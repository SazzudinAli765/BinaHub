import 'package:flutter/material.dart';
import '../theme/cyber_colors.dart';
import '../theme/cyber_typography.dart';
import 'cyber_badge.dart';

/// Top App Bar for BinaHub Screens
class CyberTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? hardwareBadge;
  final VoidCallback? onSearchTap;
  final VoidCallback? onFolderTap;
  final VoidCallback? onVaultTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onEarnTap;
  final List<Widget>? customActions;
  final bool showBackButton;
  final VoidCallback? onBackTap;

  const CyberTopAppBar({
    this.title = 'BinaHub',
    this.hardwareBadge,
    this.onSearchTap,
    this.onFolderTap,
    this.onVaultTap,
    this.onProfileTap,
    this.onEarnTap,
    this.customActions,
    this.showBackButton = false,
    this.onBackTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CyberColors.bgPureBlack,
        border: Border(
          bottom: BorderSide(color: CyberColors.borderStructural, width: 1.0),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 56.0,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              if (showBackButton)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: CyberColors.textPrimary, size: 22),
                  onPressed: onBackTap ?? () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                ),
              if (showBackButton) const SizedBox(width: 12),

              // Title and logo
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // BinaHub Brand Play Icon
                  Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(right: 8),
                    child: CustomPaint(
                      painter: _BinaHubLogoPainter(),
                    ),
                  ),
                  Text(
                    title,
                    style: CyberTypography.headlineMedium.copyWith(
                      color: CyberColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (hardwareBadge != null) ...[
                    const SizedBox(width: 8),
                    HardwareTelemetryChip(text: hardwareBadge!),
                  ],
                ],
              ),

              const Spacer(),

              // Action Icons: Search, Folder Manager, Vault, Profile (Stitch Reference)
              if (customActions != null)
                ...customActions!
              else ...[
                if (onSearchTap != null)
                  IconButton(
                    icon: const Icon(Icons.search, color: CyberColors.textSecondary, size: 20),
                    onPressed: onSearchTap,
                    tooltip: 'Search',
                    splashRadius: 18,
                  ),
                if (onFolderTap != null)
                  IconButton(
                    icon: const Icon(Icons.snippet_folder_outlined, color: CyberColors.textSecondary, size: 20),
                    onPressed: onFolderTap,
                    tooltip: 'Folder Manager',
                    splashRadius: 18,
                  ),
                if (onVaultTap != null)
                  IconButton(
                    icon: const Icon(Icons.enhanced_encryption, color: CyberColors.primaryCyan, size: 20),
                    onPressed: onVaultTap,
                    tooltip: 'Secret Vault',
                    splashRadius: 18,
                  ),
                if (onProfileTap != null)
                  IconButton(
                    icon: Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: Color(0xFF151C25),
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(BorderSide(color: CyberColors.borderStructural, width: 1.0)),
                      ),
                      child: const Icon(Icons.person, color: CyberColors.primaryCyan, size: 16),
                    ),
                    onPressed: onProfileTap,
                    tooltip: 'Profile & Mode',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 18,
                  ),
                // Retain onEarnTap for backward compatibility only if explicitly provided and space permits
                if (onEarnTap != null)
                  IconButton(
                    icon: const Icon(Icons.token, color: CyberColors.primaryCyan, size: 18),
                    onPressed: onEarnTap,
                    tooltip: 'Earn (Coming Soon)',
                    splashRadius: 18,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the BinaHub brand triangle logo matching Stitch Frame 1
class _BinaHubLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 24.0;
    final scaleY = size.height / 24.0;

    final outerPath = Path()
      ..moveTo(5.0 * scaleX, 4.5 * scaleY)
      ..lineTo(19.0 * scaleX, 12.0 * scaleY)
      ..lineTo(5.0 * scaleX, 19.5 * scaleY)
      ..close();

    final outerStroke = Paint()
      ..color = CyberColors.primaryCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * scaleX
      ..strokeJoin = StrokeJoin.round;

    final innerPath = Path()
      ..moveTo(9.0 * scaleX, 8.5 * scaleY)
      ..lineTo(15.0 * scaleX, 12.0 * scaleY)
      ..lineTo(9.0 * scaleX, 15.5 * scaleY)
      ..close();

    final innerFill = Paint()
      ..color = CyberColors.primaryCyan.withOpacity(0.35)
      ..style = PaintingStyle.fill;

    final circlePaint = Paint()
      ..color = CyberColors.primaryCyan
      ..style = PaintingStyle.fill;

    canvas.drawPath(innerPath, innerFill);
    canvas.drawPath(outerPath, outerStroke);
    canvas.drawCircle(Offset(15.0 * scaleX, 12.0 * scaleY), 1.5 * scaleX, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

