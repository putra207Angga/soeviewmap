part of 'main.components.dart';

class VibeMeterComponent extends GetView<DahsboardController> {
  const VibeMeterComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassContainer(
      glowColor: const Color(0xFF10B981), // Emerald glow
      glowOpacity: 0.02,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'vibe_check_title'.tr,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // Radial Vibe Score Gauge / Metric
          _buildVibeHeader(theme),
          const SizedBox(height: 16),
          // Sentiment Breakdown Bars
          Text(
            'rincian_sentimen'.tr,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          _buildSentimentProgressBars(),
          const SizedBox(height: 18),
          // Trending Keyword Word Cloud
          Text(
            'top_hashtag'.tr,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          _buildTrendingTagsCloud(),
        ],
      ),
    );
  }

  Widget _buildVibeHeader(ThemeData theme) {
    return Obx(() {
      final percentage = controller.positivePercentage;
      
      Color color = const Color(0xFFF59E0B);
      if (percentage >= 80) {
        color = const Color(0xFF10B981);
      } else if (percentage < 50) {
        color = const Color(0xFFF43F5E);
      }

      // Prioritize the summary status from backend sentiment analysis response
      String title = controller.sentimentAnalysis.value?.summaryStatus ?? 'Mid Vibe 😐';
      if (controller.sentimentAnalysis.value == null) {
        if (percentage >= 80) {
          title = 'Passed Vibe Check! ✨🚀';
        } else if (percentage < 50) {
          title = 'Bad Vibe Warning! 🚨😭';
        }
      }

      return Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 6,
                  backgroundColor: color.withOpacity(0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text(
                '${percentage.toInt()}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ulasan dari Google Maps RS Soebandi didominasi sentimen positif minggu ini.',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSentimentProgressBars() {
    return Obx(() {
      final analysis = controller.sentimentAnalysis.value;
      if (analysis != null) {
        return Column(
          children: [
            _buildProgressBarRow(
              'Positif (Vibe Aman)',
              analysis.positive.count,
              analysis.positive.percentage / 100,
              const Color(0xFF10B981),
            ),
            const SizedBox(height: 6),
            _buildProgressBarRow(
              'Netral (Biasa Aja)',
              analysis.neutral.count,
              analysis.neutral.percentage / 100,
              const Color(0xFFF59E0B),
            ),
            const SizedBox(height: 6),
            _buildProgressBarRow(
              'Negatif (Komplain)',
              analysis.negative.count,
              analysis.negative.percentage / 100,
              const Color(0xFFF43F5E),
            ),
          ],
        );
      }

      final total = controller.reviews.length;
      if (total == 0) return const SizedBox.shrink();

      final pos = controller.reviews
          .where((r) => r.sentiment == 'positive')
          .length;
      final neu = controller.reviews
          .where((r) => r.sentiment == 'neutral')
          .length;
      final neg = controller.reviews
          .where((r) => r.sentiment == 'negative')
          .length;

      return Column(
        children: [
          _buildProgressBarRow(
            'Positif (Vibe Aman)',
            pos,
            total > 0 ? pos / total : 0.0,
            const Color(0xFF10B981),
          ),
          const SizedBox(height: 6),
          _buildProgressBarRow(
            'Netral (Biasa Aja)',
            neu,
            total > 0 ? neu / total : 0.0,
            const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 6),
          _buildProgressBarRow(
            'Negatif (Komplain)',
            neg,
            total > 0 ? neg / total : 0.0,
            const Color(0xFFF43F5E),
          ),
        ],
      );
    });
  }

  Widget _buildProgressBarRow(String label, int count, double pct, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            ),
            Text(
              '$count ulasan (${(pct * 100).toStringAsFixed(0)}%)',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingTagsCloud() {
    return Obx(() {
      final analysis = controller.sentimentAnalysis.value;
      if (analysis != null && analysis.topKeywords.isNotEmpty) {
        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: analysis.topKeywords.map((entry) {
            final tag = entry.keyword;
            final count = entry.count;

            Color tagColor;
            if (tag.contains('slow') ||
                tag.contains('unfriendly') ||
                tag.contains('L_')) {
              tagColor = const Color(0xFFF43F5E); // Negative red
            } else if (tag.contains('mid') || tag.contains('hot')) {
              tagColor = const Color(0xFFF59E0B); // Neutral amber
            } else {
              tagColor = const Color(0xFF10B981); // Positive green
            }

            return InkWell(
              onTap: () {
                Get.snackbar(
                  'Hashtag Filter',
                  'Tag $tag muncul di $count ulasan.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: tagColor.withOpacity(0.85),
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: tagColor.withOpacity(0.25),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tag,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: tagColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: tagColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: tagColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      }

      // Fallback: Gather all tags from local reviews and count frequencies
      final tagFreq = <String, int>{};
      for (final r in controller.reviews) {
        for (final tag in r.tags) {
          tagFreq[tag] = (tagFreq[tag] ?? 0) + 1;
        }
      }

      final sortedTags = tagFreq.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return Wrap(
        spacing: 6,
        runSpacing: 6,
        children: sortedTags.map((entry) {
          final tag = entry.key;
          final count = entry.value;

          Color tagColor;
          if (tag.contains('slow') ||
              tag.contains('unfriendly') ||
              tag.contains('L_')) {
            tagColor = const Color(0xFFF43F5E); // Negative red
          } else if (tag.contains('mid') || tag.contains('hot')) {
            tagColor = const Color(0xFFF59E0B); // Neutral amber
          } else {
            tagColor = const Color(0xFF10B981); // Positive green
          }

          return InkWell(
            onTap: () {
              Get.snackbar(
                'Hashtag Filter',
                'Tag $tag muncul di $count ulasan.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: tagColor.withOpacity(0.85),
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: tagColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: tagColor.withOpacity(0.25),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tag,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: tagColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: tagColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: tagColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}
