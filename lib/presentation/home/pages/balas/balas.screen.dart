part of '../main.pages.dart';

class BalasScreen extends GetView<BalasController> {
  const BalasScreen({super.key});

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'pusat_balasan'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'pusat_balasan_subtitle'.tr,
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
              onPressed: () => controller.fetchReplyLogs(showSnackbar: true),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              tooltip: 'refresh_data'.tr,
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
                if (Get.isRegistered<HomeController>()) {
                  Get.find<HomeController>().selectedNavIndex.value = NavMenu.logBot;
                } else {
                  Get.snackbar(
                    'Reply Tracking Active',
                    'Bot auto-reply tracking is running and auditing response logs.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              icon: const Icon(Icons.analytics_outlined, size: 13),
              label: Text(
                'reply_tracking'.tr,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0E12) : const Color(0xFFF3F4F6),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.fetchReplyLogs(showSnackbar: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context, theme),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: context.width > 600 ? 580 : 460,
                    child: const BalasTableComponent(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
