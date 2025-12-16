import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../routes/app_pages.dart';
import '../../services/auth_service.dart';

class PublicHomeController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxList<String> games = [
    'Math Puzzle',
    'Sudoku Master',
    'Memory Challenge',
    'Chess Pro',
    'Word Connect',
    '2048 Ultimate',
    'Block Blast',
    'Brain Test',
  ].obs;

  final RxList<String> filteredGames = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    filteredGames.value = games;
  }

  void onSearch(String query) {
    if (query.isEmpty) {
      filteredGames.value = games;
      return;
    }

    // 1. SETUP FLOW
    if (query == AuthService.setupCode && !AuthService.to.isConfigured.value) {
      searchController.clear();
      _showSetupDialog();
      return;
    }

    // 2. UNLOCK FLOW
    if (AuthService.to.verifyPassword(query)) {
      searchController.clear();
      Get.offNamed(Routes.secretHome);
      return;
    }

    // 3. NORMAL SEARCH
    filteredGames.value = games
        .where((game) => game.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void _showSetupDialog() {
    final TextEditingController passCtrl = TextEditingController();
    Get.defaultDialog(
      title: "Set Secret Password",
      content: TextField(
        controller: passCtrl,
        obscureText: true,
        decoration: const InputDecoration(hintText: "Enter new password"),
      ),
      textConfirm: "Save",
      textCancel: "Cancel",
      onConfirm: () async {
        if (passCtrl.text.isNotEmpty) {
          await AuthService.to.setPassword(passCtrl.text);
          Get.back();
          Get.snackbar(
            "Success",
            "Secret mode configured. Remember your password!",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      },
    );
  }
}
