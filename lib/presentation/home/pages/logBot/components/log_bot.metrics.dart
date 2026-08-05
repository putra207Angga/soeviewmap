part of 'main.components.dart';

class LogBotMetricsPanel extends GetView<LogBotController> {
  const LogBotMetricsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final status = controller.botStatus.value;
      final totalLogs = controller.totalLogsCount;

      final botStatusStr = status?.botStatus ?? 'INACTIVE';
      final totalReplied = status?.totalAutoReplied ?? 0;
      final lastChecked = status?.lastCheckedAt;

      String lastCheckedStr = '-';
      if (lastChecked != null) {
        lastCheckedStr = '${lastChecked.hour.toString().padLeft(2, '0')}:${lastChecked.minute.toString().padLeft(2, '0')}:${lastChecked.second.toString().padLeft(2, '0')}';
      }

      return GridView.count(
        crossAxisCount: context.width > 1200
            ? 4
            : (context.width > 800 ? 2 : 1),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: context.width > 1200 ? 2.3 : 2.0,
        children: [
          // 1. Bot Status Card
          _buildMetricCard(
            isDark: isDark,
            title: 'bot_status_title'.tr,
            value: botStatusStr,
            subtitle: 'bot_status_desc'.tr,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: botStatusStr == 'ACTIVE'
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF43F5E),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  botStatusStr == 'ACTIVE' ? 'system_normal'.tr : 'Offline',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: botStatusStr == 'ACTIVE'
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF43F5E),
                  ),
                ),
              ],
            ),
          ),

          // 2. Total Auto Replied
          _buildMetricCard(
            isDark: isDark,
            title: 'total_auto_replied'.tr,
            value: '$totalReplied',
            subtitle: 'total_auto_replied_desc'.tr,
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 14,
                  color: Color(0xFF6366F1),
                ),
                const SizedBox(width: 4),
                Text(
                  'auto_reply_active'.tr,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
          ),

          // 3. Total Logs Card
          _buildMetricCard(
            isDark: isDark,
            title: 'total_logs_title'.tr,
            value: '$totalLogs',
            subtitle: 'total_logs_desc'.tr,
            child: Row(
              children: [
                const Icon(
                  Icons.terminal_rounded,
                  size: 14,
                  color: Colors.blue,
                ),
                const SizedBox(width: 4),
                Text(
                  '${controller.errorCount} ${"errors_detected".tr}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: controller.errorCount > 0 ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ),

          // 4. Last Sync Card
          _buildMetricCard(
            isDark: isDark,
            title: 'last_checked_title'.tr,
            value: lastCheckedStr,
            subtitle: 'last_checked_desc'.tr,
            child: Row(
              children: [
                const Icon(
                  Icons.sync_rounded,
                  size: 14,
                  color: Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  'connected_to_server'.tr,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMetricCard({
    required bool isDark,
    required String title,
    required String value,
    required String subtitle,
    required Widget child,
  }) {
    return GlassContainer(
      glowOpacity: 0.0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        child,
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 9.5,
                        color: Colors.grey.shade500,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}
