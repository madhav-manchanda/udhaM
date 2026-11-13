-- ============================================================================
-- UDHAM - LEDGER SYNC HARDENING
-- ============================================================================
-- Idempotent migration that aligns the deployed schema with the offline-first
-- client and closes authorization gaps in the original schema.
--
-- Apply with:
--   supabase db push
-- or paste this file into the Supabase SQL editor as the project owner.
--
-- Everything here is safe to run more than once.
-- ============================================================================

-- ============================================================================
-- 1. COLUMNS REQUIRED BY THE SYNC ADAPTER
-- ============================================================================

ALTER TABLE public.group_participants
    ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'member';

ALTER TABLE public.group_participants
    DROP CONSTRAINT IF EXISTS group_participants_role_check;
ALTER TABLE public.group_participants
    ADD CONSTRAINT group_participants_role_check
    CHECK (role IN ('owner', 'admin', 'member'));

-- Backfill the creator of each group as its owner.
UPDATE public.group_participants gp
SET role = 'owner'
FROM public.groups g
WHERE gp.group_id = g.id
  AND gp.user_id = g.created_by
  AND gp.role <> 'owner';

ALTER TABLE public.payments
    ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'active';
ALTER TABLE public.payments
    DROP CONSTRAINT IF EXISTS payments_status_check;
ALTER TABLE public.payments
    ADD CONSTRAINT payments_status_check
    CHECK (status IN ('active', 'reversed'));

ALTER TABLE public.settlements
    ADD COLUMN IF NOT EXISTS reference TEXT;
ALTER TABLE public.settlements
    ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'active';
ALTER TABLE public.settlements
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL
    DEFAULT timezone('utc'::text, now());
ALTER TABLE public.settlements
    DROP CONSTRAINT IF EXISTS settlements_status_check;
ALTER TABLE public.settlements
    ADD CONSTRAINT settlements_status_check
    CHECK (status IN ('active', 'reversed'));

ALTER TABLE public.balance_adjustments
    ADD COLUMN IF NOT EXISTS from_participant_id UUID
    REFERENCES public.group_participants(id) ON DELETE RESTRICT;
ALTER TABLE public.balance_adjustments
    ADD COLUMN IF NOT EXISTS to_participant_id UUID
    REFERENCES public.group_participants(id) ON DELETE RESTRICT;
ALTER TABLE public.balance_adjustments
    ADD COLUMN IF NOT EXISTS adjusted_at TIMESTAMPTZ;
ALTER TABLE public.balance_adjustments
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL
    DEFAULT timezone('utc'::text, now());

UPDATE public.balance_adjustments
SET adjusted_at = created_at
WHERE adjusted_at IS NULL;

-- The legacy row shape stored a single participant and a signed delta.
-- Preserve it, but allow the transfer-based shape the client writes.
ALTER TABLE public.balance_adjustments
    ALTER COLUMN participant_id DROP NOT NULL;

ALTER TABLE public.audit_events
    ADD COLUMN IF NOT EXISTS client_mutation_id TEXT;

CREATE UNIQUE INDEX IF NOT EXISTS audit_events_client_mutation_id_key
    ON public.audit_events (client_mutation_id)
    WHERE client_mutation_id IS NOT NULL;

-- ============================================================================
-- 2. INDEXES FOR PULL AND RLS
-- ============================================================================

CREATE INDEX IF NOT EXISTS groups_created_by_idx
    ON public.groups (created_by);
CREATE INDEX IF NOT EXISTS group_participants_group_user_idx
    ON public.group_participants (group_id, user_id);
CREATE INDEX IF NOT EXISTS group_participants_user_status_idx
    ON public.group_participants (user_id, status);
CREATE INDEX IF NOT EXISTS group_invites_group_idx
    ON public.group_invites (group_id);
CREATE INDEX IF NOT EXISTS expenses_group_updated_idx
    ON public.expenses (group_id, updated_at);
CREATE INDEX IF NOT EXISTS expense_splits_group_idx
    ON public.expense_splits (group_id);
