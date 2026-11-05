import 'package:flutter/material.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../core/theme/cyber_shapes.dart';
import '../../../core/theme/cyber_typography.dart';
import '../../../core/widgets/cyber_button.dart';
import '../../../core/widgets/cyber_app_bar.dart';

/// Directory Whitelist & Blacklist Manager Screen
/// Configures media scanning paths, folder inclusion, and exclusions.
class DirectoryManagerScreen extends StatefulWidget {
  @override
  _DirectoryManagerScreenState createState() => _DirectoryManagerScreenState();
}

class _DirectoryManagerScreenState extends State<DirectoryManagerScreen> {
  final List<Map<String, dynamic>> _whitelisted = [
    {'path': '/storage/emulated/0/Movies', 'items': 18, 'type': 'video'},
    {'path': '/storage/emulated/0/Download', 'items': 24, 'type': 'all'},
    {'path': '/storage/emulated/0/Music', 'items': 142, 'type': 'audio'},
  ];

  final List<String> _blacklisted = [
    '/storage/emulated/0/Android/data',
    '/storage/emulated/0/WhatsApp/Media',
    '/storage/emulated/0/.thumbnails',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgPureBlack,
      appBar: CyberTopAppBar(
        title: 'Folder Manager',
        showBackButton: true,
        onBackTap: () => Navigator.pop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          // Whitelist section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'INDEXED FOLDERS (WHITELIST)',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: CyberColors.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(
                height: 28,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CyberColors.primaryCyan,
                    side: BorderSide(color: CyberColors.primaryCyan.withOpacity(0.4)),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  icon: const Icon(Icons.create_new_folder_outlined, size: 14),
                  label: const Text('ADD FOLDER', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.w700)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening storage folder picker...'),
                        backgroundColor: CyberColors.surfaceCarbonRaised,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ..._whitelisted.map((folder) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CyberColors.surfaceCarbon,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: CyberColors.borderStructural),
              ),
              child: Row(
                children: [
                  const Icon(Icons.folder_special, color: CyberColors.primaryCyan, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          folder['path'],
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: CyberColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${folder['items']} media files indexed',
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 10,
                            color: CyberColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: CyberColors.textTertiary, size: 20),
                    onPressed: () {
                      setState(() => _whitelisted.remove(folder));
                    },
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 20),

          // Blacklist section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'EXCLUDED FOLDERS (BLACKLIST)',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: CyberColors.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(
                height: 28,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CyberColors.thermalRed,
                    side: BorderSide(color: CyberColors.thermalRed.withOpacity(0.4)),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  icon: const Icon(Icons.folder_off_outlined, size: 14),
                  label: const Text('EXCLUDE', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.w700)),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ..._blacklisted.map((path) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CyberColors.surfaceCarbon,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: CyberColors.borderStructural),
              ),
              child: Row(
                children: [
                  const Icon(Icons.folder_off, color: CyberColors.thermalRed, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      path,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: CyberColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: CyberColors.textTertiary, size: 18),
                    onPressed: () {
                      setState(() => _blacklisted.remove(path));
                    },
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 24),

          // Rescan Trigger Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: CyberColors.primaryCyan,
                foregroundColor: const Color(0xFF002022),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              icon: const Icon(Icons.sync, size: 18),
              label: const Text(
                'RUN FULL STORAGE RESCAN',
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
                    content: Text('Storage scan started: traversing indexed directories...'),
                    backgroundColor: CyberColors.surfaceCarbonRaised,
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
