part of 'main.components.dart';

class LogBotConsolePanel extends GetView<LogBotController> {
  const LogBotConsolePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassContainer(
      glowOpacity: 0.0,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Console Header Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E222B)
                  : Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF2E3440) : Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.code_rounded,
                      size: 16,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'audit_log_console'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Obx(() {
                  final count = controller.filteredLogs.length;
                  return Text(
                    '$count ${"events_count".tr}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }),
              ],
            ),
          ),

          // Console Body
          Expanded(
            child: Container(
              color: isDark
                  ? const Color(0xFF0F1115) // Deep slate black console
                  : const Color(0xFFFAF9F6), // Off-white clean console
              child: Obx(() {
                final items = controller.filteredLogs;
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.terminal_rounded,
                          size: 36,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'no_logs_found'.tr,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  physics: const BouncingScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final log = items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Monospace Timestamp
                          Text(
                            _formatTime(log.timestamp),
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Styled Badge
                          _buildLevelBadge(log.level),

                          const SizedBox(width: 8),

                          // Message
                          Expanded(
                            child: Text(
                              log.message,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Courier',
                                color: isDark
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade800,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String isoString) {
    try {
      final dt = DateTime.tryParse(isoString) ?? DateTime.now();
      return '[${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}]';
    } catch (_) {
      return '[--:--:--]';
    }
  }

  Widget _buildLevelBadge(String level) {
    Color color = Colors.blue;
    switch (level.toUpperCase()) {
      case 'SUCCESS':
        color = const Color(0xFF10B981);
        break;
      case 'INFO':
        color = Colors.blue;
        break;
      case 'WARNING':
        color = const Color(0xFFF59E0B);
        break;
      case 'ERROR':
        color = const Color(0xFFF43F5E);
        break;
    }

    final labelMap = {
      'SUCCESS': 'level_success'.tr.toUpperCase(),
      'INFO': 'level_info'.tr.toUpperCase(),
      'WARNING': 'level_warning'.tr.toUpperCase(),
      'ERROR': 'level_error'.tr.toUpperCase(),
    };

    return Container(
      width: 76,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        labelMap[level.toUpperCase()] ?? level.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