CREATE INDEX IF NOT EXISTS payments_group_updated_idx
    ON public.payments (group_id, updated_at);
CREATE INDEX IF NOT EXISTS payment_allocations_group_idx
    ON public.payment_allocations (group_id);
CREATE INDEX IF NOT EXISTS settlements_group_updated_idx
    ON public.settlements (group_id, updated_at);
CREATE INDEX IF NOT EXISTS balance_adjustments_group_updated_idx
    ON public.balance_adjustments (group_id, updated_at);
CREATE INDEX IF NOT EXISTS attachments_group_idx
    ON public.attachments (group_id);
CREATE INDEX IF NOT EXISTS audit_events_group_created_idx
    ON public.audit_events (group_id, created_at DESC);

-- ============================================================================
-- 3. SECURITY DEFINER FUNCTIONS (PIN SEARCH PATH)
-- ============================================================================

CREATE OR REPLACE FUNCTION public.is_group_member(group_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public, pg_temp
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.group_participants
        WHERE group_id = group_uuid
          AND user_id = auth.uid()
          AND status = 'active'
    );
$$;

CREATE OR REPLACE FUNCTION public.is_group_manager(group_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public, pg_temp
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.group_participants
        WHERE group_id = group_uuid
          AND user_id = auth.uid()
          AND status = 'active'
          AND role IN ('owner', 'admin')
    );
$$;

-- ============================================================================
-- 4. REPLACE BROKEN ATOMIC GROUP DELETE
-- ============================================================================

CREATE OR REPLACE FUNCTION public.delete_group_atomic(p_group_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    IF auth.uid() IS NULL THEN
        RAISE EXCEPTION 'Authentication required.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM public.groups
        WHERE id = p_group_id AND created_by = auth.uid()
    ) AND NOT EXISTS (
        SELECT 1 FROM public.group_participants
        WHERE group_id = p_group_id
          AND user_id = auth.uid()
          AND role = 'owner'
          AND status = 'active'
    ) THEN
        RAISE EXCEPTION 'Only the group owner can delete this group.';
    END IF;

    -- Child rows first, in dependency order. The original function referenced
    -- public.sync_mutations, which does not exist and aborted every delete.
    DELETE FROM public.payment_allocations WHERE group_id = p_group_id;
    DELETE FROM public.payments WHERE group_id = p_group_id;
    DELETE FROM public.settlements WHERE group_id = p_group_id;
    DELETE FROM public.balance_adjustments WHERE group_id = p_group_id;
    DELETE FROM public.expense_splits WHERE group_id = p_group_id;
    DELETE FROM public.expenses WHERE group_id = p_group_id;
    DELETE FROM public.group_invites WHERE group_id = p_group_id;
    DELETE FROM public.audit_events WHERE group_id = p_group_id;
    DELETE FROM public.attachments WHERE group_id = p_group_id;
    DELETE FROM public.group_participants WHERE group_id = p_group_id;
    DELETE FROM public.groups WHERE id = p_group_id;

    RETURN TRUE;
END;
$$;

-- ============================================================================
-- 5. MISSING UPDATE / DELETE POLICIES
-- ============================================================================

DROP POLICY IF EXISTS "Members can update expenses" ON public.expenses;
CREATE POLICY "Members can update expenses"
    ON public.expenses FOR UPDATE TO authenticated
    USING (public.is_group_member(group_id))
    WITH CHECK (public.is_group_member(group_id));

DROP POLICY IF EXISTS "Members can delete expenses" ON public.expenses;
CREATE POLICY "Members can delete expenses"
    ON public.expenses FOR DELETE TO authenticated
    USING (public.is_group_member(group_id));

DROP POLICY IF EXISTS "Members can update splits" ON public.expense_splits;
CREATE POLICY "Members can update splits"
    ON public.expense_splits FOR UPDATE TO authenticated
    USING (public.is_group_member(group_id))
    WITH CHECK (public.is_group_member(group_id));

