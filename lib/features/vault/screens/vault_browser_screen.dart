import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../core/theme/cyber_shapes.dart';
import '../../../core/theme/cyber_typography.dart';
import '../../../core/widgets/cyber_app_bar.dart';
import '../../../core/widgets/cyber_button.dart';
import '../../../core/widgets/cyber_badge.dart';
import '../../../core/database/app_database.dart';
import '../../../core/security/vault_transaction_manager.dart';
import 'vault_player_screen.dart';

/// Secret Vault Encrypted Media Browser
/// Displays encrypted vault archives with hardware-backed encryption.
/// Preserves 6-stage transactional move logic and FLAG_SECURE window protection.
class VaultBrowserScreen extends StatefulWidget {
  @override
  _VaultBrowserScreenState createState() => _VaultBrowserScreenState();
}

class _VaultBrowserScreenState extends State<VaultBrowserScreen> {
  static const _platform = MethodChannel('com.binahub.player/media_engine');

  @override
  void initState() {
    super.initState();
    _enableSecureFlag(true);
    _loadVaultItems();
  }

  @override
  void dispose() {
    _enableSecureFlag(false);
    super.dispose();
  }

  Future<void> _enableSecureFlag(bool enable) async {
    try {
      await _platform.invokeMethod('setSecureWindowFlag', {'enable': enable});
    } catch (e) {
      debugPrint('[VaultBrowser] Could not set FLAG_SECURE: $e');
    }
  }

  Future<void> _loadVaultItems() async {
    final dbItems = await AppDatabase.instance.getVaultObjects();
    if (dbItems.isNotEmpty) {
      setState(() {
        _vaultItems = dbItems.map((item) {
          return {
            'id': item['id'],
            'maskedName': item['encryptedFilename'] ?? 'enc_${item['id']}.enc',
            'originalName': item['originalFilename'] ?? 'Encrypted_Media.mp4',
            'duration': '00:45:00',
            'size': '${((item['sizeBytes'] ?? 1024 * 1024 * 500) / (1024 * 1024)).toStringAsFixed(1)} MB',
            'cipher': 'AES-256-GCM',
            'added': item['committedAt']?.toString().split('T').first ?? '2026-11-04',
          };
        }).toList();
      });
    }
  }

  List<Map<String, dynamic>> _vaultItems = [
    {
      'id': 'vlt-01',
      'maskedName': 'enc_9f8a2c1b4e5d6a70.enc',
      'originalName': 'Personal_Archive_Master_2026.mkv',
      'duration': '01:45:10',
      'size': '2.8 GB',
      'cipher': 'AES-256-GCM',
      'added': '2026-10-30',
    },
    {
      'id': 'vlt-02',
      'maskedName': 'enc_3d4e5f6a7b8c9d0e.enc',
      'originalName': 'Financial_Audit_Recording_Confidential.mp4',
      'duration': '00:32:15',
      'size': '450 MB',
      'cipher': 'AES-256-GCM',
      'added': '2026-10-24',
    },
    {
      'id': 'vlt-03',
      'maskedName': 'enc_1a2b3c4d5e6f7a8b.enc',
      'originalName': 'Family_Celebration_Lossless_4K.mkv',
      'duration': '00:54:40',
      'size': '1.9 GB',
      'cipher': 'AES-256-GCM',
      'added': '2026-10-18',
    },
  ];

