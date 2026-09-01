part of 'main.components.dart';

class ReviewFiltersPanel extends GetView<ReviewController> {
  const ReviewFiltersPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isWide = context.width > 950;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
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
                'nav_review'.tr,
                style: TextStyle(
                  fontSize: context.width > 600 ? 22 : 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'review_subtitle'.tr,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
          if (!isWide) const SizedBox(height: 16),

          // Right: Status tabs, Time Range Dropdown, Ratings Dropdown
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Status Segmented Capsular Control
              _buildStatusTabs(isDark, theme),

              // Time Range Dropdown
              _buildDropdown(
                value: controller.selectedTimeRange,
                itemMap: {
                  'Last 7 Days': 'last_7_days'.tr,
                  'Last 30 Days': 'last_30_days'.tr,
                  'All Time': 'all_time'.tr,
                },
                isDark: isDark,
                theme: theme,
                onChanged: (val) => controller.filterTimeRange(val),
              ),

              // Ratings Dropdown
              _buildDropdown(
                value: controller.selectedRating,
                itemMap: {
                  'All Ratings': 'all_ratings'.tr,
                  '5 Stars': '5 ${"star_label".tr}',
                  '4 Stars': '4 ${"star_label".tr}',
                  '3 Stars': '3 ${"star_label".tr}',
                  '2 Stars': '2 ${"star_label".tr}',
                  '1 Star': '1 ${"star_label".tr}',
                },
                isDark: isDark,
                theme: theme,
                icon: Icons.star_border_rounded,
                onChanged: (val) => controller.filterRating(val),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTabs(bool isDark, ThemeData theme) {
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
        final current = controller.selectedStatus.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: ['All', 'Pending', 'Replied'].map((status) {
            final isSelected = current == status;
            final label = status == 'All'
                ? 'all_status'.tr
                : (status == 'Pending' ? 'pending_status'.tr : 'replied_status'.tr);

            return GestureDetector(
              onTap: () => controller.filterStatus(status),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
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

  Widget _buildDropdown({
    required RxString value,
    required Map<String, String> itemMap,
    required bool isDark,
    required ThemeData theme,
    required ValueChanged<String> onChanged,
    IconData? icon,
  }) {
    return Obx(() {
      final current = value.value;
      return Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 10),
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
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: current,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            dropdownColor: isDark ? const Color(0xFF1E222B) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            onChanged: (val) {
              if (val != null) onChanged(val);
            },
            items: itemMap.entries.map<DropdownMenuItem<String>>((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.grey.shade300
                            : Colors.grey.shade800,
                      ),
                    ),
                    if (icon != null) ...[
                      const SizedBox(width: 6),
                      Icon(icon, size: 12, color: Colors.amber),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }
}
