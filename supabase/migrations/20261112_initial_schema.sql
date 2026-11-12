-- ============================================================================
-- UDHAM LEDGER ENGINE - SUPABASE POSTGRESQL SCHEMA & GOOGLE OAUTH PROFILES
-- ============================================================================
-- Architecture: Offline-first synchronized shared expense ledger
-- Monetary storage: BIGINT minor units (1 INR = 100 paise)
-- Authentication: Supabase Auth (Google OAuth exclusively)
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- 1. PROFILES (SYNCHRONIZED WITH GOOGLE AUTH)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT NOT NULL,
    email TEXT,
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Trigger: Automatically populate profile upon Google OAuth sign-in
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, display_name, email, avatar_url, created_at, updated_at)
    VALUES (
        NEW.id,
        COALESCE(
            NEW.raw_user_meta_data->>'full_name',
            NEW.raw_user_meta_data->>'name',
            SPLIT_PART(NEW.email, '@', 1),
            'UdhaM User'
        ),
        NEW.email,
        COALESCE(
            NEW.raw_user_meta_data->>'avatar_url',
            NEW.raw_user_meta_data->>'picture'
        ),
        timezone('utc'::text, now()),
        timezone('utc'::text, now())
    )
    ON CONFLICT (id) DO UPDATE SET
        display_name = EXCLUDED.display_name,
        email = EXCLUDED.email,
        avatar_url = EXCLUDED.avatar_url,
        updated_at = timezone('utc'::text, now());

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT OR UPDATE ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================================
-- 2. GROUPS & PARTICIPANTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL CHECK (char_length(trim(name)) > 0),
    description TEXT,
    created_by UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    default_currency TEXT NOT NULL DEFAULT 'INR',
    is_archived BOOLEAN NOT NULL DEFAULT FALSE,
    archived_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE TABLE IF NOT EXISTS public.group_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    display_name TEXT NOT NULL CHECK (char_length(trim(display_name)) > 0),
    participant_type TEXT NOT NULL DEFAULT 'registered' CHECK (participant_type IN ('registered', 'guest')),
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'left', 'removed')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    UNIQUE(group_id, user_id)
);

CREATE TABLE IF NOT EXISTS public.group_invites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
    created_by UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    token_hash TEXT NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ,
    max_uses INT NOT NULL DEFAULT 100,
    use_count INT NOT NULL DEFAULT 0,
    revoked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- ============================================================================
-- 3. EXPENSES & SPLITS
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.expenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
    created_by UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    description TEXT NOT NULL CHECK (char_length(trim(description)) > 0),
    amount_minor BIGINT NOT NULL CHECK (amount_minor > 0),
    currency TEXT NOT NULL DEFAULT 'INR',
    expense_date TIMESTAMPTZ NOT NULL,
    expected_payer_participant_id UUID REFERENCES public.group_participants(id) ON DELETE SET NULL,
    category TEXT,
    notes TEXT,
    split_method TEXT NOT NULL DEFAULT 'equal' CHECK (split_method IN ('equal', 'custom', 'shares', 'percentage')),
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'voided')),
    version INT NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE TABLE IF NOT EXISTS public.expense_splits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    expense_id UUID NOT NULL REFERENCES public.expenses(id) ON DELETE CASCADE,
    group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
    participant_id UUID NOT NULL REFERENCES public.group_participants(id) ON DELETE CASCADE,
    share_minor BIGINT NOT NULL CHECK (share_minor >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    UNIQUE(expense_id, participant_id)
);

-- ============================================================================
-- 4. PAYMENTS & ALLOCATIONS
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
    created_by UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    payer_participant_id UUID NOT NULL REFERENCES public.group_participants(id) ON DELETE RESTRICT,
    amount_minor BIGINT NOT NULL CHECK (amount_minor > 0),
    currency TEXT NOT NULL DEFAULT 'INR',
    payment_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    reference TEXT,
    notes TEXT,
    version INT NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE TABLE IF NOT EXISTS public.payment_allocations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
    payment_id UUID NOT NULL REFERENCES public.payments(id) ON DELETE CASCADE,
    expense_id UUID NOT NULL REFERENCES public.expenses(id) ON DELETE CASCADE,
    amount_minor BIGINT NOT NULL CHECK (amount_minor > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    UNIQUE(payment_id, expense_id)
);

