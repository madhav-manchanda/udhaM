-- ============================================================================
-- UDHAM - GROUP INVITES & STORAGE POLICIES
-- ============================================================================

-- 1. GROUP INVITES POLICIES
-- Allow authenticated group members/creators to view invites for their groups
CREATE POLICY "Group members can view group invites"
    ON public.group_invites FOR SELECT TO authenticated
    USING (public.is_group_member(group_id) OR EXISTS (
        SELECT 1 FROM public.groups WHERE id = group_id AND created_by = auth.uid()
    ));

-- Allow group members or creators to insert invites
CREATE POLICY "Group members or creators can insert group invites"
    ON public.group_invites FOR INSERT TO authenticated
    WITH CHECK (
        created_by = auth.uid() AND (
            public.is_group_member(group_id) OR EXISTS (
                SELECT 1 FROM public.groups WHERE id = group_id AND created_by = auth.uid()
            )
        )
    );

-- Allow creators to update or revoke invites
CREATE POLICY "Group creators or invite creators can update group invites"
    ON public.group_invites FOR UPDATE TO authenticated
    USING (created_by = auth.uid() OR public.is_group_member(group_id));

-- 2. SECURE ATOMIC RPC: CREATE GROUP INVITE
CREATE OR REPLACE FUNCTION public.create_group_invite(
    p_group_id UUID,
    p_token_raw TEXT,
    p_max_uses INT DEFAULT 100,
    p_expires_in_days INT DEFAULT 7
)
RETURNS UUID AS $$
DECLARE
    v_token_hash TEXT;
    v_invite_id UUID;
BEGIN
    -- Verify caller is active member or group creator
    IF NOT (public.is_group_member(p_group_id) OR EXISTS (
        SELECT 1 FROM public.groups WHERE id = p_group_id AND created_by = auth.uid()
    )) THEN
        RAISE EXCEPTION 'Not authorized to create invite for this group.';
    END IF;

    -- Hash token using sha256 to store in token_hash column
    v_token_hash := encode(digest(trim(p_token_raw), 'sha256'), 'hex');
    v_invite_id := gen_random_uuid();

    INSERT INTO public.group_invites (
        id,
        group_id,
        created_by,
        token_hash,
        expires_at,
        max_uses,
        use_count,
        created_at
    ) VALUES (
        v_invite_id,
        p_group_id,
        auth.uid(),
        v_token_hash,
        now() + (p_expires_in_days || ' days')::INTERVAL,
        p_max_uses,
        0,
        now()
    );

    RETURN v_invite_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. STORAGE POLICIES FOR ATTACHMENTS BUCKET
INSERT INTO storage.buckets (id, name, public)
VALUES ('attachments', 'attachments', false)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Authenticated users can upload attachments to their groups"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (
    bucket_id = 'attachments' AND
    auth.uid() IS NOT NULL
);

CREATE POLICY "Authenticated users can read attachments"
ON storage.objects FOR SELECT TO authenticated
USING (
    bucket_id = 'attachments' AND
    auth.uid() IS NOT NULL
);
