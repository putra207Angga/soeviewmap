part of 'main.components.dart';

class ReviewsListComponent extends GetView<DahsboardController> {
  const ReviewsListComponent({super.key});

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Feed Ulasan Google Maps',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Obx(() {
                final count = controller.filteredReviews.length;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count Ulasan',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 12),

          // Filters row
          _buildFilterTabs(),
          const SizedBox(height: 8),

          // Active filter chip indicator
          _buildActiveFiltersIndicator(theme),

          const SizedBox(height: 8),

          // Review list scrollable
          Expanded(
            child: Obx(() {
              final items = controller.filteredReviews;
              if (items.isEmpty) {
                return _buildEmptyState(isDark);
              }
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildReviewCard(context, item, isDark, theme);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final sentiments = ['All', 'Positive', 'Neutral', 'Negative'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: sentiments.map((sentiment) {
          return Obx(() {
            final isSelected = controller.selectedSentiment.value == sentiment;
            Color activeColor;
            IconData icon;

            switch (sentiment) {
              case 'Positive':
                activeColor = const Color(0xFF10B981);
                icon = Icons.sentiment_very_satisfied_rounded;
                break;
              case 'Neutral':
                activeColor = const Color(0xFFF59E0B);
                icon = Icons.sentiment_neutral_rounded;
                break;
              case 'Negative':
                activeColor = const Color(0xFFF43F5E);
                icon = Icons.sentiment_very_dissatisfied_rounded;
                break;
              default:
                activeColor = const Color(0xFF6366F1);
                icon = Icons.list_rounded;
            }

            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 14,
                      color: isSelected
                          ? Colors.white
                          : activeColor.withOpacity(0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      sentiment == 'All'
                          ? 'Semua'
                          : (sentiment == 'Positive'
                                ? 'Positif'
                                : (sentiment == 'Neutral'
                                      ? 'Netral'
                                      : 'Negatif')),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : (Get.isDarkMode
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
                selected: isSelected,
                selectedColor: activeColor,
                backgroundColor: activeColor.withOpacity(0.08),
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : activeColor.withOpacity(0.2),
                  width: 0.8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                labelPadding: EdgeInsets.zero,
                showCheckmark: false,
                onSelected: (selected) {
                  if (selected) {
                    controller.filterBySentiment(sentiment);
                  }
                },
              ),
            );
          });
        }).toList(),
      ),
    );
  }

  Widget _buildActiveFiltersIndicator(ThemeData theme) {
    return Obx(() {
      final loc = controller.selectedLocation.value;
      final rating = controller.selectedRating.value;

      if (loc == null && rating == null) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Filter aktif:',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (loc != null)
              Chip(
                label: Text(
                  'Lokasi: ${loc.split(' (').first}',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                deleteIcon: const Icon(Icons.close_rounded, size: 10),
                backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: BorderSide(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                ),
                onDeleted: () => controller.filterByLocation(null),
              ),
            if (rating != null)
              Chip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Rating: ${rating.toInt()}',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.star_rounded,
                      size: 10,
                      color: Color(0xFFF59E0B),
                    ),
                  ],
                ),
                deleteIcon: const Icon(Icons.close_rounded, size: 10),
                backgroundColor: const Color(0xFFF59E0B).withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: const BorderSide(color: Color(0xFFF59E0B)),
                onDeleted: () => controller.filterByRating(null),
              ),
            TextButton(
              onPressed: () => controller.resetFilters(),
              child: const Text(
                'Reset Semua',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEmptyState(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.sentiment_dissatisfied_rounded,
          size: 48,
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
        ),
        const SizedBox(height: 12),
        Text(
          'Gak ada ulasan nih, Bestie! 🥲',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Coba reset filter atau pilih lokasi lain.',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildReviewCard(
    BuildContext context,
    ReviewModel item,
    bool isDark,
    ThemeData theme,
  ) {
    Color sentimentColor;
    String sentimentText;

    final sentimentLower = item.sentiment.toLowerCase();
    if (sentimentLower == 'positive') {
      sentimentColor = const Color(0xFF10B981);
      sentimentText = 'Passed Vibe Check ✨';
    } else if (sentimentLower == 'negative') {
      sentimentColor = const Color(0xFFF43F5E);
      sentimentText = 'Bad Vibe Alert 🚨';
    } else {
      sentimentColor = const Color(0xFFF59E0B);
      sentimentText = 'Neutral Vibe 😐';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E222B).withOpacity(0.5)
            : Colors.grey.shade50.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2E3440).withOpacity(0.5)
              : Colors.grey.shade200,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Avatar & Name row
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: sentimentColor.withOpacity(0.1),
                backgroundImage: NetworkImage(item.reviewerAvatar),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.reviewerName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          item.date,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        RatingStars(rating: item.rating, size: 12),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200.withOpacity(
                              isDark ? 0.08 : 0.8,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.locationName.split(' (').first,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Comment content
          Text(item.comment, style: const TextStyle(fontSize: 11, height: 1.4)),
          const SizedBox(height: 8),

          // Tags row & Sentiment indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 4,
                children: item.tags
                    .map(
                      (tag) => Text(
                        tag,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary.withOpacity(0.85),
                        ),
                      ),
                    )
                    .toList(),
              ),
              GlowBadge(label: sentimentText, color: sentimentColor),
            ],
          ),

          // Reply Panel
          const SizedBox(height: 8),
          Obx(() {
            final reply = item.replyText.value;
            if (reply.isEmpty) {
              return Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => _openAiReplySheet(context, item),
                  icon: const Icon(Icons.auto_awesome, size: 12),
                  label: const Text(
                    'AI Smart Reply',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              );
            }

            return Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.04),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.15),
                  width: 0.8,
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
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Balasan RS Soebandi',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => controller.deleteReply(item.id),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 14,
                          color: Colors.redAccent,
                        ),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        tooltip: 'Hapus balasan',
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reply,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? Colors.grey.shade300
                          : Colors.grey.shade800,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _openAiReplySheet(BuildContext context, ReviewModel item) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AiReplyDialog(review: item);
      },
    );
  }
}
