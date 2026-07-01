part of 'main.components.dart';

class LogBotFiltersPanel extends GetView<LogBotController> {
  const LogBotFiltersPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isWide = context.width > 950;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Flex(
        direction: isWide ? Axis.horizontal : Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: isWide
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          // Left: Screen Title & Subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Log Bot',
                style: TextStyle(
                  fontSize: context.width > 600 ? 28 : 22,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Audit log aktivitas sinkronisasi dan auto-reply ulasan Google Maps',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
          if (!isWide) const SizedBox(height: 16),

          // Right: Log Level Capsular Tabs and Search Bar
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Search Input field
              Container(
                width: 200,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E222B) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2E3440) : Colors.grey.shade200,
                    width: 1.2,
                  ),
                ),
                child: TextField(
                  onChanged: (val) => controller.searchQuery.value = val,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Cari log...',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                    prefixIcon: Icon(Icons.search, size: 16, color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),

              // Level Segmented capsular tabs
              _buildLevelTabs(isDark, theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelTabs(bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E222B) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3440) : Colors.grey.shade200,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        final current = controller.selectedLevel.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: ['All', 'Success', 'Info', 'Warning', 'Error'].map((level) {
            final isSelected = current == level;
            return GestureDetector(
              onTap: () {
                controller.selectedLevel.value = level;
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _getLevelColor(level, theme)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  level,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  Color _getLevelColor(String level, ThemeData theme) {
    switch (level.toUpperCase()) {
      case 'SUCCESS':
        return const Color(0xFF10B981);
      case 'INFO':
        return Colors.blue;
      case 'WARNING':
        return const Color(0xFFF59E0B);
      case 'ERROR':
        return const Color(0xFFF43F5E);
      default:
        return theme.colorScheme.primary;
    }
  }
}
