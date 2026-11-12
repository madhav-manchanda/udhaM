import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/providers/providers.dart';
import '../../../shared/widgets/design_system.dart';

Future<void> showJoinGroupDialog(
  BuildContext context,
  WidgetRef ref,
  String profileId,
) async {
  final token = TextEditingController();
  var busy = false;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) {
        Future<void> submit() async {
          var raw = token.text.trim();
          if (busy || raw.isEmpty) return;

          // Strip URL query parameters or route prefix if pasted from browser
          if (raw.contains('code=')) {
            raw = Uri.tryParse(raw)?.queryParameters['code'] ?? raw;
          } else if (raw.contains('/invite/')) {
            raw = raw.split('/invite/').last.split('?').first.split('/').first;
          }

          setState(() => busy = true);
          try {
            final groupId =
                await ref.read(groupRepositoryProvider).redeemInvite(
                      actorProfileId: profileId,
                      token: raw,
                    );
            unawaited(ref.read(syncCoordinatorProvider).syncNow());
            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
              context.push('/groups/$groupId');
              showMessage(context, 'Joined group successfully.');
            }
          } catch (error) {
            if (dialogContext.mounted) showError(dialogContext, error);
          } finally {
            if (dialogContext.mounted) setState(() => busy = false);
          }
        }

        return AlertDialog(
          backgroundColor: UdhamColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          title: Text(
            'JOIN EXISTING GROUP',
            style: GoogleFonts.spaceMono(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: UdhamColors.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter the 6-character group code (e.g. 79F5E3 or #GRP-79F5E3), full UUID, or invite link.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: UdhamColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: token,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                style: GoogleFonts.spaceMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: UdhamColors.onSurface),
                decoration: InputDecoration(
                  labelText: 'Group Code or Link',
                  hintText: 'e.g. #GRP-79F5E3 or 79F5E3',
                  hintStyle: GoogleFonts.inter(
                    color: UdhamColors.outline,
                    fontSize: 12,
                    letterSpacing: 0,
                  ),
                ),
                onSubmitted: (_) => submit(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: busy ? null : () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: busy ? null : submit,
              style: FilledButton.styleFrom(
                backgroundColor: UdhamColors.secondaryContainer,
                foregroundColor: UdhamColors.onSecondaryContainer,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2)),
              ),
              child: busy
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Join Group'),
            ),
          ],
        );
      },
    ),
  );
}
