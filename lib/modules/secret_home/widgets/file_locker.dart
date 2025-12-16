import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../services/encryption_service.dart';

class FileLockerController extends GetxController {
  final RxList<FileSystemEntity> files = <FileSystemEntity>[].obs;
  final ImagePicker _picker = ImagePicker();
  late Directory _secretDir;

  @override
  void onInit() {
    super.onInit();
    _initDir();
  }

  Future<void> _initDir() async {
    final docsDir = await getApplicationDocumentsDirectory();
    _secretDir = Directory(p.join(docsDir.path, 'secret_files'));
    if (!await _secretDir.exists()) {
      await _secretDir.create();
    }
    _loadFiles();
  }

  void _loadFiles() {
    if (_secretDir.existsSync()) {
      files.value = _secretDir
          .listSync()
          .where((e) => e.path.endsWith('.enc'))
          .toList();
    }
  }

  Future<void> addFile() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final bytes = await image.readAsBytes();
    final encrypted = EncryptionService.to.encryptData(bytes);

    final filename = "${DateTime.now().millisecondsSinceEpoch}.enc";
    final file = File(p.join(_secretDir.path, filename));
    await file.writeAsBytes(encrypted);

    _loadFiles();
    Get.snackbar("Success", "File encrypted and hidden!");
  }

  Future<void> openFile(File file) async {
    try {
      final encryptedBytes = await file.readAsBytes();
      final decryptedBytes = EncryptionService.to.decryptData(encryptedBytes);

      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.memory(decryptedBytes),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text("Close"),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to decrypt file: $e",
        backgroundColor: Colors.redAccent,
      );
    }
  }
}

class FileLocker extends StatelessWidget {
  const FileLocker({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject controller here or via binding.
    // For widget usage, putOrFind is okay if unique.
    final controller = Get.put(FileLockerController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Encrypted Files"),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF0F0F0F),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.addFile,
        backgroundColor: Colors.amberAccent,
        child: const Icon(Icons.add_a_photo, color: Colors.black),
      ),
      body: Obx(() {
        if (controller.files.isEmpty) {
          return const Center(
            child: Text(
              "No secure files",
              style: TextStyle(color: Colors.white24),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.files.length,
          itemBuilder: (ctx, i) {
            final file = controller.files[i] as File;
            final name = p.basename(file.path);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: ListTile(
                leading: const Icon(Icons.lock, color: Colors.amberAccent),
                title: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Courier',
                  ),
                ),
                subtitle: const Text(
                  "AES-256 Encrypted",
                  style: TextStyle(color: Colors.white30, fontSize: 10),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    file.deleteSync();
                    controller._loadFiles();
                  },
                ),
                onTap: () => controller.openFile(file),
              ),
            );
          },
        );
      }),
    );
  }
}