DROP POLICY IF EXISTS "Members can delete splits" ON public.expense_splits;
CREATE POLICY "Members can delete splits"
    ON public.expense_splits FOR DELETE TO authenticated
    USING (public.is_group_member(group_id));

DROP POLICY IF EXISTS "Members can update payments" ON public.payments;
CREATE POLICY "Members can update payments"
    ON public.payments FOR UPDATE TO authenticated
    USING (public.is_group_member(group_id))
    WITH CHECK (public.is_group_member(group_id));

DROP POLICY IF EXISTS "Members can delete payments" ON public.payments;
CREATE POLICY "Members can delete payments"
    ON public.payments FOR DELETE TO authenticated
    USING (public.is_group_member(group_id));

DROP POLICY IF EXISTS "Members can update allocations" ON public.payment_allocations;
CREATE POLICY "Members can update allocations"
    ON public.payment_allocations FOR UPDATE TO authenticated
    USING (public.is_group_member(group_id))
    WITH CHECK (public.is_group_member(group_id));

DROP POLICY IF EXISTS "Members can delete allocations" ON public.payment_allocations;
CREATE POLICY "Members can delete allocations"
    ON public.payment_allocations FOR DELETE TO authenticated
    USING (public.is_group_member(group_id));

DROP POLICY IF EXISTS "Members can update settlements" ON public.settlements;
CREATE POLICY "Members can update settlements"
    ON public.settlements FOR UPDATE TO authenticated
    USING (public.is_group_member(group_id))
    WITH CHECK (public.is_group_member(group_id));

DROP POLICY IF EXISTS "Members can delete settlements" ON public.settlements;
CREATE POLICY "Members can delete settlements"
    ON public.settlements FOR DELETE TO authenticated
    USING (public.is_group_member(group_id));

DROP POLICY IF EXISTS "Members can update adjustments" ON public.balance_adjustments;
CREATE POLICY "Members can update adjustments"
    ON public.balance_adjustments FOR UPDATE TO authenticated
    USING (public.is_group_member(group_id))
    WITH CHECK (public.is_group_member(group_id));

DROP POLICY IF EXISTS "Members can delete adjustments" ON public.balance_adjustments;
CREATE POLICY "Members can delete adjustments"
    ON public.balance_adjustments FOR DELETE TO authenticated
    USING (public.is_group_member(group_id));

DROP POLICY IF EXISTS "Members can update attachments" ON public.attachments;
CREATE POLICY "Members can update attachments"
    ON public.attachments FOR UPDATE TO authenticated
    USING (public.is_group_member(group_id))
    WITH CHECK (public.is_group_member(group_id));

DROP POLICY IF EXISTS "Members can delete attachments" ON public.attachments;
CREATE POLICY "Members can delete attachments"
    ON public.attachments FOR DELETE TO authenticated
    USING (public.is_group_member(group_id));

-- Attachment link tables were never granted any policy, so member reads and
-- writes silently returned nothing.
DROP POLICY IF EXISTS "Members can view expense attachments" ON public.expense_attachments;
CREATE POLICY "Members can view expense attachments"
    ON public.expense_attachments FOR SELECT TO authenticated
    USING (EXISTS (
        SELECT 1 FROM public.expenses e
        WHERE e.id = expense_id AND public.is_group_member(e.group_id)
    ));

DROP POLICY IF EXISTS "Members can write expense attachments" ON public.expense_attachments;
CREATE POLICY "Members can write expense attachments"
    ON public.expense_attachments FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM public.expenses e
        WHERE e.id = expense_id AND public.is_group_member(e.group_id)
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM public.expenses e
        WHERE e.id = expense_id AND public.is_group_member(e.group_id)
    ));

DROP POLICY IF EXISTS "Members can view payment attachments" ON public.payment_attachments;
CREATE POLICY "Members can view payment attachments"
    ON public.payment_attachments FOR SELECT TO authenticated
    USING (EXISTS (
        SELECT 1 FROM public.payments p
        WHERE p.id = payment_id AND public.is_group_member(p.group_id)
    ));

