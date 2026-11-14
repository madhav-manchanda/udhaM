import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/providers/providers.dart';
import '../../../shared/widgets/design_system.dart';
import '../domain/user_profile.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final repository = ref.read(authRepositoryProvider);
    repository.authError.addListener(_handleAuthError);
    final existingError = repository.authError.value;
    if (existingError != null && existingError.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showError(context, existingError);
      });
    }
  }

  @override
  void dispose() {
    try {
      ref.read(authRepositoryProvider).authError.removeListener(_handleAuthError);
    } catch (_) {
      // Widget already disposed; ref may no longer be accessible.
    }
    super.dispose();
  }

  void _handleAuthError() {
    final message = ref.read(authRepositoryProvider).authError.value;
    if (message != null && message.isNotEmpty && mounted) {
      showError(context, message);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      final profile = await ref.read(authRepositoryProvider).signInWithGoogle();
      if (profile != null && mounted) {
        showMessage(context, 'Signed in as ${profile.displayName}.');
        context.go('/groups');
      } else if (mounted) {
        showMessage(context, 'Redirecting to Google Sign-In...');
      }
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _handleCustomGoogleSignIn() async {
    final emailCtrl = TextEditingController(text: 'user@gmail.com');
    final nameCtrl = TextEditingController(text: 'Madhav');

    await showModalBottomSheet<void>(
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
                    'GOOGLE ACCOUNT IDENTIFIER',
                    style: GoogleFonts.spaceMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: UdhamColors.onPrimaryContainer,
                      letterSpacing: 0.1,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: UdhamColors.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Enter the Google account credentials to link with this device:',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: UdhamColors.onPrimaryContainer.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: UdhamColors.onPrimaryContainer,
                ),
                decoration: const InputDecoration(
                  labelText: 'Account Display Name',
                  hintText: 'e.g. Madhav',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.spaceMono(
                  fontSize: 14,
                  color: UdhamColors.onPrimaryContainer,
                ),
                decoration: const InputDecoration(
                  labelText: 'Google Email',
                  hintText: 'e.g. you@gmail.com',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: MechButton(
                  label: 'CONFIRM GOOGLE LOGIN',
                  icon: Icons.login,
                  filled: true,
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    setState(() => _busy = true);
                    try {
                      final profile = await ref
                          .read(authRepositoryProvider)
                          .signInWithGoogle(
                            email: emailCtrl.text.trim(),
                            displayName: nameCtrl.text.trim(),
                          );
                      if (profile != null && mounted) {
                        showMessage(
                            context, 'Signed in as ${profile.displayName}.');
                        context.go('/groups');
                      }
                    } catch (error) {
                      if (mounted) showError(context, error);
                    } finally {
                      if (mounted) setState(() => _busy = false);
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

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<UserProfile?>>(currentProfileProvider,
        (previous, next) {
      final profile = next.valueOrNull;
      if (profile != null && mounted) {
        context.go('/groups');
      }
    });
    return Scaffold(
      backgroundColor: UdhamColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              children: [
                const SizedBox(height: 36),

                // Circuit Header Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: UdhamColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(
                            color: UdhamColors.outlineVariant, width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: UdhamColors.secondaryContainer,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'SECURE ENCLAVE // 01',
                            style: GoogleFonts.spaceMono(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.08,
                              color: UdhamColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'v0.1.0',
                      style: GoogleFonts.spaceMono(
                        fontSize: 9,
                        color: UdhamColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Main App Branding (Industrial Logo Plaque)
                Container(
                  width: double.infinity,
                  height: 190,
                  decoration: BoxDecoration(
                    color: const Color(0xFF161718),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: UdhamColors.outlineVariant,
                      width: 0.8,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),

                // Security & Architecture Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: UdhamColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                        color: UdhamColors.outlineVariant, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            size: 18,
                            color: UdhamColors.secondaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ZERO-KNOWLEDGE BANK PRIVACY',
                            style: GoogleFonts.spaceMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: UdhamColors.onSurface,
                              letterSpacing: 0.05,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bank identifiers and SMS parser operate 100% locally on this device. '
                        'Only finalized, user-approved group transactions synchronize with Supabase PostgreSQL.',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          height: 1.45,
                          color: UdhamColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Feature Highlights List
                const _FeatureBullet(
                  icon: Icons.hub_outlined,
                  title: 'Industrial Ledger Engine',
                  description:
                      'Split payments, exact math, and zero debt round-off drift.',
                ),
                const SizedBox(height: 12),
                const _FeatureBullet(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Integrated Budget Controller',
                  description:
                      'Monitor debits and credits across groups and SMS in real-time.',
                ),
                const SizedBox(height: 12),
                const _FeatureBullet(
                  icon: Icons.cloud_sync_outlined,
                  title: 'Offline-First Synchronization',
                  description:
                      'Operate seamlessly offline; auto-reconcile on network reconnect.',
                ),
                const SizedBox(height: 40),

                // Primary Call to Action: Sign in with Google
                GestureDetector(
                  onTap: _busy ? null : _handleGoogleSignIn,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                          color: UdhamColors.outlineVariant, width: 0.8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          offset: Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: _busy
                        ? const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black87,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _GoogleLogoSvg(),
                              const SizedBox(width: 12),
                              Text(
                                'Sign in with Google',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1F1F1F),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                // Option to specify custom Google account (demo / testing)
                Center(
                  child: TextButton.icon(
                    onPressed: _busy ? null : _handleCustomGoogleSignIn,
                    icon: const Icon(Icons.manage_accounts_outlined,
                        size: 14, color: UdhamColors.onSurfaceVariant),
                    label: Text(
                      'Choose specific Google account',
                      style: GoogleFonts.spaceMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: UdhamColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Bottom security disclaimer
                Center(
                  child: Text(
                    'AUTHENTICATION IS RESTRICTED TO GOOGLE OAUTH.\nNO PASSWORDS STORED.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceMono(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                      color:
                          UdhamColors.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  const _FeatureBullet({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: UdhamColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: UdhamColors.outlineVariant, width: 0.5),
          ),
          child: Icon(icon, size: 14, color: UdhamColors.secondaryContainer),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: UdhamColors.onSurface,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: UdhamColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Standalone pure-Flutter custom painter for the Google "G" logo
/// No external asset or dependency required.
class _GoogleLogoSvg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(18, 18),
      painter: _GoogleIconPainter(),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final r = w / 2;

    // Google Brand Colors
    const blue = Color(0xFF4285F4);
    const red = Color(0xFFEA4335);
    const yellow = Color(0xFFFBBC05);
    const green = Color(0xFF34A853);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.22
      ..strokeCap = StrokeCap.butt;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.85);

    // Red arc (top)
    paint.color = red;
    canvas.drawArc(rect, -3.14159 * 0.75, 3.14159 * 0.55, false, paint);

    // Yellow arc (left)
    paint.color = yellow;
    canvas.drawArc(rect, -3.14159 * 1.30, 3.14159 * 0.55, false, paint);

    // Green arc (bottom)
    paint.color = green;
    canvas.drawArc(rect, 3.14159 * 0.25, 3.14159 * 0.50, false, paint);

    // Blue arc (right)
    paint.color = blue;
    canvas.drawArc(rect, -3.14159 * 0.20, 3.14159 * 0.45, false, paint);

    // Blue horizontal bar
    final barPaint = Paint()
      ..color = blue
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(cx - w * 0.05, cy - h * 0.11, w * 0.45, h * 0.22),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
