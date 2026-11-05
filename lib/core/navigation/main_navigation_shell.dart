import 'package:flutter/material.dart';
import '../theme/cyber_colors.dart';
import '../../features/video/screens/video_library_screen.dart';
import '../../features/tools/screens/tools_hub_screen.dart';
import '../../features/earn/screens/earn_screen.dart';
import '../widgets/docked_mini_player.dart';

/// Main Navigation Shell with 4 Persistent Bottom Tabs (SRS Section 6.1) & Docked Mini-Player
class MainNavigationShell extends StatefulWidget {
  final Widget? audioScreen;
  final Widget? toolsScreen;
  final Widget? settingsScreen;
  final VoidCallback? onOpenVault;
  final VoidCallback? onOpenFolders;
  final VoidCallback? onOpenProfile;
  final VoidCallback? onOpenEarn;

  const MainNavigationShell({
    this.audioScreen,
    this.toolsScreen,
    this.settingsScreen,
    this.onOpenVault,
    this.onOpenFolders,
    this.onOpenProfile,
    this.onOpenEarn,
  });

  @override
  _MainNavigationShellState createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  bool _showMiniPlayer = true;
  bool _isPlayingMini = true;

  void _openEarn(BuildContext context) {
    if (widget.onOpenEarn != null) {
      widget.onOpenEarn!();
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => EarnScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgPureBlack,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          VideoLibraryScreen(
            onOpenVault: widget.onOpenVault,
            onOpenFolders: widget.onOpenFolders,
            onOpenProfile: widget.onOpenProfile,
            onOpenEarn: () => _openEarn(context),
          ),
          widget.audioScreen ?? Container(color: CyberColors.bgPureBlack),
          widget.toolsScreen ??
              ToolsHubScreen(
                onOpenVault: widget.onOpenVault,
                onOpenFolders: widget.onOpenFolders,
                onOpenProfile: widget.onOpenProfile,
                onOpenEarn: () => _openEarn(context),
              ),
          widget.settingsScreen ?? Container(color: CyberColors.bgPureBlack),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Persistent Docked Mini-Player
          if (_showMiniPlayer)
            DockedMiniPlayer(
              title: 'Synthwave_Overdrive_2026_Remaster.flac',
              subtitle: 'Cyberpunk Soundscapes • FLAC 96kHz / 24-bit',
              isPlaying: _isPlayingMini,
              progress: 0.38,
              formatBadge: 'FLAC 96k',
              onPlayPause: () {
                setState(() => _isPlayingMini = !_isPlayingMini);
              },
              onNext: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Switched to Next Track in Queue')),
                );
              },
              onTap: () {
                // Switch to Audio tab (Index 1)
                setState(() => _currentIndex = 1);
              },
              onClose: () {
                setState(() => _showMiniPlayer = false);
              },
            ),

          // Cyber Precision Bottom Navigation Bar (SRS Section 6.1: Video, Audio, Tools, Settings)
          Container(
            decoration: const BoxDecoration(
              color: CyberColors.surfaceCarbon,
              border: Border(
                top: BorderSide(color: CyberColors.borderStructural, width: 1.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xCC000000),
                  offset: Offset(0, -2),
                  blurRadius: 12,
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              backgroundColor: CyberColors.surfaceCarbon,
              selectedItemColor: CyberColors.primaryCyan,
              unselectedItemColor: CyberColors.textSecondary,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              selectedLabelStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.2,
              ),
              onTap: (index) {
                setState(() => _currentIndex = index);
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.movie_outlined, size: 22),
                  activeIcon: Icon(Icons.movie, color: CyberColors.primaryCyan, size: 22),
                  label: 'Video',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.graphic_eq_outlined, size: 22),
                  activeIcon: Icon(Icons.graphic_eq, color: CyberColors.primaryCyan, size: 22),
                  label: 'Audio',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.construction_outlined, size: 22),
                  activeIcon: Icon(Icons.construction, color: CyberColors.primaryCyan, size: 22),
                  label: 'Tools',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.tune_outlined, size: 22),
                  activeIcon: Icon(Icons.tune, color: CyberColors.primaryCyan, size: 22),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
