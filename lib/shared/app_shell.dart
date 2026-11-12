import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/providers/providers.dart';
import '../features/smart_inbox/data/sms_detection_service.dart';
import 'widgets/design_system.dart';

/// The root shell that wraps main app destinations with the
/// Industrial Precision bottom dock and header.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int get _tab {
    if (widget.location.startsWith('/overview')) return 0;
    if (widget.location.startsWith('/groups')) return 1;
    if (widget.location.startsWith('/ledger')) return 2;
    if (widget.location.startsWith('/settle')) return 3;
    return 1; // default to groups
  }

  @override
  void initState() {
    super.initState();
    // Request SMS + notification permissions once after the shell (authenticated
    // screen) is first shown. The context here is inside MaterialApp.router so
    // showModalBottomSheet works correctly.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeRequestPermissions();
    });
  }

  Future<void> _maybeRequestPermissions() async {
    if (!mounted) return;
    final sms = ref.read(smsDetectionServiceProvider);
    final smsGranted = await sms.checkPermissions();
    final notifGranted = await sms.checkNotificationPermission();
    if (smsGranted && notifGranted) return;
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _PermissionSheet(
        smsGranted: smsGranted,
        notifGranted: notifGranted,
        onGrant: () async {
          Navigator.of(ctx).pop();
          if (!smsGranted) await sms.requestPermissions();
          if (!notifGranted) await sms.requestNotificationPermission();
        },
        onSkip: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  static const _destinations = [
    _TabDef('01', Icons.grid_view_outlined, 'OVERVIEW', '/overview'),
    _TabDef('02', Icons.hub_outlined, 'GROUPS', '/groups'),
    _TabDef('03', Icons.receipt_long_outlined, 'LEDGER', '/ledger'),
    _TabDef('04', Icons.tune_outlined, 'SETTLE', '/settle'),
  ];

  void _navigate(int index) {
    HapticFeedback.selectionClick();
    context.go(_destinations[index].route);
  }

  void _openActionPanel() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _ActionPanel(
        onAddExpense: () => _pickExpenseType(ctx),
        onRecordPayment: () => _doAction('/groups'),
        onCreateGroup: () {
          Navigator.pop(context);
          context.go('/groups');
        },
        onSmartInbox: () {
          Navigator.pop(context);
          context.push('/inbox');
        },
      ),
    );
  }

  void _doAction(String route) {
    Navigator.pop(context);
    context.push(route);
  }

  /// Shows a picker: Personal expense (coming soon note) or Group expense
  /// (group selector → navigate to expense form).
  void _pickExpenseType(BuildContext panelCtx) {
    Navigator.pop(context); // close the action panel first
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _ExpenseTypePicker(
        onPersonal: () {
          Navigator.pop(ctx);
          context.push('/personal-expense/new');
        },
        onGroup: () {
          Navigator.pop(ctx);
          _pickGroupForExpense();
        },
      ),
    );
  }

  void _pickGroupForExpense() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _GroupPickerSheet(
        onGroupSelected: (groupId) {
          Navigator.pop(ctx);
          context.push('/groups/$groupId/expenses/new');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inboxCount = ref.watch(smartInboxCountProvider).value ?? 0;
    final tab = _tab;

    return Scaffold(
      backgroundColor: UdhamColors.surface,
      extendBody: true,
      body: widget.child,
      bottomNavigationBar: _BottomDock(
        currentIndex: tab,
        destinations: _destinations,
        inboxCount: inboxCount,
        onTap: _navigate,
        onAction: _openActionPanel,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom dock
// ---------------------------------------------------------------------------

class _BottomDock extends StatelessWidget {
  const _BottomDock({
    required this.currentIndex,
    required this.destinations,
    required this.inboxCount,
    required this.onTap,
    required this.onAction,
  });

  final int currentIndex;
  final List<_TabDef> destinations;
  final int inboxCount;
  final ValueChanged<int> onTap;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      color: UdhamColors.primaryContainer,
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        height: 64,
        decoration: const BoxDecoration(
          color: UdhamColors.primaryContainer,
          border: Border(
            top: BorderSide(color: UdhamColors.onPrimaryContainer, width: 0.3),
          ),
        ),
        child: Row(
          children: [
            // Left two tabs
            for (int i = 0; i < 2; i++)
              Expanded(
                child: _DockTab(
                  def: destinations[i],
                  active: currentIndex == i,
                  badge: i == 0 && inboxCount > 0 ? inboxCount : 0,
                  onTap: () => onTap(i),
                ),
              ),
            // Central orange action button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _CentralButton(onTap: onAction),
            ),
            // Right two tabs
            for (int i = 2; i < 4; i++)
              Expanded(
                child: _DockTab(
                  def: destinations[i],
                  active: currentIndex == i,
                  onTap: () => onTap(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DockTab extends StatelessWidget {
  const _DockTab({
    required this.def,
    required this.active,
    required this.onTap,
    this.badge = 0,
  });

  final _TabDef def;
  final bool active;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final fg = active
        ? UdhamColors.secondaryContainer
        : UdhamColors.onPrimaryContainer;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 64,
        decoration: active
            ? BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                border: const Border(
                  top: BorderSide(
                      color: UdhamColors.secondaryContainer, width: 1.5),
                ),
              )
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              def.number,
              style: GoogleFonts.spaceMono(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.08,
                color: active
                    ? UdhamColors.secondaryContainer.withValues(alpha: 0.7)
                    : UdhamColors.onPrimaryContainer.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 2),
            Badge(
              isLabelVisible: badge > 0,
              label: Text('$badge'),
              backgroundColor: UdhamColors.secondaryContainer,
              textColor: UdhamColors.onSecondaryContainer,
              child: Icon(def.icon, size: 20, color: fg),
            ),
            const SizedBox(height: 2),
            Text(
              def.label,
              style: GoogleFonts.spaceMono(
                fontSize: 8,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                letterSpacing: 0.05,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CentralButton extends StatefulWidget {
  const _CentralButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_CentralButton> createState() => _CentralButtonState();
}

class _CentralButtonState extends State<_CentralButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        width: 48,
        height: 48,
        transform: Matrix4.translationValues(
          _pressed ? 1 : 0,
          _pressed ? 1 : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: UdhamColors.secondaryContainer,
          borderRadius: BorderRadius.circular(2),
          boxShadow: _pressed
              ? []
              : [
                  const BoxShadow(
                    color: Color(0xAA0A0D0B),
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: const Icon(
          Icons.add,
          size: 26,
          color: UdhamColors.onSecondaryContainer,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action panel
// ---------------------------------------------------------------------------

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({
    required this.onAddExpense,
    required this.onRecordPayment,
    required this.onCreateGroup,
    required this.onSmartInbox,
  });

  final VoidCallback onAddExpense;
  final VoidCallback onRecordPayment;
  final VoidCallback onCreateGroup;
  final VoidCallback onSmartInbox;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: UdhamColors.primaryContainer,
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 36,
              height: 3,
              decoration: BoxDecoration(
                color: UdhamColors.onPrimaryContainer,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ACTIONS',
                style: GoogleFonts.spaceMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                  color: UdhamColors.onPrimaryContainer,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close,
                    color: UdhamColors.onPrimaryContainer, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Orange highlight divider
          Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [UdhamColors.secondaryContainer, Colors.transparent],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Actions
          _ActionRow(
            icon: Icons.add_circle_outline,
            label: 'Add Expense',
            sublabel: 'Personal or group cost',
            highlight: true,
            onTap: onAddExpense,
          ),
          _ActionRow(
            icon: Icons.payments_outlined,
            label: 'Record Payment',
            sublabel: 'Log an actual payment made',
            onTap: onRecordPayment,
          ),
          _ActionRow(
            icon: Icons.document_scanner_outlined,
            label: 'Scan Receipt',
            sublabel: 'Attach photo to an expense',
            onTap: () {
              Navigator.pop(context);
              showMessage(context,
                  'Open an expense and use the attachment section to upload a receipt.');
            },
          ),
          _ActionRow(
            icon: Icons.sms_outlined,
            label: 'From SMS',
            sublabel: 'Smart Inbox — review detected transactions',
            onTap: onSmartInbox,
          ),
          _ActionRow(
            icon: Icons.query_stats_outlined,
            label: 'Cashflow Insights',
            sublabel: 'Spending & receipts by week, month, year',
            onTap: () {
              Navigator.pop(context);
              context.push('/analytics');
            },
          ),
          _ActionRow(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Budget Controller',
            sublabel: 'Maintain budget limit vs spent & received',
            onTap: () {
              Navigator.pop(context);
              context.push('/budget');
            },
          ),
          _ActionRow(
            icon: Icons.group_add_outlined,
            label: 'Create Group',
            sublabel: 'Start a new expense circle',
            onTap: onCreateGroup,
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.onTap,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final labelColor = highlight
        ? UdhamColors.secondaryContainer
        : UdhamColors.onPrimaryContainer;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(2),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: labelColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: labelColor,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color:
                          UdhamColors.onPrimaryContainer.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: UdhamColors.onPrimaryContainer.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data classes
// ---------------------------------------------------------------------------

class _TabDef {
  const _TabDef(this.number, this.icon, this.label, this.route);

  final String number;
  final IconData icon;
  final String label;
  final String route;
}

// ---------------------------------------------------------------------------
// Expense Type Picker
// ---------------------------------------------------------------------------

class _ExpenseTypePicker extends StatelessWidget {
  const _ExpenseTypePicker({
    required this.onPersonal,
    required this.onGroup,
  });

  final VoidCallback onPersonal;
  final VoidCallback onGroup;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: UdhamColors.primaryContainer,
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 36,
              height: 3,
              decoration: BoxDecoration(
                color: UdhamColors.onPrimaryContainer,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ADD EXPENSE',
                style: GoogleFonts.spaceMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                  color: UdhamColors.onPrimaryContainer,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close,
                    color: UdhamColors.onPrimaryContainer, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Is this a personal expense or a group expense?',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: UdhamColors.onPrimaryContainer.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _TypeCard(
                  icon: Icons.person_outline,
                  title: 'PERSONAL',
                  subtitle: 'Only for you',
                  onTap: onPersonal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TypeCard(
                  icon: Icons.groups_outlined,
                  title: 'GROUP',
                  subtitle: 'Split with others',
                  highlight: true,
                  onTap: onGroup,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.highlight = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final bg = highlight
        ? UdhamColors.secondaryContainer
        : UdhamColors.surfaceContainerHigh;
    final fg =
        highlight ? UdhamColors.onSecondaryContainer : UdhamColors.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(2),
          boxShadow: const [
            BoxShadow(
                color: Color(0x660A0D0B), offset: Offset(2, 2), blurRadius: 0),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: fg),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.spaceMono(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: fg.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Group picker for expense
// ---------------------------------------------------------------------------

class _GroupPickerSheet extends ConsumerWidget {
  const _GroupPickerSheet({required this.onGroupSelected});

  final ValueChanged<String> onGroupSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider).value;
    final groupsAsync =
        profile == null ? null : ref.watch(groupsProvider(profile.id));
    final groups = groupsAsync?.value ?? [];
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: UdhamColors.primaryContainer,
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 36,
              height: 3,
              decoration: BoxDecoration(
                color: UdhamColors.onPrimaryContainer,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SELECT GROUP',
                style: GoogleFonts.spaceMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                  color: UdhamColors.onPrimaryContainer,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close,
                    color: UdhamColors.onPrimaryContainer, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Which group is this expense for?',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: UdhamColors.onPrimaryContainer.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 14),
          if (groups.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No groups yet. Create or join a group first.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: UdhamColors.onPrimaryContainer.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: groups.length,
                separatorBuilder: (_, __) => Container(
                  height: 0.5,
                  color: UdhamColors.outlineVariant,
                ),
                itemBuilder: (_, i) {
                  final g = groups[i];
                  return InkWell(
                    onTap: () => onGroupSelected(g.id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.hub_outlined,
                              size: 18, color: UdhamColors.onPrimaryContainer),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              g.name,
                              style: GoogleFonts.bricolageGrotesque(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: UdhamColors.onPrimaryContainer,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              size: 18, color: UdhamColors.onPrimaryContainer),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Permission bottom sheet (shown once after first login)
// ---------------------------------------------------------------------------

class _PermissionSheet extends StatelessWidget {
  const _PermissionSheet({
    required this.smsGranted,
    required this.notifGranted,
    required this.onGrant,
    required this.onSkip,
  });

  final bool smsGranted;
  final bool notifGranted;
  final VoidCallback onGrant;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Enable Bank SMS Detection',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'UdhaM needs access to SMS and notifications to automatically detect bank transactions and alert you for review.',
                style: TextStyle(
                  color: Colors.white.withAlpha(178),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              if (!smsGranted) ...[
                const _PermissionRow(
                  icon: Icons.sms_outlined,
                  title: 'SMS Access',
                  description:
                      'Read incoming bank SMS on-device. Raw messages are never uploaded.',
                  color: Color(0xFFFF6B2B),
                ),
                const SizedBox(height: 14),
              ],
              if (!notifGranted) ...[
                const _PermissionRow(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  description:
                      'Show an alert when a transaction is detected so you can review and confirm it.',
                  color: Color(0xFFFF6B2B),
                ),
                const SizedBox(height: 14),
              ],
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onGrant,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B2B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Grant Permissions',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: onSkip,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white54,
                  ),
                  child: const Text('Not now — enable later in Settings'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withAlpha(153),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
