-- ============================================================================
-- UDHAM - INSTANT GROUP JOIN, GROUP DELETE & RLS POLICIES
-- ============================================================================

-- 1. DELETE POLICY FOR GROUPS TABLE
-- Allow group creators to delete their groups directly
DROP POLICY IF EXISTS "Group creators can delete group" ON public.groups;
CREATE POLICY "Group creators can delete group"
    ON public.groups FOR DELETE TO authenticated
    USING (created_by = auth.uid());

-- 2. DELETE POLICY FOR GROUP PARTICIPANTS
-- Allow users to leave (delete their own participant row) or group creators to remove members
DROP POLICY IF EXISTS "Users can leave group or creators can remove members" ON public.group_participants;
CREATE POLICY "Users can leave group or creators can remove members"
    ON public.group_participants FOR DELETE TO authenticated
    USING (user_id = auth.uid() OR EXISTS (
        SELECT 1 FROM public.groups WHERE id = group_id AND created_by = auth.uid()
    ));

-- 3. ATOMIC RPC: DELETE GROUP
-- Cascadingly deletes all financial and group records for a group in one atomic call
CREATE OR REPLACE FUNCTION public.delete_group_atomic(p_group_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    IF auth.uid() IS NULL THEN
        RAISE EXCEPTION 'Authentication required.';
    END IF;

    -- Verify caller is creator or owner
    IF NOT EXISTS (
        SELECT 1 FROM public.groups WHERE id = p_group_id AND created_by = auth.uid()
    ) AND NOT EXISTS (
        SELECT 1 FROM public.group_participants 
        WHERE group_id = p_group_id AND user_id = auth.uid() AND role = 'owner' AND status = 'active'
    ) THEN
        RAISE EXCEPTION 'Only the group owner can delete this group.';
    END IF;

    -- Clean up children in dependency order
    DELETE FROM public.payment_allocations WHERE group_id = p_group_id;
    DELETE FROM public.payments WHERE group_id = p_group_id;
    DELETE FROM public.settlements WHERE group_id = p_group_id;
    DELETE FROM public.balance_adjustments WHERE group_id = p_group_id;
    DELETE FROM public.expense_splits WHERE group_id = p_group_id;
    DELETE FROM public.expenses WHERE group_id = p_group_id;
    DELETE FROM public.group_invites WHERE group_id = p_group_id;
    DELETE FROM public.audit_events WHERE group_id = p_group_id;
    DELETE FROM public.attachments WHERE group_id = p_group_id;
    DELETE FROM public.sync_mutations WHERE group_id = p_group_id;
    DELETE FROM public.group_participants WHERE group_id = p_group_id;
    DELETE FROM public.groups WHERE id = p_group_id;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. ATOMIC RPC: INSTANT JOIN GROUP BY CODE OR ID
-- Joins a group instantly by entering either:
--  - A 6-character code (e.g. 79F5E3)
--  - Formatted group code (e.g. #GRP-79F5E3 or GRP-79F5E3)
--  - Full Group UUID
--  - Or an invite token
CREATE OR REPLACE FUNCTION public.join_group_by_code(p_code TEXT)
RETURNS UUID AS $$
DECLARE
    v_clean_code TEXT;
    v_group_id UUID := NULL;
    v_group RECORD;
    v_user_profile RECORD;
    v_participant_id UUID;
    v_token_hash TEXT;
BEGIN
    IF auth.uid() IS NULL THEN
        RAISE EXCEPTION 'Authentication required to join a group.';
    END IF;

    -- Clean input
    v_clean_code := upper(trim(p_code));
    IF v_clean_code LIKE '#GRP-%' THEN
        v_clean_code := substring(v_clean_code FROM 6);
    ELSIF v_clean_code LIKE 'GRP-%' THEN
        v_clean_code := substring(v_clean_code FROM 5);
    ELSIF v_clean_code LIKE '#%' THEN
        v_clean_code := substring(v_clean_code FROM 2);
    END IF;
    v_clean_code := trim(v_clean_code);

    IF length(v_clean_code) = 0 THEN
        RAISE EXCEPTION 'Please enter a valid group code or invite.';
    END IF;

    -- 1. Check if it's a full UUID
    BEGIN
        IF length(v_clean_code) = 36 THEN
            SELECT * INTO v_group FROM public.groups WHERE id = v_clean_code::UUID LIMIT 1;
            IF v_group.id IS NOT NULL THEN
                v_group_id := v_group.id;
            END IF;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        v_group_id := NULL;
    END;

    -- 2. Check if it matches UUID prefix (6 or more chars)
    IF v_group_id IS NULL AND length(v_clean_code) >= 6 THEN
        SELECT * INTO v_group
        FROM public.groups
        WHERE upper(replace(id::text, '-', '')) LIKE v_clean_code || '%'
           OR upper(id::text) LIKE v_clean_code || '%'
        LIMIT 1;

        IF v_group.id IS NOT NULL THEN
            v_group_id := v_group.id;
        END IF;
    END IF;

    -- 3. Check group_invites table by token_hash
    IF v_group_id IS NULL THEN
        v_token_hash := encode(digest(trim(p_code), 'sha256'), 'hex');
        SELECT group_id INTO v_group_id
        FROM public.group_invites
        WHERE token_hash = v_token_hash
          AND (revoked_at IS NULL)
          AND (expires_at IS NULL OR expires_at > now())
        LIMIT 1;

        IF v_group_id IS NOT NULL THEN
            SELECT * INTO v_group FROM public.groups WHERE id = v_group_id LIMIT 1;
        END IF;
    END IF;

    IF v_group_id IS NULL OR v_group.id IS NULL THEN
        RAISE EXCEPTION 'No group found for code: %', p_code;
    END IF;

    IF v_group.is_archived THEN
        RAISE EXCEPTION 'This group has been archived and cannot be joined.';
    END IF;

    -- Fetch user profile
    SELECT * INTO v_user_profile FROM public.profiles WHERE id = auth.uid();

    -- Check if user is already an active member
    SELECT id INTO v_participant_id
    FROM public.group_participants
    WHERE group_id = v_group_id AND user_id = auth.uid() AND status = 'active'
    LIMIT 1;

    -- If not active participant, insert or activate
    IF v_participant_id IS NULL THEN
        INSERT INTO public.group_participants (
            id,
            group_id,
            user_id,
            display_name,
            participant_type,
            status,
            role,
            created_at,
            updated_at
        ) VALUES (
            gen_random_uuid(),
            v_group_id,
            auth.uid(),
            COALESCE(v_user_profile.display_name, 'Member'),
            'registered',
            'active',
            'member',
            now(),
            now()
        );
    END IF;

    RETURN v_group_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