DROP POLICY IF EXISTS "Members can write payment attachments" ON public.payment_attachments;
CREATE POLICY "Members can write payment attachments"
    ON public.payment_attachments FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM public.payments p
        WHERE p.id = payment_id AND public.is_group_member(p.group_id)
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM public.payments p
        WHERE p.id = payment_id AND public.is_group_member(p.group_id)
    ));

DROP POLICY IF EXISTS "Members can view settlement attachments" ON public.settlement_attachments;
CREATE POLICY "Members can view settlement attachments"
    ON public.settlement_attachments FOR SELECT TO authenticated
    USING (EXISTS (
        SELECT 1 FROM public.settlements s
        WHERE s.id = settlement_id AND public.is_group_member(s.group_id)
    ));

DROP POLICY IF EXISTS "Members can write settlement attachments" ON public.settlement_attachments;
CREATE POLICY "Members can write settlement attachments"
    ON public.settlement_attachments FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM public.settlements s
        WHERE s.id = settlement_id AND public.is_group_member(s.group_id)
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM public.settlements s
        WHERE s.id = settlement_id AND public.is_group_member(s.group_id)
    ));

-- Activity history was write-only: no SELECT policy existed.
DROP POLICY IF EXISTS "Members can view activity" ON public.audit_events;
CREATE POLICY "Members can view activity"
    ON public.audit_events FOR SELECT TO authenticated
    USING (public.is_group_member(group_id));

DROP POLICY IF EXISTS "Members can write activity" ON public.audit_events;
CREATE POLICY "Members can write activity"
    ON public.audit_events FOR INSERT TO authenticated
    WITH CHECK (public.is_group_member(group_id));

-- The client replicates activity with an idempotent upsert, which needs an
-- UPDATE policy as well as INSERT when the same client_mutation_id is retried.
DROP POLICY IF EXISTS "Members can update activity" ON public.audit_events;
CREATE POLICY "Members can update activity"
    ON public.audit_events FOR UPDATE TO authenticated
    USING (public.is_group_member(group_id))
    WITH CHECK (public.is_group_member(group_id));

-- Invites may be revoked by their creator or a group manager.
DROP POLICY IF EXISTS "Group creators or invite creators can delete group invites"
    ON public.group_invites;
CREATE POLICY "Group creators or invite creators can delete group invites"
    ON public.group_invites FOR DELETE TO authenticated
    USING (created_by = auth.uid() OR public.is_group_manager(group_id));

-- ============================================================================
-- 6. STORAGE OBJECT POLICIES
-- ============================================================================

DROP POLICY IF EXISTS "Authenticated users can update attachments"
    ON storage.objects;
CREATE POLICY "Authenticated users can update attachments"
    ON storage.objects FOR UPDATE TO authenticated
    USING (bucket_id = 'attachments' AND auth.uid() IS NOT NULL)
    WITH CHECK (bucket_id = 'attachments' AND auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "Authenticated users can delete attachments"
    ON storage.objects;
CREATE POLICY "Authenticated users can delete attachments"
    ON storage.objects FOR DELETE TO authenticated
    USING (bucket_id = 'attachments' AND auth.uid() IS NOT NULL);

-- ============================================================================
-- 7. REALTIME PUBLICATION
-- ============================================================================

DO $$
DECLARE
    table_name TEXT;
BEGIN
    IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
        FOREACH table_name IN ARRAY ARRAY[
            'groups',
            'group_participants',
            'expenses',
            'expense_splits',
            'payments',
            'payment_allocations',
            'settlements',
            'balance_adjustments',
            'attachments',
            'expense_attachments',
            'payment_attachments',
            'settlement_attachments',
            'audit_events'
        ]
        LOOP
            IF NOT EXISTS (
                SELECT 1
                FROM pg_publication_tables
                WHERE pubname = 'supabase_realtime'
                  AND schemaname = 'public'
                  AND tablename = table_name
            ) THEN
                EXECUTE format(
                    'ALTER PUBLICATION supabase_realtime ADD TABLE public.%I',
                    table_name
                );
            END IF;
        END LOOP;
    END IF;
END
$$;