-- ============================================================================
-- 5. SETTLEMENTS & ADJUSTMENTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.settlements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
    created_by UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    from_participant_id UUID NOT NULL REFERENCES public.group_participants(id) ON DELETE RESTRICT,
    to_participant_id UUID NOT NULL REFERENCES public.group_participants(id) ON DELETE RESTRICT,
    amount_minor BIGINT NOT NULL CHECK (amount_minor > 0),
    currency TEXT NOT NULL DEFAULT 'INR',
    settled_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE TABLE IF NOT EXISTS public.balance_adjustments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
    created_by UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    participant_id UUID NOT NULL REFERENCES public.group_participants(id) ON DELETE RESTRICT,
    adjustment_minor BIGINT NOT NULL,
    currency TEXT NOT NULL DEFAULT 'INR',
    reason TEXT NOT NULL CHECK (char_length(trim(reason)) > 0),
    status TEXT NOT NULL DEFAULT 'confirmed' CHECK (status IN ('pending', 'confirmed', 'voided')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- ============================================================================
-- 6. ATTACHMENTS & AUDIT EVENTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
    uploaded_by UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    storage_path TEXT NOT NULL,
    file_name TEXT NOT NULL,
    mime_type TEXT NOT NULL,
    size_bytes BIGINT NOT NULL,
    checksum TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE TABLE IF NOT EXISTS public.expense_attachments (
    expense_id UUID NOT NULL REFERENCES public.expenses(id) ON DELETE CASCADE,
    attachment_id UUID NOT NULL REFERENCES public.attachments(id) ON DELETE CASCADE,
    PRIMARY KEY(expense_id, attachment_id)
);

CREATE TABLE IF NOT EXISTS public.payment_attachments (
    payment_id UUID NOT NULL REFERENCES public.payments(id) ON DELETE CASCADE,
    attachment_id UUID NOT NULL REFERENCES public.attachments(id) ON DELETE CASCADE,
    PRIMARY KEY(payment_id, attachment_id)
);

CREATE TABLE IF NOT EXISTS public.settlement_attachments (
    settlement_id UUID NOT NULL REFERENCES public.settlements(id) ON DELETE CASCADE,
    attachment_id UUID NOT NULL REFERENCES public.attachments(id) ON DELETE CASCADE,
    PRIMARY KEY(settlement_id, attachment_id)
);

CREATE TABLE IF NOT EXISTS public.audit_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
    actor_user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    entity_type TEXT NOT NULL,
    entity_id UUID NOT NULL,
    action TEXT NOT NULL,
    before_data JSONB,
    after_data JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Idempotency mutation tracking for offline sync
CREATE TABLE IF NOT EXISTS public.client_mutations (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
    mutation_type TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'applied',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    applied_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- ============================================================================
-- 7. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_invites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expense_splits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_allocations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.settlements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.balance_adjustments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expense_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.settlement_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.client_mutations ENABLE ROW LEVEL SECURITY;

-- Helper function: Check if current auth user is an active participant in group
CREATE OR REPLACE FUNCTION public.is_group_member(group_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM public.group_participants
        WHERE group_id = group_uuid
          AND user_id = auth.uid()
          AND status = 'active'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Profiles: Anyone authenticated can read profiles; users can only update their own
CREATE POLICY "Profiles are readable by authenticated users"
    ON public.profiles FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "Users can update their own profile"
    ON public.profiles FOR UPDATE TO authenticated
    USING (id = auth.uid())
    WITH CHECK (id = auth.uid());

-- Groups: Read and mutate if active member or creator
CREATE POLICY "Users can view groups they participate in"
    ON public.groups FOR SELECT TO authenticated
    USING (created_by = auth.uid() OR public.is_group_member(id));

CREATE POLICY "Users can insert groups"
    ON public.groups FOR INSERT TO authenticated
    WITH CHECK (created_by = auth.uid());

CREATE POLICY "Group creators or members can update group"
    ON public.groups FOR UPDATE TO authenticated
    USING (created_by = auth.uid() OR public.is_group_member(id));

-- Group Participants
CREATE POLICY "Group members can view participants"
    ON public.group_participants FOR SELECT TO authenticated
    USING (public.is_group_member(group_id));

CREATE POLICY "Group members or creators can insert participants"
    ON public.group_participants FOR INSERT TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.groups
            WHERE id = group_id AND created_by = auth.uid()
        ) OR public.is_group_member(group_id)
    );

CREATE POLICY "Group participants can update"
    ON public.group_participants FOR UPDATE TO authenticated
    USING (public.is_group_member(group_id));

-- Expenses & Splits
CREATE POLICY "Members can view expenses"
    ON public.expenses FOR SELECT TO authenticated
    USING (public.is_group_member(group_id));

CREATE POLICY "Members can insert expenses"
    ON public.expenses FOR INSERT TO authenticated
    WITH CHECK (public.is_group_member(group_id));

CREATE POLICY "Members can update expenses"
    ON public.expenses FOR UPDATE TO authenticated
    USING (public.is_group_member(group_id));

CREATE POLICY "Members can view splits"
    ON public.expense_splits FOR SELECT TO authenticated
    USING (public.is_group_member(group_id));

CREATE POLICY "Members can insert splits"
    ON public.expense_splits FOR INSERT TO authenticated
    WITH CHECK (public.is_group_member(group_id));

-- Payments & Allocations
CREATE POLICY "Members can view payments"
    ON public.payments FOR SELECT TO authenticated
    USING (public.is_group_member(group_id));

CREATE POLICY "Members can insert payments"
    ON public.payments FOR INSERT TO authenticated
    WITH CHECK (public.is_group_member(group_id));

CREATE POLICY "Members can view allocations"
    ON public.payment_allocations FOR SELECT TO authenticated
    USING (public.is_group_member(group_id));

CREATE POLICY "Members can insert allocations"
    ON public.payment_allocations FOR INSERT TO authenticated
    WITH CHECK (public.is_group_member(group_id));

-- Settlements & Adjustments
CREATE POLICY "Members can view settlements"
    ON public.settlements FOR SELECT TO authenticated
    USING (public.is_group_member(group_id));

CREATE POLICY "Members can insert settlements"
    ON public.settlements FOR INSERT TO authenticated
    WITH CHECK (public.is_group_member(group_id));

CREATE POLICY "Members can view adjustments"
    ON public.balance_adjustments FOR SELECT TO authenticated
    USING (public.is_group_member(group_id));

CREATE POLICY "Members can insert adjustments"
    ON public.balance_adjustments FOR INSERT TO authenticated
    WITH CHECK (public.is_group_member(group_id));

-- Attachments
CREATE POLICY "Members can view attachments"
    ON public.attachments FOR SELECT TO authenticated
    USING (public.is_group_member(group_id));

CREATE POLICY "Members can upload attachments"
    ON public.attachments FOR INSERT TO authenticated
    WITH CHECK (public.is_group_member(group_id));

-- Client Mutations (Idempotency)
CREATE POLICY "Users can insert their own client mutations"
    ON public.client_mutations FOR ALL TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- ============================================================================
-- 8. TRANSACTIONAL ATOMIC RPC: INVITE REDEMPTION
-- ============================================================================

CREATE OR REPLACE FUNCTION public.redeem_group_invite(invite_token_raw TEXT)
RETURNS UUID AS $$
DECLARE
    v_token_hash TEXT;
    v_invite RECORD;
    v_participant_id UUID;
    v_user_profile RECORD;
BEGIN
    -- Hash incoming token using sha256 to compare with stored token_hash
    v_token_hash := encode(digest(trim(invite_token_raw), 'sha256'), 'hex');

    SELECT * INTO v_invite
    FROM public.group_invites
    WHERE token_hash = v_token_hash
      AND (revoked_at IS NULL)
      AND (expires_at IS NULL OR expires_at > now())
      AND (use_count < max_uses)
    LIMIT 1;

    IF v_invite IS NULL THEN
        RAISE EXCEPTION 'Invalid, expired, or revoked invite code.';
    END IF;

    -- Check if user is already an active member of the group
    SELECT id INTO v_participant_id
    FROM public.group_participants
    WHERE group_id = v_invite.group_id
      AND user_id = auth.uid()
      AND status = 'active';

    IF v_participant_id IS NOT NULL THEN
        RETURN v_invite.group_id; -- Already a member, return group ID directly
    END IF;

    -- Fetch user profile display name
    SELECT * INTO v_user_profile
    FROM public.profiles
    WHERE id = auth.uid();

    -- Insert participant
    INSERT INTO public.group_participants (
        id,
        group_id,
        user_id,
        display_name,
        participant_type,
        status,
        created_at,
        updated_at
    ) VALUES (
        gen_random_uuid(),
        v_invite.group_id,
        auth.uid(),
        COALESCE(v_user_profile.display_name, 'New Member'),
        'registered',
        'active',
        now(),
        now()
    );

    -- Increment usage counter
    UPDATE public.group_invites
    SET use_count = use_count + 1
    WHERE id = v_invite.id;

    RETURN v_invite.group_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
