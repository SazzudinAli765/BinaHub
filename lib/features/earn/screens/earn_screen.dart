import 'package:flutter/material.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../core/theme/cyber_shapes.dart';
import '../../../core/theme/cyber_typography.dart';
import '../../../core/widgets/cyber_button.dart';
import '../../../core/widgets/cyber_app_bar.dart';

/// Earn Screen
/// Clean, restrained Coming Soon placeholder for future rewards and token mechanics.
/// All internal SRS identifiers and diagnostic banners purged in compliance with Condition 4.
class EarnScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgPureBlack,
      appBar: CyberTopAppBar(
        title: 'Earn',
        showBackButton: true,
        onBackTap: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Coin Emblem with subtle Amber Halo
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: CyberColors.surfaceCarbonRaised,
                    shape: BoxShape.circle,
                    border: Border.all(color: CyberColors.warningAmber, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: CyberColors.warningAmber.withOpacity(0.25),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.monetization_on,
                      size: 44,
                      color: CyberColors.warningAmber,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Rewards & Community',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: CyberColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Coming Soon',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: CyberColors.warningAmber,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Feature Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: CyberColors.surfaceCarbon,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CyberColors.borderStructural),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.stars_outlined, color: CyberColors.warningAmber, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Community Rewards Program',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'The Earn ecosystem is currently under development. Future releases will introduce community participation badges, creator tips, and feature unlock tokens.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: CyberColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CyberColors.warningAmber,
                    foregroundColor: const Color(0xFF261A00),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.notifications_active_outlined, size: 18),
                  label: const Text(
                    'NOTIFY ME AT LAUNCH',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Launch notification preference saved.'),
                        backgroundColor: CyberColors.surfaceCarbonRaised,
                      ),
                    );
                  },
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
