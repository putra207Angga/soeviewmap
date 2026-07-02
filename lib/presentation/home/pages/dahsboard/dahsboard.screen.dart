part of '../main.pages.dart';

class DahsboardScreen extends GetView<DahsboardController> {
  const DahsboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0E12) : const Color(0xFFF3F4F6),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dashboard Header
                _buildHeader(context, theme, isDark),
                const SizedBox(height: 16),

                // Metrics grid (takes natural height, wraps rows dynamically)
                const DashboardMetricsGrid(),
                const SizedBox(height: 16),

                // Main Layout
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 950;

                    if (isWide) {
                      // Desktop split layout but fully scrollable on page-level
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left column (Map + VibeMeter)
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(
                                  height: 420,
                                  child: SentimentMapComponent(),
                                ),
                                const SizedBox(height: 16),
                                const VibeMeterComponent(), // Takes its natural height
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Right column (Reviews Feed)
                          const Expanded(
                            flex: 4,
                            child: SizedBox(
                              height: 850,
                              child: ReviewsListComponent(), // Scrolls internally
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Mobile single column layout
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(
                            height: 380,
                            child: SentimentMapComponent(),
                          ),
                          const SizedBox(height: 16),
                          const VibeMeterComponent(), // Takes its natural height
                          const SizedBox(height: 16),
                          const SizedBox(
                            height: 550,
                            child: ReviewsListComponent(), // Scrolls internally
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Review Comment Google Map',
                  style: TextStyle(
                    fontSize: context.width > 600 ? 22 : 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'VIBE CHECK',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Moderasi sentimen ulasan & balas ulasan RS Soebandi dengan AI Assistant.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
        if (context.width > 600)
          ElevatedButton.icon(
            onPressed: () {
              controller.resetFilters();
              Get.snackbar(
                'Filters Cleared',
                'Semua filter ulasan disetel ulang.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            icon: const Icon(Icons.filter_list_off_rounded, size: 16),
            label: const Text(
              'Reset Filter',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF2E3440) : Colors.white,
              foregroundColor: isDark ? Colors.white : theme.colorScheme.primary,
              side: BorderSide(
                color: isDark ? const Color(0xFF3E4450) : Colors.grey.shade300,
                width: 1.2,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          ),
      ],
    );
  }
}
