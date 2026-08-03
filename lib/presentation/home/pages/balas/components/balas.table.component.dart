part of 'main.components.dart';

class BalasTableComponent extends GetView<BalasController> {
  const BalasTableComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassContainer(
      glowColor: theme.colorScheme.primary,
      glowOpacity: 0.01,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Table Header Actions (Laporan Log Bulanan, Month Dropdown, Export PDF)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Text(
                  'month_report'.tr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Month Picker Selector
                      _buildMonthDropdown(context, theme, isDark),
                      const SizedBox(width: 12),
                      // Export PDF Button
                      _buildExportButton(theme, isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF2E3440) : Colors.grey.shade200,
          ),

          // 2. Scrollable Spreadsheet Table (responsive width based on constraints)
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Stretch to fill card if constraints allow, minimum width 950
                final tableWidth = constraints.maxWidth > 950
                    ? constraints.maxWidth
                    : 950.0;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    child: Column(
                      children: [
                        _buildTableHeaderRow(isDark),
                        Divider(
                          height: 1,
                          color: isDark
                              ? const Color(0xFF2E3440)
                              : Colors.grey.shade200,
                        ),
                        Expanded(
                          child: Obx(() {
                            if (controller.isLoading.value && controller.replyLogs.isEmpty) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final items = controller.filteredReplyLogs;
                            if (items.isEmpty) {
                              return _buildEmptyState(isDark);
                            }
                            return ListView.separated(
                              itemCount: items.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                color: isDark
                                    ? const Color(0xFF2E3440).withOpacity(0.5)
                                    : Colors.grey.shade100,
                              ),
                              itemBuilder: (context, index) {
                                final log = items[index];
                                return _buildLogRow(context, log, isDark, theme);
                              },
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthDropdown(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return Obx(() {
      final months = controller.availableMonths;
      return PopupMenuButton<String>(
        onSelected: (month) => controller.changeMonth(month),
        offset: const Offset(0, 35),
        itemBuilder: (context) => months
            .map(
              (m) => PopupMenuItem(
                value: m,
                child: Text(m, style: const TextStyle(fontSize: 11)),
              ),
            )
            .toList(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E222B) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? const Color(0xFF2E3440) : Colors.grey.shade300,
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 12,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                controller.selectedMonth.value,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 14,
                color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildExportButton(ThemeData theme, bool isDark) {
    return Obx(() {
      final isExporting = controller.isExporting.value;
      return SizedBox(
        height: 30,
        child: ElevatedButton.icon(
          onPressed: isExporting ? null : () => controller.exportPdfReport(),
          icon: isExporting
              ? const SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.download_rounded, size: 12),
          label: Text(
            isExporting ? 'Exporting...' : 'export_pdf'.tr,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? const Color(0xFF1E222B) : Colors.white,
            foregroundColor: isDark ? Colors.white : Colors.grey.shade800,
            side: BorderSide(
              color: isDark ? const Color(0xFF2E3440) : Colors.grey.shade300,
              width: 0.8,
            ),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      );
    });
  }

  Widget _buildTableHeaderRow(bool isDark) {
    final headerStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
      letterSpacing: 0.3,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text('date'.tr, style: headerStyle)),
          SizedBox(
            width: 140,
            child: Text('reviewer'.tr, style: headerStyle),
          ),
          SizedBox(width: 100, child: Text('rating'.tr, style: headerStyle)),
          Expanded(child: Text('nav_review'.tr, style: headerStyle)),
          Expanded(child: Text('nav_balas'.tr, style: headerStyle)),
          SizedBox(
            width: 110,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('status'.tr, style: headerStyle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogRow(
    BuildContext context,
    BalasLogModel item,
    bool isDark,
    ThemeData theme,
  ) {
    return InkWell(
      onTap: () => _openDetailsDialog(context, item),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Tanggal
            SizedBox(
              width: 100,
              child: Text(
                item.date,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                ),
              ),
            ),

            // User Pengguna
            SizedBox(
              width: 140,
              child: InkWell(
                onTap: () => _showUserProfile(context, item),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    item.reviewerName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),

            // Rating
            SizedBox(
              width: 100,
              child: RatingStars(rating: item.rating, size: 12),
            ),

            // Ulasan Pengguna
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  item.reviewText.isEmpty ? '-' : '"${Get.find<HomeController>().censorText(item.reviewText)}"',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? Colors.grey.shade300
                        : Colors.grey.shade800,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Balasan Admin
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Obx(() {
                  final reply = item.adminReply.value;
                  return Text(
                    reply.isEmpty ? 'Belum ditanggapi' : '"$reply"',
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: reply.isEmpty
                          ? FontStyle.normal
                          : FontStyle.italic,
                      color: reply.isEmpty
                          ? Colors.grey.shade500
                          : (isDark
                                ? Colors.grey.shade300
                                : Colors.grey.shade700),
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  );
                }),
              ),
            ),

            // Status Badge
            SizedBox(
              width: 110,
              child: Align(
                alignment: Alignment.centerRight,
                child: Obx(() {
                  final isSent = item.status.value == 'terkirim';
                  return GlowBadge(
                    label: isSent ? 'Terkirim' : 'Pending',
                    color: isSent
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF43F5E),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ada log balasan',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetailsDialog(BuildContext context, BalasLogModel item) {
    showDialog(
      context: context,
      builder: (context) {
        return BalasDetailsDialog(logItem: item, controller: controller);
      },
    );
  }

  void _showUserProfile(BuildContext context, BalasLogModel item) {
    showDialog(
      context: context,
      builder: (context) {
        return UserProfileDialog(logItem: item);
      },
    );
  }
}
