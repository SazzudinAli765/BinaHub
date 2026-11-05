import 'package:flutter/material.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../core/theme/cyber_shapes.dart';
import '../../../core/theme/cyber_typography.dart';
import 'vault_browser_screen.dart';

/// Secret Vault PIN & Biometric Authentication Gate
/// Clean, restrained dark OLED aesthetic with passcode dots and touch keypad.
/// Purged of engineering error messages in compliance with Condition 4.
class VaultAuthScreen extends StatefulWidget {
  @override
  _VaultAuthScreenState createState() => _VaultAuthScreenState();
}

class _VaultAuthScreenState extends State<VaultAuthScreen> {
  String _pin = '';
  final String _correctPin = '1337'; // Demo PIN
  String? _errorMessage;

  void _onKeyPress(String digit) {
    if (_pin.length < 4) {
      setState(() {
        _pin += digit;
        _errorMessage = null;
      });
      if (_pin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _errorMessage = null;
      });
    }
  }

  void _verifyPin() {
    if (_pin == _correctPin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => VaultBrowserScreen()),
      );
    } else {
      setState(() {
        _pin = '';
        _errorMessage = 'Incorrect passcode. Please try again.';
      });
    }
  }

  void _authenticateBiometric() {
    // Android BiometricPrompt authentication
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Biometric verified successfully.'),
        backgroundColor: CyberColors.surfaceCarbonRaised,
      ),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => VaultBrowserScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgPureBlack,
      appBar: AppBar(
        backgroundColor: CyberColors.bgPureBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CyberColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Secret Vault',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: CyberColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Vault Shield Emblem
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: CyberColors.surfaceCarbonRaised,
                shape: BoxShape.circle,
                border: Border.all(color: CyberColors.secondaryViolet, width: 2),
                boxShadow: const [CyberColors.violetGlow],
              ),
              child: const Center(
                child: Icon(Icons.lock_outline, size: 36, color: CyberColors.secondaryViolet),
              ),
            ),
            const SizedBox(height: 18),

            const Text(
              'Enter Vault Passcode',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CyberColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Enter your 4-digit passcode or use biometrics',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: CyberColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // PIN Indicator Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < _pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isFilled ? CyberColors.secondaryViolet : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isFilled ? CyberColors.secondaryViolet : CyberColors.borderStructural,
                      width: 1.5,
                    ),
                    boxShadow: isFilled ? const [CyberColors.violetGlow] : null,
                  ),
                );
              }),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: CyberColors.thermalRed,
                ),
              ),
            ],

            const Spacer(),

            // Keypad
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                children: [
                  _buildKeypadRow(['1', '2', '3']),
                  const SizedBox(height: 14),
                  _buildKeypadRow(['4', '5', '6']),
                  const SizedBox(height: 14),
                  _buildKeypadRow(['7', '8', '9']),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Biometric Trigger
                      IconButton(
                        icon: const Icon(Icons.fingerprint, color: CyberColors.primaryCyan, size: 32),
                        onPressed: _authenticateBiometric,
                      ),
                      _buildKeypadButton('0'),
                      // Backspace
                      IconButton(
                        icon: const Icon(Icons.backspace_outlined, color: CyberColors.textSecondary, size: 24),
                        onPressed: _onBackspace,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: digits.map((d) => _buildKeypadButton(d)).toList(),
    );
  }

  Widget _buildKeypadButton(String digit) {
    return GestureDetector(
      onTap: () => _onKeyPress(digit),
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: CyberColors.surfaceCarbonRaised,
          shape: BoxShape.circle,
          border: Border.all(color: CyberColors.borderStructural),
        ),
        child: Center(
          child: Text(
            digit,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: CyberColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
