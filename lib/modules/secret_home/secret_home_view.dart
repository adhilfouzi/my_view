import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'secret_home_controller.dart';
import '../../routes/app_pages.dart';
import 'widgets/secure_browser.dart';
import 'widgets/file_locker.dart';

class SecretHomeView extends GetView<SecretHomeController> {
  const SecretHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Secured Vault'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_outline, color: Colors.red),
            onPressed: () {
              // Lock and go back
              Get.offAllNamed(Routes.home);
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        children: [
          _buildOptionCard(
            icon: Icons.public,
            label: "Private Browser",
            color: Colors.blueGrey,
            onTap: () {
              Get.to(() => const SecureBrowser());
            },
          ),
          _buildOptionCard(
            icon: Icons.folder_special,
            label: "Hidden Files",
            color: Colors.brown,
            onTap: () {
              Get.to(() => const FileLocker());
            },
          ),
          _buildOptionCard(
            icon: Icons.vpn_key,
            label: "Credentials",
            color: Colors.amber[900]!,
            onTap: () {},
          ),
          _buildOptionCard(
            icon: Icons.settings,
            label: "Security Settings",
            color: Colors.grey[800]!,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 15),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
