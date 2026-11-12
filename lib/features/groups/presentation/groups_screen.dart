import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/providers/providers.dart';
import '../../../shared/format.dart';
import '../../../shared/widgets/design_system.dart';
import 'join_group_dialog.dart';

class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({super.key});

  @override
  ConsumerState<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends ConsumerState<GroupsScreen> {
  String _filter = 'all'; // all, owed, owe, settled
  final _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncCoordinatorProvider).syncNow();
    });
    _syncTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) {
        ref.read(syncCoordinatorProvider).syncNow();
      }
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider).value;
    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final groupsAsync = ref.watch(groupsProvider(profile.id));

    return Scaffold(
      backgroundColor: UdhamColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _GroupsHeader(
              onProfile: () => context.push('/profile'),
              onCreateGroup: () => _showCreateGroup(context, ref, profile.id),
              onJoinGroup: () => _showJoinGroup(context, ref, profile.id),
            ),
            Expanded(
              child: groupsAsync.when(
                loading: () => const _GroupsSkeleton(),
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
                data: (groups) => _GroupsBody(
                  groups: groups,
                  profileId: profile.id,
                  filter: _filter,
                  searchQuery: _searchQuery,
                  searchController: _searchController,
                  onFilterChanged: (f) => setState(() => _filter = f),
                  onSearchChanged: (q) => setState(() => _searchQuery = q),
                  onCreateGroup: () =>
                      _showCreateGroup(context, ref, profile.id),
                  onJoinGroup: () => _showJoinGroup(context, ref, profile.id),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateGroup(
      BuildContext context, WidgetRef ref, String profileId) async {
    final name = TextEditingController();
    final description = TextEditingController();
    var currency = 'INR';
    var busy = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          Future<void> submit() async {
            if (busy || name.text.trim().isEmpty) return;
            setState(() => busy = true);
            try {
              final group = await ref.read(groupRepositoryProvider).createGroup(
                    actorProfileId: profileId,
                    name: name.text.trim(),
                    description: description.text.trim().isNotEmpty
                        ? description.text.trim()
                        : null,
                    currency: currency,
                  );
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
                context.push('/groups/${group.id}');
              }
            } catch (error) {
              if (dialogContext.mounted) showError(dialogContext, error);
            } finally {
              if (dialogContext.mounted) setState(() => busy = false);
            }
          }

          return AlertDialog(
            title: Text(
              'Create group',
              style:
                  GoogleFonts.bricolageGrotesque(fontWeight: FontWeight.w700),
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: name,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Group name'),
                    onSubmitted: (_) => submit(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: description,
                    maxLines: 2,
                    decoration: const InputDecoration(
                        labelText: 'Description (optional)'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: currency,
                    decoration: const InputDecoration(labelText: 'Currency'),
                    items: const [
                      DropdownMenuItem(value: 'INR', child: Text('INR — ₹')),
                      DropdownMenuItem(value: 'USD', child: Text('USD — \$')),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR — €')),
                      DropdownMenuItem(value: 'GBP', child: Text('GBP — £')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => currency = v);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                    busy ? null : () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: busy ? null : submit,
                child: busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Create'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showJoinGroup(
      BuildContext context, WidgetRef ref, String profileId) async {
    await showJoinGroupDialog(context, ref, profileId);
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _GroupsHeader extends StatelessWidget {
  const _GroupsHeader({
    required this.onProfile,
    required this.onCreateGroup,
    required this.onJoinGroup,
  });

  final VoidCallback onProfile;
  final VoidCallback onCreateGroup;
  final VoidCallback onJoinGroup;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: UdhamColors.surface,
        border: Border(
            bottom: BorderSide(color: UdhamColors.outlineVariant, width: 0.5)),
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
            'Groups',
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: UdhamColors.onSurface,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onJoinGroup,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: UdhamColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: UdhamColors.outlineVariant),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.group_add,
                      size: 14, color: UdhamColors.onSurface),
                  const SizedBox(width: 4),
                  Text(
                    'JOIN',
                    style: GoogleFonts.spaceMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: UdhamColors.onSurface,
                      letterSpacing: 0.08,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onCreateGroup,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: UdhamColors.secondaryContainer,
                borderRadius: BorderRadius.circular(2),
                boxShadow: const [
                  BoxShadow(color: Color(0x660A0D0B), offset: Offset(2, 2)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add,
                      size: 14, color: UdhamColors.onSecondaryContainer),
                  const SizedBox(width: 4),
                  Text(
                    'NEW GROUP',
                    style: GoogleFonts.spaceMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: UdhamColors.onSecondaryContainer,
                      letterSpacing: 0.08,
                    ),
                  ),
                ],
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

class _GroupsBody extends ConsumerWidget {
  const _GroupsBody({
    required this.groups,
    required this.profileId,
    required this.filter,
    required this.searchQuery,
    required this.searchController,
    required this.onFilterChanged,
    required this.onSearchChanged,
    required this.onCreateGroup,
    required this.onJoinGroup,
  });

  final List groups;
  final String profileId;
  final String filter;
  final String searchQuery;
  final TextEditingController searchController;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onCreateGroup;
  final VoidCallback onJoinGroup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (groups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.groups_outlined,
                  size: 48, color: UdhamColors.outline),
              const SizedBox(height: 16),
              Text(
                'No groups yet',
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: UdhamColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Create a new group or join an existing group with an invite code.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: UdhamColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  MechButton(
                    label: 'Create group',
                    icon: Icons.add,
                    onTap: onCreateGroup,
                  ),
                  MechButton(
                    label: 'Join with code',
                    icon: Icons.login,
                    filled: false,
                    onTap: onJoinGroup,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(syncCoordinatorProvider).syncNow(),
      color: UdhamColors.secondary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 112),
        children: [
          // Search + filter
          _SearchBar(controller: searchController, onChanged: onSearchChanged),
          const SizedBox(height: 10),

          // Aggregate metrics banner
          _MetricsBanner(profileId: profileId, groups: groups),
          const SizedBox(height: 10),

          // Filter pills
          _FilterPills(
              current: filter,
              onChanged: onFilterChanged,
              groups: groups,
              profileId: profileId),
          const SizedBox(height: 12),

          // Group cards
          ..._filteredGroups(groups, filter, searchQuery, profileId, ref).map(
            (g) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _GroupCard(group: g, profileId: profileId),
            ),
          ),

          // Join via code
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onJoinGroup,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: UdhamColors.outlineVariant),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.login,
                      size: 16, color: UdhamColors.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    'Join with invite code',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: UdhamColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List _filteredGroups(
    List groups,
    String filter,
    String query,
    String profileId,
    WidgetRef ref,
  ) {
    var list = groups.toList();

    if (query.isNotEmpty) {
      list = list
          .where((g) => g.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    // Filter by balance direction (requires reading balances — do it at card level for perf)
    return list;
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: UdhamColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: UdhamColors.outlineVariant, width: 0.5),
        boxShadow: const [
          BoxShadow(
              color: Color(0x14202321), offset: Offset(2, 2), blurRadius: 0),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          const Icon(Icons.search, size: 18, color: UdhamColors.outline),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style:
                  GoogleFonts.inter(fontSize: 13, color: UdhamColors.onSurface),
              decoration: InputDecoration(
                hintText: 'Filter groups...',
                hintStyle:
                    GoogleFonts.inter(fontSize: 13, color: UdhamColors.outline),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onChanged('');
              },
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.close, size: 16, color: UdhamColors.outline),
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricsBanner extends ConsumerWidget {
  const _MetricsBanner({required this.profileId, required this.groups});

  final String profileId;
  final List groups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int totalOwed = 0;
    int totalOwe = 0;

    for (final group in groups) {
      final balances = ref.watch(balancesProvider(group.id)).value;
      final participants =
          ref.watch(participantsProvider(group.id)).value ?? [];
      final me = participants.cast<dynamic>().firstWhere(
            (p) => p.userId == profileId,
            orElse: () => null,
          );
      if (me != null && balances != null) {
        final net = balances.lineFor(me.id)?.netMinor ?? 0;
        if (net > 0) totalOwed += net;
        if (net < 0) totalOwe += net.abs();
      }
    }

    final netMinor = totalOwed - totalOwe;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: UdhamColors.primaryContainer,
        borderRadius: BorderRadius.circular(2),
        boxShadow: const [
          BoxShadow(color: Color(0x660A0D0B), offset: Offset(3, 3)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'CIRCUIT METRICS // 02',
                style: GoogleFonts.spaceMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                  color: UdhamColors.onPrimaryContainer,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: UdhamColors.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'LIVE',
                    style: GoogleFonts.spaceMono(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: UdhamColors.secondaryFixedDim,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACTIVE POOLS',
                        style: GoogleFonts.spaceMono(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.08,
                          color: UdhamColors.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            groups.length.toString().padLeft(2, '0'),
                            style: GoogleFonts.spaceMono(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: UdhamColors.inverseOnSurface,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'GROUPS',
                            style: GoogleFonts.spaceMono(
                              fontSize: 9,
                              color: UdhamColors.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OVERALL NET',
                        style: GoogleFonts.spaceMono(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.08,
                          color: UdhamColors.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        netMinor >= 0 ? 'Owed to you' : 'You owe',
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: UdhamColors.inverseOnSurface,
                        ),
                      ),
                      Text(
                        formatMoney(netMinor.abs(), 'INR'),
                        style: GoogleFonts.spaceMono(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: netMinor >= 0
                              ? UdhamColors.secondaryFixed
                              : UdhamColors.errorContainer,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterPills extends ConsumerWidget {
  const _FilterPills({
    required this.current,
    required this.onChanged,
    required this.groups,
    required this.profileId,
  });

  final String current;
  final ValueChanged<String> onChanged;
  final List groups;
  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = [
      ('all', 'ALL (${groups.length})'),
      ('owed', 'YOU ARE OWED'),
      ('owe', 'YOU OWE'),
      ('settled', 'SETTLED'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final active = current == f.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => onChanged(f.$1),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: active
                      ? UdhamColors.primary
                      : UdhamColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: active
                      ? const [
                          BoxShadow(
                              color: Color(0x440A0D0B), offset: Offset(1, 1))
                        ]
                      : null,
                ),
                child: Text(
                  f.$2,
                  style: GoogleFonts.spaceMono(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.08,
                    color:
                        active ? UdhamColors.onPrimary : UdhamColors.onSurface,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _GroupCard extends ConsumerWidget {
  const _GroupCard({required this.group, required this.profileId});

  final dynamic group;
  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participants = ref.watch(participantsProvider(group.id)).value ?? [];
    final balances = ref.watch(balancesProvider(group.id)).value;
    final me = participants.cast<dynamic>().firstWhere(
          (p) => p.userId == profileId,
          orElse: () => null,
        );
    final net = (me != null && balances != null)
        ? (balances.lineFor(me.id)?.netMinor ?? 0)
        : null;
    final memberCount = participants.where((p) => p.isActive).length;

    final balanceLabel = net == null
        ? '—'
        : net > 0
            ? 'YOU ARE OWED'
            : net < 0
                ? 'YOU OWE'
                : 'SETTLED';
    final balanceColor = net == null || net == 0
        ? UdhamColors.onSurfaceVariant
        : net > 0
            ? UdhamColors.secondary
            : UdhamColors.error;

    return GestureDetector(
      onTap: () => context.push('/groups/${group.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: UdhamColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: UdhamColors.outlineVariant, width: 0.5),
          boxShadow: const [
            BoxShadow(
                color: Color(0x140A0D0B), offset: Offset(2, 2), blurRadius: 0),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '#GRP-${group.id.substring(0, 6).toUpperCase()}',
                            style: GoogleFonts.spaceMono(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: UdhamColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (group.isArchived)
                            UdhamChip(
                              label: 'ARCHIVED',
                              color: Colors.orange,
                              textColor: Colors.orange.shade800,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        group.name,
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: UdhamColors.onSurface,
                        ),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          balanceLabel,
                          style: GoogleFonts.spaceMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: balanceColor,
                            letterSpacing: 0.08,
                          ),
                        ),
                        const SizedBox(width: 2),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          iconSize: 18,
                          splashRadius: 18,
                          icon: const Icon(Icons.more_vert,
                              size: 18, color: UdhamColors.outline),
                          onSelected: (value) async {
                            if (value == 'copy_code') {
                              final code =
                                  '#GRP-${group.id.substring(0, 6).toUpperCase()}';
                              await Clipboard.setData(ClipboardData(text: code));
                              if (context.mounted) {
                                showMessage(
                                    context, 'Invite code $code copied!');
                              }
                            } else if (value == 'delete') {
                              final confirmed = await confirmAction(
                                context,
                                title: 'Delete group',
                                message:
                                    'Permanently delete "${group.name}" from Supabase and this device?',
                                confirmLabel: 'Delete',
                                destructive: true,
                              );
                              if (confirmed && context.mounted) {
                                try {
                                  await ref
                                      .read(groupRepositoryProvider)
                                      .deleteGroup(
                                        actorProfileId: profileId,
                                        groupId: group.id,
                                      );
                                  if (context.mounted) {
                                    showMessage(context, 'Group deleted.');
                                  }
                                } catch (e) {
                                  if (context.mounted) showError(context, e);
                                }
                              }
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'copy_code',
                              child: Row(
                                children: [
                                  Icon(Icons.copy, size: 16),
                                  SizedBox(width: 8),
                                  Text('Copy Invite Code'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline,
                                      size: 16, color: UdhamColors.error),
                                  SizedBox(width: 8),
                                  Text(
                                    'Delete Group',
                                    style: TextStyle(color: UdhamColors.error),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    if (net != null)
                      Text(
                        '${net >= 0 ? '+' : ''}${formatMoney(net, group.defaultCurrency)}',
                        style: GoogleFonts.spaceMono(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: balanceColor,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Member avatars row
            Row(
              children: [
                ...participants.take(4).map((p) => Align(
                      widthFactor: 0.75,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: UdhamColors.surfaceContainerLow,
                              width: 1.5),
                        ),
                        child:
                            ParticipantAvatar(name: p.displayName, radius: 12),
                      ),
                    )),
                if (participants.length > 4) ...[
                  const SizedBox(width: 10),
                  Text(
                    '+${participants.length - 4} more',
                    style: GoogleFonts.spaceMono(
                      fontSize: 9,
                      color: UdhamColors.onSurfaceVariant,
                    ),
                  ),
                ],
                const Spacer(),
                const Icon(Icons.chevron_right,
                    size: 16, color: UdhamColors.outline),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupsSkeleton extends StatelessWidget {
  const _GroupsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        SkeletonBox(width: double.infinity, height: 40),
        SizedBox(height: 10),
        SkeletonBox(width: double.infinity, height: 120),
        SizedBox(height: 10),
        SkeletonBox(width: double.infinity, height: 32),
        SizedBox(height: 12),
        SkeletonBox(width: double.infinity, height: 110),
        SizedBox(height: 12),
        SkeletonBox(width: double.infinity, height: 110),
      ],
    );
  }
}
