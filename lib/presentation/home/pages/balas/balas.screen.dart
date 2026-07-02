part of '../main.pages.dart';

class BalasScreen extends GetView<BalasController> {
  const BalasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0E12) : const Color(0xFFF3F4F6),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 950;
            final isTallEnough = constraints.maxHeight > 750;

            Widget header = Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pusat Balasan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Track patient engagement and manage automated response workflows.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => controller.fetchReplyLogs(),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      tooltip: 'Segarkan data',
                      style: IconButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.04),
                        padding: const EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: theme.colorScheme.primary.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        Get.snackbar(
                          'Reply Tracking Active',
                          'Bot auto-reply tracking is running and auditing response logs.',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      icon: const Icon(Icons.analytics_outlined, size: 13),
                      label: const Text(
                        'Reply Tracking',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        side: BorderSide(
                          color: theme.colorScheme.primary.withOpacity(0.4),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.04),
                      ),
                    ),
                  ],
                ),
              ],
            );

            if (isWide) {
              // Desktop layout (uses Expanded if viewport height is tall enough, otherwise scrolls)
              Widget content = Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    header,
                    const SizedBox(height: 16),
                    isTallEnough
                        ? const Expanded(child: BalasTableComponent())
                        : const SizedBox(
                            height: 480,
                            child: BalasTableComponent(),
                          ),
                  ],
                ),
              );

              if (!isTallEnough) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: content,
                );
              }
              return content;
            } else {
              // Mobile/tablet scrollable view
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      header,
                      const SizedBox(height: 16),
                      const SizedBox(
                        height: 500,
                        child: BalasTableComponent(),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