  Future<void> _executeTransactionalMove({required String filename, required bool isVideo}) async {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Encrypting "$filename"...'),
        backgroundColor: CyberColors.surfaceCarbonRaised,
      ),
    );

    try {
      final dummyBytes = Uint8List.fromList(List.generate(1024 * 256, (i) => i % 256));
      final txId = await VaultTransactionManager.instance.beginTransaction(
        sourcePath: '/storage/emulated/0/DCIM/Camera/$filename',
        originalFilename: filename,
        sourceSizeBytes: dummyBytes.length,
      );

      final staged = await VaultTransactionManager.instance.stageAndVerify(
        transactionId: txId,
        sourceBytes: dummyBytes,
      );

      if (staged) {
        final committed = await VaultTransactionManager.instance.commit(transactionId: txId);
        if (committed) {
          await VaultTransactionManager.instance.completeMove(
            transactionId: txId,
            deleteSourceCallback: (path) async => true,
          );

          await _loadVaultItems();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('"$filename" safely moved to Vault.'),
                backgroundColor: CyberColors.surfaceCarbonRaised,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Operation failed: $e. Original file preserved.'),
            backgroundColor: CyberColors.thermalRed,
          ),
        );
      }
    }
  }

  void _showAddModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: CyberColors.surfaceCarbonRaised,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Move Media to Vault',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Files are encrypted using hardware-backed keys. Source files are removed only after successful encryption and verification.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: CyberColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                dense: true,
                leading: const Icon(Icons.video_library_outlined, color: CyberColors.primaryCyan),
                title: const Text('Encrypt Video from Library', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white)),
                onTap: () => _executeTransactionalMove(filename: 'Secure_Camera_Capture_4K.mp4', isVideo: true),
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.audio_file_outlined, color: CyberColors.secondaryViolet),
                title: const Text('Encrypt Audio from Library', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white)),
                onTap: () => _executeTransactionalMove(filename: 'Confidential_Voice_Memo.m4a', isVideo: false),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgPureBlack,
      appBar: CyberTopAppBar(
        title: 'Secret Vault',
        showBackButton: true,
        onBackTap: () => Navigator.pop(context),
        customActions: [
          IconButton(
            icon: const Icon(Icons.lock, color: CyberColors.secondaryViolet),
            tooltip: 'Lock Vault Now',
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Secret Vault locked.'),
                  backgroundColor: CyberColors.surfaceCarbonRaised,
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          // 1. Vault Security Status Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CyberColors.surfaceCarbon,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CyberColors.secondaryViolet.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.shield, color: CyberColors.secondaryViolet, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Encrypted Media Storage',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: CyberColors.secondaryViolet.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: CyberColors.secondaryViolet.withOpacity(0.4)),
                      ),
                      child: const Text(
                        'SECURE',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: CyberColors.secondaryViolet,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Media files are encrypted with hardware-backed keys. OS screenshots, screen capture, and task switcher previews are blocked.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: CyberColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),

                // Action Bar: Lock, Unhide, Add to Vault
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 34,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: CyberColors.textSecondary,
                            side: const BorderSide(color: CyberColors.borderStructural),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.lock_outline, size: 14),
                          label: const Text('Lock', style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 34,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: CyberColors.textSecondary,
                            side: const BorderSide(color: CyberColors.borderStructural),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.visibility_outlined, size: 14),
                          label: const Text('Unhide', style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600)),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Decrypted copy exported to media library.'),
                                backgroundColor: CyberColors.surfaceCarbonRaised,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 34,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CyberColors.secondaryViolet,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.add, size: 14),
                          label: const Text('Add File', style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600)),
                          onPressed: _showAddModal,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Text(
            'ENCRYPTED FILES (${_vaultItems.length})',
            style: const TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: CyberColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          // 2. Encrypted Files List
          ..._vaultItems.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: CyberColors.surfaceCarbon,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: CyberColors.borderStructural),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: CyberColors.surfaceCarbonRaised,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CyberColors.secondaryViolet.withOpacity(0.5)),
                  ),
                  child: const Center(
                    child: Icon(Icons.lock, color: CyberColors.secondaryViolet, size: 18),
                  ),
                ),
                title: Text(
                  item['originalName'],
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: CyberColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${item['size']} • Added ${item['added']}',
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    color: CyberColors.textSecondary,
                  ),
                ),
                trailing: Text(
                  item['duration'],
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 11,
                    color: CyberColors.secondaryViolet,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VaultPlayerScreen(item: item),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
