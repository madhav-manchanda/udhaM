import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/providers/providers.dart';
import '../../../shared/format.dart';
import '../../../shared/widgets/design_system.dart';
import '../../activity/domain/activity_event.dart';
import '../../groups/presentation/join_group_dialog.dart';

class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider).value;
    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final groups = ref.watch(groupsProvider(profile.id));
    final inboxCount = ref.watch(smartInboxCountProvider).value ?? 0;

    return Scaffold(
      backgroundColor: UdhamColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _OverviewHeader(
              name: profile.displayName,
              inboxCount: inboxCount,
              onProfile: () => context.push('/profile'),
              onInbox: () => context.push('/inbox'),
            ),
            Expanded(
              child: groups.when(
                loading: () => const _OverviewSkeleton(),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off_outlined,
                            size: 40, color: UdhamColors.outline),
                        const SizedBox(height: 12),
                        Text(describe(error), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () => ref.invalidate(groupsProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (groupList) => _OverviewBody(
                  profileId: profile.id,
                  groups: groupList,
                  ref: ref,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader({
    required this.name,
    required this.inboxCount,
    required this.onProfile,
    required this.onInbox,
  });

  final String name;
  final int inboxCount;
  final VoidCallback onProfile;
  final VoidCallback onInbox;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: UdhamColors.surface,
        border: Border(
          bottom: BorderSide(color: UdhamColors.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: UdhamColors.outlineVariant, width: 0.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/logo_icon.png',
              fit: BoxFit.cover,
            ),
          ),
          Text(
            'UdhaM',
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: UdhamColors.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.push('/budget'),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              size: 22,
              color: UdhamColors.onSurface,
            ),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: () => context.push('/analytics'),
            child: const Icon(
              Icons.query_stats_outlined,
              size: 22,
              color: UdhamColors.onSurface,
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: onInbox,
            child: Badge(
              isLabelVisible: inboxCount > 0,
              label: Text('$inboxCount'),
              backgroundColor: UdhamColors.secondaryContainer,
              textColor: UdhamColors.onSecondaryContainer,
              child: const Icon(Icons.notifications_outlined,
                  size: 22, color: UdhamColors.onSurface),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: onProfile,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: UdhamColors.primaryContainer,
                borderRadius: BorderRadius.all(Radius.circular(18)),
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: UdhamColors.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

class _OverviewBody extends ConsumerWidget {
  const _OverviewBody({
    required this.profileId,
    required this.groups,
    required this.ref,
  });

  final String profileId;
  final List groups;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => ref.read(syncCoordinatorProvider).syncNow(),
      color: UdhamColors.secondary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 112),
        children: [
          // Active group selector
          _ActiveGroupSelector(profileId: profileId),
          const SizedBox(height: 16),

          // Net position card
          _NetPositionCard(profileId: profileId),
          const SizedBox(height: 16),

          // Quick actions row
          _QuickActions(profileId: profileId),
          const SizedBox(height: 20),

          // Active groups section
          _SectionLabel(
            label: 'ACTIVE GROUPS',
            actionLabel: '+ Join',
            onAction: () => showJoinGroupDialog(context, ref, profileId),
            onViewAll: () => context.go('/groups'),
          ),
          const SizedBox(height: 8),
          _GroupsList(profileId: profileId),
          const SizedBox(height: 20),

          // Recent activity
          const _SectionLabel(label: 'RECENT ACTIVITY'),
          const SizedBox(height: 8),
          _RecentActivity(profileId: profileId),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Active group selector
// ---------------------------------------------------------------------------

class _ActiveGroupSelector extends ConsumerWidget {
  const _ActiveGroupSelector({required this.profileId});

  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupsProvider(profileId)).value ?? [];
    final activeGroups = groups.where((g) => !g.isArchived).toList();

    if (activeGroups.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => context.go('/groups'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: UdhamColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: UdhamColors.outlineVariant),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  activeGroups.first.name,
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: UdhamColors.onSurface,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_outlined,
                    size: 18, color: UdhamColors.onSurfaceVariant),
              ],
            ),
          ),
        ),
        Text(
          '${activeGroups.length} group${activeGroups.length == 1 ? '' : 's'}',
          style: GoogleFonts.inter(
              fontSize: 12, color: UdhamColors.onSurfaceVariant),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Net position card
// ---------------------------------------------------------------------------

class _NetPositionCard extends ConsumerWidget {
  const _NetPositionCard({required this.profileId});

  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupsProvider(profileId)).value ?? [];
    final activeGroups = groups.where((g) => !g.isArchived).toList();

    // Aggregate balances across groups
    int totalOwedToMe = 0;
    int totalIOwe = 0;

    for (final group in activeGroups) {
      final balances = ref.watch(balancesProvider(group.id)).value;
      final participants =
          ref.watch(participantsProvider(group.id)).value ?? [];
      final me = participants.firstWhereOrNull((p) => p.userId == profileId);
      if (me != null && balances != null) {
        final net = balances.lineFor(me.id)?.netMinor ?? 0;
        if (net > 0) totalOwedToMe += net;
        if (net < 0) totalIOwe += net.abs();
      }
    }

    final netMinor = totalOwedToMe - totalIOwe;
    const currency = 'INR';
    final isPositive = netMinor >= 0;
    final barOwedWidth = totalOwedToMe + totalIOwe == 0
        ? 0.5
        : totalOwedToMe / (totalOwedToMe + totalIOwe);

    return GestureDetector(
      onTap: () => context.push('/analytics'),
      child: Container(
        decoration: BoxDecoration(
          color: UdhamColors.primaryContainer,
          borderRadius: BorderRadius.circular(2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x660A0D0B),
              offset: Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'NET BALANCE',
                      style: GoogleFonts.spaceMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                        color: UdhamColors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward_outlined,
                      size: 12,
                      color: UdhamColors.onPrimaryContainer,
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: UdhamColors.tertiaryContainer,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    isPositive ? 'SURPLUS' : 'DEFICIT',
                    style: GoogleFonts.spaceMono(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: UdhamColors.onTertiaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              formatSignedMoney(netMinor, currency),
              style: GoogleFonts.spaceMono(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: UdhamColors.inverseOnSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            // Balance bar
            if (totalOwedToMe + totalIOwe > 0) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: SizedBox(
                  height: 6,
                  child: Row(
                    children: [
                      Flexible(
                        flex: (barOwedWidth * 100).round().clamp(1, 99),
                        child: Container(color: UdhamColors.secondaryContainer),
                      ),
                      Flexible(
                        flex: ((1 - barOwedWidth) * 100).round().clamp(1, 99),
                        child: Container(color: UdhamColors.error),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            // Split row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You are owed',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: UdhamColors.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatMoney(totalOwedToMe, currency),
                        style: GoogleFonts.spaceMono(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: UdhamColors.secondaryFixed,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You owe',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: UdhamColors.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatMoney(totalIOwe, currency),
                        style: GoogleFonts.spaceMono(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: UdhamColors.errorContainer,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick actions row
// ---------------------------------------------------------------------------

class _QuickActions extends ConsumerWidget {
  const _QuickActions({required this.profileId});

  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inboxCount = ref.watch(smartInboxCountProvider).value ?? 0;
    return Row(
      children: [
        Expanded(
          child: MechButton(
            label: 'Expense',
            icon: Icons.add,
            filled: true,
            onTap: () => context.go('/groups'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: MechButton(
            label: 'Settle',
            icon: Icons.sync_alt,
            filled: false,
            onTap: () => context.go('/settle'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: MechButton(
            label: inboxCount > 0 ? 'SMS ($inboxCount)' : 'SMS',
            icon: Icons.bolt_outlined,
            filled: false,
            onTap: () => context.push('/inbox'),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Groups list
// ---------------------------------------------------------------------------

class _GroupsList extends ConsumerWidget {
  const _GroupsList({required this.profileId});

  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupsProvider(profileId));

    return groupsAsync.when(
      loading: () => Column(
        children: List.generate(
            2,
            (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    height: 72,
                    decoration: BoxDecoration(
                      color: UdhamColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                          color: UdhamColors.outlineVariant, width: 0.5),
                    ),
                    child: const Center(
                        child: SkeletonBox(width: null, height: 12)),
                  ),
                )),
      ),
      error: (e, _) => Text(describe(e)),
      data: (groups) {
        final active = groups.where((g) => !g.isArchived).take(3).toList();
        if (active.isEmpty) {
          return EmptyState(
            icon: Icons.groups_outlined,
            title: 'No groups yet',
            message: 'Create or join a group to start sharing expenses.',
            action: MechButton(
              label: 'Join with code',
              icon: Icons.login,
              filled: false,
              onTap: () => showJoinGroupDialog(context, ref, profileId),
            ),
          );
        }
        return Column(
          children: [
            for (final group in active) ...[
              _GroupCard(group: group, profileId: profileId),
              const SizedBox(height: 8),
            ],
          ],
        );
      },
    );
  }
}

class _GroupCard extends ConsumerWidget {
  const _GroupCard({required this.group, required this.profileId});

  final dynamic group;
  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balancesAsync = ref.watch(balancesProvider(group.id));
    final participantsAsync = ref.watch(participantsProvider(group.id));
    final participants = participantsAsync.value ?? [];
    final me = participants.firstWhereOrNull((p) => p.userId == profileId);
    final balances = balancesAsync.value;
    final net = (me != null && balances != null)
        ? (balances.lineFor(me.id)?.netMinor ?? 0)
        : null;
    final memberCount = participants.where((p) => p.isActive).length;

    return GestureDetector(
      onTap: () => context.push('/groups/${group.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: UdhamColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: UdhamColors.outlineVariant, width: 0.5),
        ),
        child: Row(
          children: [
            // Group avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: UdhamColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Center(
                child: Text(
                  group.name.length >= 3
                      ? group.name.substring(0, 3).toUpperCase()
                      : group.name.toUpperCase(),
                  style: GoogleFonts.spaceMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: UdhamColors.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: UdhamColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$memberCount member${memberCount == 1 ? '' : 's'}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: UdhamColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (net != null)
              Text(
                formatSignedMoney(net, group.defaultCurrency),
                style: GoogleFonts.spaceMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: net >= 0 ? UdhamColors.secondary : UdhamColors.error,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recent activity
// ---------------------------------------------------------------------------

class _RecentActivity extends ConsumerWidget {
  const _RecentActivity({required this.profileId});

  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupsProvider(profileId)).value ?? [];
    final activeGroupId = groups.firstWhereOrNull((g) => !g.isArchived)?.id;

    if (activeGroupId == null) {
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No activity yet',
        message: 'Activity from your groups will appear here.',
      );
    }

    final activityAsync = ref.watch(activityProvider(activeGroupId));

    return activityAsync.when(
      loading: () => Column(
        children: List.generate(
            3,
            (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: Container(
                    height: 56,
                    color: UdhamColors.surfaceContainerLowest,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: SkeletonBox(width: double.infinity, height: 10),
                    ),
                  ),
                )),
      ),
      error: (e, _) => Text(describe(e)),
      data: (events) {
        if (events.isEmpty) {
          return const EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No activity yet',
            message: 'Expenses and payments will appear here.',
          );
        }
        final recent = events.take(5).toList();
        return Container(
          decoration: BoxDecoration(
            color: UdhamColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: UdhamColors.outlineVariant, width: 0.5),
          ),
          child: Column(
            children: [
              for (int i = 0; i < recent.length; i++) ...[
                _ActivityRow(event: recent[i]),
                if (i < recent.length - 1)
                  const Divider(height: 0, thickness: 0.5, indent: 48),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.event});

  final ActivityEvent event;

  @override
  Widget build(BuildContext context) {
    final icon = switch (event.entityType) {
      'expense' => Icons.receipt_long_outlined,
      'payment' => Icons.payments_outlined,
      'settlement' => Icons.handshake_outlined,
      _ => Icons.circle_outlined,
    };

    final amountMinor = event.amountMinor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: UdhamColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 15, color: UdhamColors.onSurfaceVariant),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: UdhamColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  formatTimeAgo(event.createdAt),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: UdhamColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (amountMinor != null) ...[
            const SizedBox(width: 8),
            MoneyDisplay(
              text: formatMoney(amountMinor, event.currency),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: UdhamColors.onSurface,
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section label
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.label,
    this.onViewAll,
    this.actionLabel,
    this.onAction,
  });

  final String label;
  final VoidCallback? onViewAll;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TechLabel(label),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (actionLabel != null && onAction != null) ...[
              GestureDetector(
                onTap: onAction,
                child: Text(
                  actionLabel!,
                  style: GoogleFonts.spaceMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: UdhamColors.secondary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
            ],
            if (onViewAll != null)
              GestureDetector(
                onTap: onViewAll,
                child: Row(
                  children: [
                    Text(
                      'View all',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: UdhamColors.secondary,
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        size: 14, color: UdhamColors.secondary),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton
// ---------------------------------------------------------------------------

class _OverviewSkeleton extends StatelessWidget {
  const _OverviewSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        SkeletonBox(width: double.infinity, height: 140),
        SizedBox(height: 16),
        SkeletonBox(width: double.infinity, height: 48),
        SizedBox(height: 20),
        SkeletonBox(width: double.infinity, height: 72),
        SizedBox(height: 8),
        SkeletonBox(width: double.infinity, height: 72),
      ],
    );
  }
}
