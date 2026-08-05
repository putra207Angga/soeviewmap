// ignore_for_file: unused_local_variable

part of 'main.components.dart';

class BotConfigPanel extends GetView<TemplateController> {
  const BotConfigPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassContainer(
      glowColor: const Color(0xFF10B981), // Emerald glow
      glowOpacity: 0.01,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row: Title & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.smart_toy_rounded,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'bot_monitoring_title'.tr,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'bot_monitoring_desc'.tr,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(() {
                  final isActive = controller.botActiveStatus.value;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF10B981).withOpacity(0.1)
                          : Colors.grey.shade500.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive
                            ? const Color(0xFF10B981).withOpacity(0.3)
                            : Colors.grey.shade500.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Pulsing Status Dot
                        _StatusIndicatorDot(isActive: isActive),
                        const SizedBox(width: 8),
                        Text(
                          isActive ? 'bot_active'.tr : 'bot_inactive'.tr,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isActive
                                ? const Color(0xFF10B981)
                                : Colors.grey.shade500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 16),
            Divider(
              height: 1,
              color: isDark ? const Color(0xFF2E3440) : Colors.grey.shade200,
            ),
            const SizedBox(height: 16),
            // Config Inputs: Webhook URL & Secret Token
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;

                final statusMessageField = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'status_message_label'.tr,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Obx(
                      () => _buildCopyableField(
                        context,
                        text: controller.botStatusMessage.value,
                        isDark: isDark,
                        theme: theme,
                        label: 'Status Message',
                      ),
                    ),
                  ],
                );

                final lastCheckedField = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'last_checked_time_label'.tr,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Obx(
                      () => _buildCopyableField(
                        context,
                        text: controller.lastCheckedTime.value,
                        isDark: isDark,
                        theme: theme,
                        label: 'Last Checked Time',
                      ),
                    ),
                  ],
                );

                final totalRepliedField = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'total_auto_replies_label'.tr,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Obx(
                      () => _buildCopyableField(
                        context,
                        text: '${controller.totalAutoRepliedCount.value} ${"reviews_count".tr}',
                        isDark: isDark,
                        theme: theme,
                        label: 'Total Auto Replies',
                      ),
                    ),
                  ],
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: statusMessageField),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: lastCheckedField),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: totalRepliedField),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      statusMessageField,
                      const SizedBox(height: 16),
                      lastCheckedField,
                      const SizedBox(height: 16),
                      totalRepliedField,
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildCopyableField(
    BuildContext context, {
    required String text,
    required bool isDark,
    required ThemeData theme,
    required String label,
    bool obscure = false,
  }) {
    final displayText = obscure
        ? '${text.substring(0, 4)}••••••••${text.substring(text.length - 2)}'
        : text;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3440) : Colors.grey.shade200,
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              displayText,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text));
              Get.snackbar(
                'Copied!',
                '$label copied to clipboard.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: isDark
                    ? const Color(0xFF1E222B)
                    : Colors.white.withOpacity(0.95),
                colorText: isDark ? Colors.white : Colors.black,
                borderWidth: 1,
                borderColor: isDark
                    ? const Color(0xFF2E3440)
                    : Colors.grey.shade200,
                duration: const Duration(seconds: 2),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 14),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
            color: theme.colorScheme.primary,
            tooltip: 'Copy $label',
          ),
        ],
      ),
    );
  }
}

class _StatusIndicatorDot extends StatefulWidget {
  final bool isActive;
  const _StatusIndicatorDot({required this.isActive});

  @override
  State<_StatusIndicatorDot> createState() => _StatusIndicatorDotState();
}

class _StatusIndicatorDotState extends State<_StatusIndicatorDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.6,
    ).animate(_animController);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.isActive
        ? const Color(0xFF10B981)
        : Colors.grey.shade400;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: baseColor,
          boxShadow: [
            BoxShadow(
              color: baseColor.withOpacity(0.6),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}
