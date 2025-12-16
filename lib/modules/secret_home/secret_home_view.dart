import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'secret_home_controller.dart';
import '../../routes/app_pages.dart';
import 'widgets/secure_browser.dart';
import 'widgets/file_locker.dart';
import '../../theme/app_theme.dart';

class SecretHomeView extends GetView<SecretHomeController> {
  const SecretHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secretBackground,
      appBar: AppBar(
        title: const Text(
          'SECURE VAULT',
          style: TextStyle(
            color: AppColors.secretAccent,
            letterSpacing: 2.0,
            fontFamily: 'Courier',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.power_settings_new,
              color: Color(0xFFEF4444),
            ),
            onPressed: () {
              // Lock and go back
              Get.offAllNamed(Routes.home);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [AppColors.secretSurface, AppColors.secretBackground],
          ),
        ),
        child: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(20),
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _buildSecureOption(
              icon: Icons.public_off, // "Off the grid"
              label: "Private\nBrowser",
              accent: Colors.cyanAccent,
              onTap: () {
                Get.to(() => const SecureBrowser());
              },
            ),
            _buildSecureOption(
              icon: Icons.folder_special,
              label: "Encrypted\nStorage",
              accent: Colors.amberAccent,
              onTap: () {
                Get.to(() => const FileLocker());
              },
            ),
            _buildSecureOption(
              icon: Icons.vpn_key,
              label: "Password\nKeeper",
              accent: Colors.deepPurpleAccent,
              onTap: () {},
            ),
            _buildSecureOption(
              icon: Icons.shield,
              label: "Security\nAudit",
              accent: AppColors.secretAccent,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecureOption({
    required IconData icon,
    required String label,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: accent.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.1),
              ),
              child: Icon(icon, size: 40, color: accent),
            ),
            const SizedBox(height: 15),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: accent, // Neon text
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                fontFamily: 'Courier', // Monospace for hacker feel
              ),
            ),
          ],
        ),
      ),
    );
  }
}
