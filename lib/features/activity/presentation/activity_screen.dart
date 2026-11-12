import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/providers.dart';
import '../../../shared/format.dart';
import '../../../shared/widgets/common.dart';
import '../../groups/domain/group.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activity = ref.watch(activityProvider(groupId));
    final participants = ref.watch(participantsProvider(groupId)).value ??
        const <GroupParticipant>[];
    final participantById = {
      for (final participant in participants) participant.id: participant,
    };

    return activity.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(describe(error))),
      data: (events) {
        if (events.isEmpty) {
          return const EmptyState(
            icon: Icons.history,
            title: 'No activity yet',
            message: 'Expenses, payments and settlements will appear here.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: events.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 64),
          itemBuilder: (context, index) {
            final event = events[index];
            final actor = participantById[event.actorUserId];
            final amount = event.metadata['amountMinor'];
            return ListTile(
              leading: CircleAvatar(
                child: Icon(_iconFor(event.action), size: 20),
              ),
              title: Text(_titleFor(event.action)),
              subtitle: Text(
                [
                  actor?.displayName ?? 'Someone',
                  formatTimeAgo(event.createdAt),
                ].join(' · '),
              ),
              trailing: amount is int
                  ? Text(
                      formatMoney(
                        amount,
                        (event.metadata['currency'] as String?) ?? 'INR',
                      ),
                    )
                  : null,
            );
          },
        );
      },
    );
  }

  IconData _iconFor(String action) {
    final lower = action.toLowerCase();
    if (lower.contains('expense')) return Icons.receipt_long_outlined;
    if (lower.contains('payment')) return Icons.payments_outlined;
    if (lower.contains('settlement')) return Icons.handshake_outlined;
    if (lower.contains('adjustment')) return Icons.tune;
    if (lower.contains('participant') || lower.contains('member')) {
      return Icons.people_outline;
    }
    if (lower.contains('attachment')) return Icons.attach_file;
    if (lower.contains('invite')) return Icons.person_add_alt;
    if (lower.contains('group')) return Icons.groups_outlined;
    return Icons.bolt_outlined;
  }

  String _titleFor(String action) {
    return action
        .split(RegExp(r'[._]'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }
}
