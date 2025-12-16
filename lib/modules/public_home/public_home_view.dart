import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'public_home_controller.dart';
import '../../theme/app_theme.dart';

class PublicHomeView extends GetView<PublicHomeController> {
  const PublicHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Brain Games',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.background, AppColors.surface],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildModernSearchBar(),
              Expanded(
                child: Obx(() {
                  if (controller.filteredGames.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.videogame_asset_off,
                            size: 64,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No games found",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.9,
                        ),
                    itemCount: controller.filteredGames.length,
                    itemBuilder: (context, index) {
                      return _buildGameCard(
                        controller.filteredGames[index],
                        index,
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.1),
        ),
      ),
      child: TextField(
        controller: controller.searchController,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: "Search casual games...",
          hintStyle: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.7),
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.mic_none, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ),
        onSubmitted: controller.onSearch,
      ),
    );
  }

  Widget _buildGameCard(String title, int index) {
    // Dynamic gradients for games
    final List<List<Color>> gradients = [
      [const Color(0xFF6366F1), const Color(0xFF8B5CF6)], // Indigo -> Violet
      [const Color(0xFFEC4899), const Color(0xFFF43F5E)], // Pink -> Rose
      [const Color(0xFF10B981), const Color(0xFF3B82F6)], // Emerald -> Blue
      [const Color(0xFFF59E0B), const Color(0xFFEF4444)], // Amber -> Red
    ];
    final gradient = gradients[index % gradients.length];

    // Icons mapping (simple heuristic for demo)
    IconData icon = Icons.games;
    if (title.contains("Math")) icon = Icons.calculate;
    if (title.contains("Puzzle")) icon = Icons.extension;
    if (title.contains("Chess")) icon = Icons.gradient;
    if (title.contains("Word")) icon = Icons.text_fields;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.snackbar(
              "Start Game",
              "Launching $title...",
              colorText: Colors.white,
              backgroundColor: AppColors.surface.withValues(alpha: 0.9),
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(20),
              borderRadius: 20,
              icon: Icon(Icons.play_circle_fill, color: gradient[1]),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Decorative Circle
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: gradient[0].withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradient),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: gradient[0].withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 28),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Casual",
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
