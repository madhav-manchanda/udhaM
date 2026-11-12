import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/providers/providers.dart';
import '../../../core/utils/id.dart';
import '../../../shared/widgets/design_system.dart';
import '../domain/configured_bank_account.dart';

class ConfiguredBanksScreen extends ConsumerWidget {
  const ConfiguredBanksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(configuredBankAccountsProvider);
    final accounts = accountsAsync.value ?? [];

    return Scaffold(
      backgroundColor: UdhamColors.surface,
      appBar: AppBar(
        backgroundColor: UdhamColors.surface,
        title: Text(
          'CONFIGURED BANK ACCOUNTS',
          style: GoogleFonts.bricolageGrotesque(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: UdhamColors.onSurface,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: UdhamColors.secondaryContainer,
        foregroundColor: UdhamColors.onSecondaryContainer,
        onPressed: () => _showAccountDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Bank Account'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          // Security disclaimer card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: UdhamColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: UdhamColors.outlineVariant, width: 0.5),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 20,
                  color: UdhamColors.secondaryContainer,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Bank identifiers and SMS processing run 100% on-device. '
                    'Raw messages and account numbers are never sent to Supabase.',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: UdhamColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'YOUR BANK ACCOUNTS (${accounts.length})',
              style: GoogleFonts.spaceMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: UdhamColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 8),

          if (accounts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: UdhamColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(2),
                  border:
                      Border.all(color: UdhamColors.outlineVariant, width: 0.5),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.account_balance_outlined,
                      size: 32,
                      color: UdhamColors.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No bank accounts configured',
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: UdhamColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add your bank name, masked account number (e.g. XX1234), and SMS sender IDs to strictly match only your bank messages.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: UdhamColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final preset = ConfiguredBankAccount(
                          id: newId(),
                          bankName: 'HDFC Bank',
                          accountIdentifier: 'XX1234',
                          senderIds: const ['HDFCBK', 'VM-HDFCBK'],
                          createdAt: DateTime.now().toUtc(),
                        );
                        await ref
                            .read(configuredBankRepositoryProvider)
                            .saveAccount(preset);
                      },
                      icon: const Icon(Icons.flash_on, size: 16),
                      label: const Text('Add Example Account (HDFC Bank)'),
                    ),
                  ],
                ),
              ),
            )
          else
            ...accounts.map(
              (acc) => _BankAccountCard(
                account: acc,
                onEdit: () => _showAccountDialog(context, ref, account: acc),
                onDelete: () => _deleteAccount(context, ref, acc.id),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(
      BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await confirmAction(
      context,
      title: 'Delete Bank Account',
      message: 'Remove this bank account configuration?',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    await ref.read(configuredBankRepositoryProvider).deleteAccount(id);
    if (context.mounted) showMessage(context, 'Bank account removed.');
  }

  void _showAccountDialog(
    BuildContext context,
    WidgetRef ref, {
    ConfiguredBankAccount? account,
  }) {
    final bankNameCtrl = TextEditingController(text: account?.bankName ?? '');
    final accIdCtrl =
        TextEditingController(text: account?.accountIdentifier ?? '');
    final senderIdsCtrl = TextEditingController(
      text: account?.senderIds.join(', ') ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: UdhamColors.primaryContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    account == null ? 'ADD BANK ACCOUNT' : 'EDIT BANK ACCOUNT',
                    style: GoogleFonts.spaceMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: UdhamColors.onPrimaryContainer,
                      letterSpacing: 0.1,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: const Icon(Icons.close,
                        color: UdhamColors.onPrimaryContainer, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (account == null) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: UdhamColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                        color: UdhamColors.outlineVariant, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 16, color: UdhamColors.secondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EXAMPLE FORMAT',
                              style: GoogleFonts.spaceMono(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: UdhamColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'HDFC Bank · XX1234 · HDFCBK, VM-HDFCBK',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: UdhamColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          bankNameCtrl.text = 'HDFC Bank';
                          accIdCtrl.text = 'XX1234';
                          senderIdsCtrl.text = 'HDFCBK, VM-HDFCBK';
                        },
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                        ),
                        child: Text(
                          'FILL DUMMY DATA',
                          style: GoogleFonts.spaceMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: UdhamColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Text(
                'BANK NAME',
                style: GoogleFonts.spaceMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: UdhamColors.onPrimaryContainer,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: bankNameCtrl,
                style: GoogleFonts.inter(
                    color: UdhamColors.onSurface, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'e.g. HDFC Bank',
                  hintStyle: GoogleFonts.inter(
                      color: UdhamColors.outline, fontSize: 13),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'MASKED ACCOUNT IDENTIFIER',
                style: GoogleFonts.spaceMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: UdhamColors.onPrimaryContainer,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: accIdCtrl,
                style: GoogleFonts.spaceMono(
                    color: UdhamColors.onSurface, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'e.g. XX1234',
                  hintStyle: GoogleFonts.spaceMono(
                      color: UdhamColors.outline, fontSize: 13),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'SMS SENDER IDS (COMMA SEPARATED)',
                style: GoogleFonts.spaceMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: UdhamColors.onPrimaryContainer,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: senderIdsCtrl,
                style: GoogleFonts.spaceMono(
                    color: UdhamColors.onSurface, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'e.g. HDFCBK, VM-HDFCBK',
                  hintStyle: GoogleFonts.spaceMono(
                      color: UdhamColors.outline, fontSize: 13),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: MechButton(
                  label: account == null
                      ? 'SAVE BANK ACCOUNT'
                      : 'UPDATE BANK ACCOUNT',
                  icon: Icons.check,
                  filled: true,
                  onTap: () async {
                    final bankName = bankNameCtrl.text.trim();
                    final accId = accIdCtrl.text.trim();
                    final senders = senderIdsCtrl.text
                        .split(',')
                        .map((s) => s.trim().toUpperCase())
                        .where((s) => s.isNotEmpty)
                        .toList();

                    if (bankName.isEmpty) {
                      showMessage(ctx, 'Enter bank name');
                      return;
                    }
                    if (accId.isEmpty && senders.isEmpty) {
                      showMessage(
                          ctx, 'Provide account identifier or sender IDs');
                      return;
                    }

                    final updated = ConfiguredBankAccount(
                      id: account?.id ?? newId(),
                      bankName: bankName,
                      accountIdentifier: accId,
                      senderIds: senders,
                      createdAt: account?.createdAt ?? DateTime.now().toUtc(),
                    );

                    await ref
                        .read(configuredBankRepositoryProvider)
                        .saveAccount(updated);

                    if (ctx.mounted) {
                      Navigator.of(ctx).pop();
                      showMessage(context, 'Bank account configuration saved.');
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BankAccountCard extends StatelessWidget {
  const _BankAccountCard({
    required this.account,
    required this.onEdit,
    required this.onDelete,
  });

  final ConfiguredBankAccount account;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: UdhamColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: UdhamColors.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_balance,
                      size: 18,
                      color: UdhamColors.secondaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        account.bankName,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: UdhamColors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: onEdit,
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: UdhamColors.error,
                    onPressed: onDelete,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
          if (account.accountIdentifier.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Account ID: ',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: UdhamColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  account.accountIdentifier,
                  style: GoogleFonts.spaceMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: UdhamColors.onSurface,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: account.senderIds.map((sid) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: UdhamColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  sid,
                  style: GoogleFonts.spaceMono(
                    fontSize: 10,
                    color: UdhamColors.onSurface,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
