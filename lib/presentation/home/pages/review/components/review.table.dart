part of 'main.components.dart';

class ReviewTableComponent extends GetView<ReviewController> {
  const ReviewTableComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassContainer(
      glowColor: const Color(0xFF6366F1), // Indigo glow
      glowOpacity: 0.01,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Table Header & Content (with horizontal scrolling on small viewports)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width:
                    900, // Fixed width inside scrollable view to keep table columns proportional
                child: Column(
                  children: [
                    // Table Header Row
                    _buildTableHeaderRow(isDark),
                    Divider(
                      height: 1,
                      color: isDark
                          ? const Color(0xFF2E3440)
                          : Colors.grey.shade200,
                    ),

                    // Table Rows
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return _buildLoadingState(isDark);
                        }
                        final items = controller.paginatedReviews;
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
                            final review = items[index];
                            return _buildReviewRow(
                              context,
                              review,
                              isDark,
                              theme,
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Pagination controls row
          const SizedBox(height: 8),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF2E3440) : Colors.grey.shade200,
          ),
          const SizedBox(height: 12),
          _buildPaginationRow(theme, isDark),
        ],
      ),
    );
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
          SizedBox(width: 160, child: Text('Pengguna', style: headerStyle)),
          SizedBox(width: 100, child: Text('Date', style: headerStyle)),
          SizedBox(width: 100, child: Text('Rating', style: headerStyle)),
          Expanded(child: Text('Ulasan', style: headerStyle)),
          SizedBox(width: 100, child: Text('Status', style: headerStyle)),
          SizedBox(
            width: 120,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('Aksi', style: headerStyle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRow(
    BuildContext context,
    ReviewModel item,
    bool isDark,
    ThemeData theme,
  ) {
    final nameInitials = item.reviewerName
        .split(' ')
        .map((s) => s.isNotEmpty ? s[0] : '')
        .join();
    final _ = item.replyText.value.isNotEmpty;

    // Vibrant avatar colors based on name initials
    Color avatarColor = const Color(0xFF6366F1); // Default Indigo
    if (nameInitials.contains('L')) {
      avatarColor = const Color(0xFFF43F5E); // Rose
    } else if (nameInitials.contains('B')) {
      avatarColor = const Color(0xFF06B6D4); // Cyan
    } else if (nameInitials.contains('R')) {
      avatarColor = const Color(0xFF3B82F6); // Blue
    } else if (nameInitials.contains('D')) {
      avatarColor = const Color(0xFFF59E0B); // Amber
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Pengguna (Avatar, Name, ID)
          SizedBox(
            width: 160,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: avatarColor,
                  child: Text(
                    nameInitials.substring(
                      0,
                      nameInitials.length > 2 ? 2 : nameInitials.length,
                    ),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.reviewerName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: #${item.id}',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Date
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

          // Rating
          SizedBox(
            width: 100,
            child: RatingStars(rating: item.rating, size: 12),
          ),

          // Ulasan (Comment text)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                item.comment,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Status Badge
          SizedBox(
            width: 100,
            child: Obx(() {
              final replied = item.replyText.value.isNotEmpty;
              return GlowBadge(
                label: replied ? 'REPLIED' : 'PENDING',
                color: replied
                    ? const Color(0xFF10B981)
                    : const Color(0xFFF43F5E),
              );
            }),
          ),

          // Aksi (Quick Reply / View Thread)
          SizedBox(
            width: 120,
            child: Align(
              alignment: Alignment.centerRight,
              child: Obx(() {
                final replied = item.replyText.value.isNotEmpty;
                if (replied) {
                  return TextButton(
                    onPressed: () => _openViewThreadDialog(context, item),
                    child: Text(
                      'View Thread',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  );
                } else {
                  return SizedBox(
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () => _openQuickReplyDialog(context, item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Quick Reply',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
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
            'Tidak ada ulasan ditemukan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ganti filter Anda untuk mencari yang lain.',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Memuat data ulasan...',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationRow(ThemeData theme, bool isDark) {
    return Obx(() {
      final total = controller.totalReviewsCount;
      final start = controller.startEntry;
      final end = controller.endEntry;
      final current = controller.currentPage.value;
      final pages = controller.totalPages;

      // Dynamic page button ranges windowing algorithm
      final List<Widget> pageButtons = [];
      const int maxButtons = 5;

      if (pages <= maxButtons) {
        for (int i = 1; i <= pages; i++) {
          pageButtons.add(_buildPageNumberButton(i, current, theme, isDark));
        }
      } else {
        // Always show the first page
        pageButtons.add(_buildPageNumberButton(1, current, theme, isDark));

        int startRange = current - 1;
        int endRange = current + 1;

        if (current <= 3) {
          startRange = 2;
          endRange = 4;
        } else if (current >= pages - 2) {
          startRange = pages - 3;
          endRange = pages - 1;
        }

        // Add left ellipsis
        if (startRange > 2) {
          pageButtons.add(_buildEllipsis(isDark));
        }

        // Add middle pages
        for (int i = startRange; i <= endRange; i++) {
          if (i > 1 && i < pages) {
            pageButtons.add(_buildPageNumberButton(i, current, theme, isDark));
          }
        }

        // Add right ellipsis
        if (endRange < pages - 1) {
          pageButtons.add(_buildEllipsis(isDark));
        }

        // Always show the last page
        pageButtons.add(_buildPageNumberButton(pages, current, theme, isDark));
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Showing count description
          Text(
            'Showing $start-$end of $total reviews',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),

          // Right: Page buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Prev Button
              _buildPaginationButton(
                icon: Icons.keyboard_arrow_left_rounded,
                enabled: current > 1,
                isDark: isDark,
                onTap: () => controller.changePage(current - 1),
              ),
              const SizedBox(width: 4),

              // Page numbers list
              ...pageButtons,

              const SizedBox(width: 4),
              // Next Button
              _buildPaginationButton(
                icon: Icons.keyboard_arrow_right_rounded,
                enabled: current < pages,
                isDark: isDark,
                onTap: () => controller.changePage(current + 1),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildPageNumberButton(
    int pageNum,
    int current,
    ThemeData theme,
    bool isDark,
  ) {
    final isSelected = pageNum == current;
    return GestureDetector(
      onTap: () => controller.changePage(pageNum),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '$pageNum',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
          ),
        ),
      ),
    );
  }

  Widget _buildEllipsis(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '...',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildPaginationButton({
    required IconData icon,
    required bool enabled,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: enabled
              ? (isDark ? const Color(0xFF1E222B) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: enabled
                ? (isDark ? const Color(0xFF2E3440) : Colors.grey.shade200)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled
              ? (isDark ? Colors.grey.shade300 : Colors.grey.shade700)
              : Colors.grey.shade400.withOpacity(0.5),
        ),
      ),
    );
  }

  void _openQuickReplyDialog(BuildContext context, ReviewModel item) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        // Reuse the dashboard's AiReplyDialog which is accessible!
        return AiReplyDialog(review: item);
      },
    );
  }

  void _openViewThreadDialog(BuildContext context, ReviewModel item) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 480,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E222B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2E3440)
                      : Colors.grey.shade200,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Thread Ulasan Google Maps',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Review Bubble
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withOpacity(0.2)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item.reviewerName,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            RatingStars(rating: item.rating, size: 10),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '"${item.comment}"',
                          style: const TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Response Bubble
                  Obx(() {
                    final reply = item.replyText.value;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.admin_panel_settings_rounded,
                                    size: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Tanggapan Mimin RSUD Soebandi',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  controller.deleteReply(item.id);
                                  Get.back();
                                  Get.snackbar(
                                    'Tanggapan Dihapus',
                                    'Balasan untuk ${item.reviewerName} berhasil dihapus.',
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Hapus',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            reply,
                            style: const TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
