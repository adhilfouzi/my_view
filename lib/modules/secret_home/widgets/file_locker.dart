import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../services/encryption_service.dart';

class FileLockerController extends GetxController {
  final RxList<FileSystemEntity> files = <FileSystemEntity>[].obs;
  final RxBool isGridView = false.obs;
  final RxString activeFilter = 'All'.obs; // All, Images, Videos

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
      files.value =
          _secretDir.listSync().where((e) => e.path.endsWith('.enc')).toList()
            ..sort(
              (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
            );
    }
  }

  List<FileSystemEntity> get filteredFiles {
    if (activeFilter.value == 'All') return files;
    return files.where((file) {
      final name = p.basename(file.path).toLowerCase();
      if (activeFilter.value == 'Images') {
        return name.contains('.jpg') ||
            name.contains('.png') ||
            name.contains('.gif') ||
            name.contains('.jpeg');
      } else if (activeFilter.value == 'Videos') {
        return name.contains('.mp4') ||
            name.contains('.webm') ||
            name.contains('.mov');
      }
      return false;
    }).toList();
  }

  Future<void> addFile() async {
    final XFile? media = await _picker
        .pickMedia(); // Changed to pickMedia for videos too
    if (media == null) return;

    final bytes = await media.readAsBytes();
    final encrypted = EncryptionService.to.encryptData(bytes);

    final ext = p.extension(media.path);
    final filename = "${DateTime.now().millisecondsSinceEpoch}$ext.enc";
    final file = File(p.join(_secretDir.path, filename));
    await file.writeAsBytes(encrypted);

    _loadFiles();
    Get.snackbar("Success", "Media encrypted and hidden!");
  }

  Future<void> openFile(File file) async {
    try {
      final name = p.basename(file.path).toLowerCase();
      final isVideo =
          name.contains('.mp4') ||
          name.contains('.webm') ||
          name.contains('.mov');

      final encryptedBytes = await file.readAsBytes();
      final decryptedBytes = EncryptionService.to.decryptData(encryptedBytes);

      if (isVideo) {
        Get.snackbar(
          "Info",
          "In-app video player coming soon.\nFile is secure.",
        );
        // TODO: Implement video player with decrypted bytes or temp file
        return;
      }

      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: InteractiveViewer(child: Image.memory(decryptedBytes)),
              ),
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
        actions: [
          IconButton(
            icon: Obx(
              () => Icon(
                controller.isGridView.value ? Icons.view_list : Icons.grid_view,
                color: Colors.cyanAccent,
              ),
            ),
            onPressed: () => controller.isGridView.toggle(),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF0F0F0F),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.addFile,
        backgroundColor: Colors.cyanAccent,
        child: const Icon(Icons.add_a_photo, color: Colors.black),
      ),
      body: Column(
        children: [
          // FILTER BAR
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.black,
            child: Row(
              children: [
                _buildFilterChip(controller, 'All'),
                const SizedBox(width: 8),
                _buildFilterChip(controller, 'Images'),
                const SizedBox(width: 8),
                _buildFilterChip(controller, 'Videos'),
              ],
            ),
          ),

          // CONTENT
          Expanded(
            child: Obx(() {
              final files = controller.filteredFiles;
              if (files.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.folder_off,
                        size: 48,
                        color: Colors.white10,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No ${controller.activeFilter.value.toLowerCase()} found",
                        style: const TextStyle(color: Colors.white24),
                      ),
                    ],
                  ),
                );
              }

              if (controller.isGridView.value) {
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: files.length,
                  itemBuilder: (ctx, i) {
                    final file = files[i] as File;
                    final name = p.basename(file.path);
                    return GestureDetector(
                      onTap: () => controller.openFile(file),
                      onLongPress: () {
                        // Optional: Show details or delete on long press in grid
                        _showDeleteDialog(context, controller, file);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.lock,
                              color: Colors.cyanAccent,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Text(
                                name.length > 8
                                    ? "${name.substring(0, 5)}...${p.extension(name)}"
                                    : name,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontFamily: 'Courier',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: files.length,
                  itemBuilder: (ctx, i) {
                    final file = files[i] as File;
                    final name = p.basename(file.path);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.lock,
                          color: Colors.cyanAccent,
                        ),
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
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () =>
                              _showDeleteDialog(context, controller, file),
                        ),
                        onTap: () => controller.openFile(file),
                      ),
                    );
                  },
                );
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(FileLockerController controller, String label) {
    return Obx(() {
      final isSelected = controller.activeFilter.value == label;
      return GestureDetector(
        onTap: () => controller.activeFilter.value = label,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.cyanAccent.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.cyanAccent : Colors.white24,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.cyanAccent : Colors.white54,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      );
    });
  }

  void _showDeleteDialog(
    BuildContext context,
    FileLockerController controller,
    File file,
  ) {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF222222),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Delete File?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                p.basename(file.path),
                style: const TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    onPressed: () {
                      file.deleteSync();
                      controller._loadFiles();
                      Get.back();
                    },
                    child: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
