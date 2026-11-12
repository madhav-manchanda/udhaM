import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/activity/presentation/activity_screen.dart';
import '../../features/analytics/presentation/cashflow_analytics_screen.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/balances/presentation/balances_screen.dart';
import '../../features/budget/presentation/budget_screen.dart';
import '../../features/expenses/presentation/expense_detail_screen.dart';
import '../../features/expenses/presentation/expense_form_screen.dart';
import '../../features/expenses/presentation/personal_expense_form_screen.dart';
import '../../features/groups/presentation/group_overview_screen.dart';
import '../../features/groups/presentation/group_settings_screen.dart';
import '../../features/groups/presentation/group_shell.dart';
import '../../features/groups/presentation/groups_screen.dart';
import '../../features/ledger/presentation/ledger_screen.dart';
import '../../features/members/presentation/members_screen.dart';
import '../../features/overview/presentation/overview_screen.dart';
import '../../features/payments/presentation/payment_detail_screen.dart';
import '../../features/payments/presentation/payment_form_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/settle/presentation/settle_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settlements/presentation/adjustment_form_screen.dart';
import '../../features/settlements/presentation/settlement_form_screen.dart';
import '../../features/smart_inbox/presentation/configured_banks_screen.dart';
import '../../features/smart_inbox/presentation/smart_candidate_screen.dart';
import '../../features/smart_inbox/presentation/smart_inbox_screen.dart';
import '../../shared/app_shell.dart';
import '../providers/providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authRepositoryProvider);
  final refresh = ValueNotifier<int>(0);
  final subscription =
      auth.watchCurrentProfile().listen((_) => refresh.value++);
  ref.onDispose(() {
    subscription.cancel();
    refresh.dispose();
  });

  final router = GoRouter(
    initialLocation: '/groups',
    refreshListenable: refresh,
    redirect: (context, state) {
      final loggedIn = auth.currentProfile != null;
      final onAuth = state.matchedLocation == '/auth';
      if (!loggedIn) {
        return onAuth ? null : '/auth';
      }
      if (onAuth) {
        return '/groups';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      // ─── Main shell with 4-tab bottom dock ───────────────────────────────
      ShellRoute(
        builder: (context, state, child) => AppShell(
          location: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/overview',
            builder: (context, state) => const OverviewScreen(),
          ),
          GoRoute(
            path: '/groups',
            builder: (context, state) => const GroupsScreen(),
          ),
          GoRoute(
            path: '/ledger',
            builder: (context, state) => const LedgerScreen(),
          ),
          GoRoute(
            path: '/settle',
            builder: (context, state) => const SettleScreen(),
          ),
        ],
      ),
      // ─── Group detail shell ───────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) {
          return GroupShell(
            groupId: state.pathParameters['groupId'] ?? '',
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/groups/:groupId',
            builder: (context, state) => GroupOverviewScreen(
              groupId: state.pathParameters['groupId']!,
            ),
          ),
          GoRoute(
            path: '/groups/:groupId/balances',
            builder: (context, state) => BalancesScreen(
              groupId: state.pathParameters['groupId']!,
            ),
          ),
          GoRoute(
            path: '/groups/:groupId/members',
            builder: (context, state) => MembersScreen(
              groupId: state.pathParameters['groupId']!,
            ),
          ),
          GoRoute(
            path: '/groups/:groupId/activity',
            builder: (context, state) => ActivityScreen(
              groupId: state.pathParameters['groupId']!,
            ),
          ),
          GoRoute(
            path: '/groups/:groupId/settings',
            builder: (context, state) => GroupSettingsScreen(
              groupId: state.pathParameters['groupId']!,
            ),
          ),
        ],
      ),
      // ─── Full-screen flows (no shell) ─────────────────────────────────────
      GoRoute(
        path: '/groups/:groupId/expenses/new',
        builder: (context, state) => ExpenseFormScreen(
          groupId: state.pathParameters['groupId']!,
          initial: _asMap(state.extra),
        ),
      ),
      GoRoute(
        path: '/groups/:groupId/expenses/:expenseId/edit',
        builder: (context, state) => ExpenseFormScreen(
          groupId: state.pathParameters['groupId']!,
          expenseId: state.pathParameters['expenseId'],
        ),
      ),
      GoRoute(
        path: '/groups/:groupId/expenses/:expenseId',
        builder: (context, state) => ExpenseDetailScreen(
          groupId: state.pathParameters['groupId']!,
          expenseId: state.pathParameters['expenseId']!,
        ),
      ),
      GoRoute(
        path: '/groups/:groupId/payments/new',
        builder: (context, state) => PaymentFormScreen(
          groupId: state.pathParameters['groupId']!,
          initial: _asMap(state.extra),
        ),
      ),
      GoRoute(
        path: '/groups/:groupId/payments/:paymentId',
        builder: (context, state) => PaymentDetailScreen(
          groupId: state.pathParameters['groupId']!,
          paymentId: state.pathParameters['paymentId']!,
        ),
      ),
      GoRoute(
        path: '/groups/:groupId/settlements/new',
        builder: (context, state) => SettlementFormScreen(
          groupId: state.pathParameters['groupId']!,
          initial: _asMap(state.extra),
        ),
      ),
      GoRoute(
        path: '/groups/:groupId/adjustments/new',
        builder: (context, state) => AdjustmentFormScreen(
          groupId: state.pathParameters['groupId']!,
        ),
      ),
      GoRoute(
        path: '/inbox',
        builder: (context, state) => const SmartInboxScreen(),
      ),
      GoRoute(
        path: '/inbox/banks',
        builder: (context, state) => const ConfiguredBanksScreen(),
      ),
      GoRoute(
        path: '/inbox/:candidateId',
        builder: (context, state) => SmartCandidateScreen(
          candidateId: state.pathParameters['candidateId']!,
        ),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const CashflowAnalyticsScreen(),
      ),
      GoRoute(
        path: '/budget',
        builder: (context, state) => const BudgetScreen(),
      ),
      GoRoute(
        path: '/personal-expense/new',
        builder: (context, state) => const PersonalExpenseFormScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

Map<String, Object?> _asMap(Object? extra) {
  if (extra is Map) {
    return extra.map((key, value) => MapEntry(key.toString(), value));
  }
  return const {};
}
