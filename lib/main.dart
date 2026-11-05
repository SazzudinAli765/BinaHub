import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/cyber_theme.dart';
import 'core/theme/cyber_colors.dart';
import 'core/navigation/main_navigation_shell.dart';
import 'core/database/app_database.dart';
import 'core/security/audit_logger.dart';
import 'core/services/backup_supervisor.dart';
import 'core/services/offline_expiry_manager.dart';
import 'features/audio/screens/audio_library_screen.dart';
import 'features/tools/screens/tools_hub_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/settings/screens/directory_manager_screen.dart';
import 'features/vault/screens/vault_auth_screen.dart';
import 'features/admin/screens/admin_login_screen.dart';
import 'features/earn/screens/earn_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Core Services & Database
  await AppDatabase.instance.initialize();
  await AuditLogger.instance.initialize();
  await BackupSupervisor.instance.initialize();
  OfflineExpiryManager.instance.startSupervisor();

  // Enforce edge-to-edge transparent system navigation and status bars
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: CyberColors.surfaceCarbon,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const BinaHubApp());
}

class BinaHubApp extends StatelessWidget {
  const BinaHubApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BinaHub Standard Video Player',
      debugShowCheckedModeBanner: false,
      theme: CyberTheme.darkTheme,
      home: Builder(
        builder: (context) {
          return MainNavigationShell(
            audioScreen: AudioLibraryScreen(
              onOpenVault: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => VaultAuthScreen()));
              },
              onOpenFolders: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => DirectoryManagerScreen()));
              },
              onOpenProfile: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => AdminLoginScreen()));
              },
              onOpenEarn: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => EarnScreen()));
              },
            ),
            toolsScreen: ToolsHubScreen(
              onOpenVault: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => VaultAuthScreen()));
              },
              onOpenFolders: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => DirectoryManagerScreen()));
              },
              onOpenProfile: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => AdminLoginScreen()));
              },
              onOpenEarn: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => EarnScreen()));
              },
            ),
            settingsScreen: SettingsScreen(
              onOpenAdmin: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => AdminLoginScreen()));
              },
              onOpenEarn: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => EarnScreen()));
              },
            ),
            onOpenVault: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => VaultAuthScreen()));
            },
            onOpenFolders: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => DirectoryManagerScreen()));
            },
            onOpenProfile: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AdminLoginScreen()));
            },
            onOpenEarn: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => EarnScreen()));
            },
          );
        },
      ),
    );
  }
}
