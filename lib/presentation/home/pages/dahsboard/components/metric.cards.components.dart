part of 'main.components.dart';

class DashboardMetricsGrid extends GetView<DahsboardController> {
  const DashboardMetricsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final width = context.width;
      double aspectRatio;
      if (width > 1200) {
        aspectRatio = 1.65;
      } else if (width > 800) {
        aspectRatio = 1.85;
      } else {
        aspectRatio = 2.4;
      }

      return GridView.count(
        crossAxisCount: width > 1200 ? 4 : (width > 800 ? 2 : 1),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: aspectRatio,
        children: [
          _buildMetricCard(
            context: context,
            title: 'total_reviews'.tr,
            value: '${controller.totalReviewsCount}',
            trend: controller.pendingCount > 0
                ? '${controller.pendingCount} pending ulasan'
                : 'Semua ulasan dibalas',
            trendPositive: controller.pendingCount == 0,
            icon: Icons.rate_review_rounded,
            color: const Color(0xFF6366F1), // Indigo
            subtitle: 'Review dari Google Map',
          ),
          _buildMetricCard(
            context: context,
            title: 'average_rating'.tr,
            value: '${controller.averageRating}',
            trend: 'Stable (${controller.averageRating}★)',
            trendPositive: controller.averageRating >= 4.0,
            icon: Icons.star_rounded,
            color: const Color(0xFFF59E0B), // Amber
            isRating: true,
          ),
          _buildMetricCard(
            context: context,
            title: 'positive_vibes'.tr,
            value: '${controller.positivePercentage}%',
            trend: '${controller.positiveVibesTrendPercentage >= 0 ? '+' : ''}${controller.positiveVibesTrendPercentage}% vs kemarin',
            trendPositive: controller.positiveVibesTrendPercentage >= 0,
            icon: Icons.emoji_emotions_rounded,
            color: const Color(0xFF10B981), // Emerald
            subtitle: 'Ulasan Sentimen Positif',
          ),
          _buildMetricCard(
            context: context,
            title: 'avg_response_time'.tr,
            value: '${controller.avgResponseHours} hrs',
            trend: '${controller.responseTargetDifferenceMinutes <= 0 ? '' : '+'}${controller.responseTargetDifferenceMinutes}m vs target',
            trendPositive: controller.responseTargetDifferenceMinutes <= 0,
            icon: Icons.timer_rounded,
            color: const Color(0xFF06B6D4), // Cyan
            subtitle: 'Rata-rata kecepatan respon',
          ),
        ],
      );
    });
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required String trend,
    required bool trendPositive,
    required IconData icon,
    required Color color,
    String? subtitle,
    bool isRating = false,
  }) {
    return GlassContainer(
      glowColor: color,
      glowOpacity: 0.04,
      child: Stack(
        children: [
          // Background ambient light
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    textBaseline: TextBaseline.alphabetic,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                      if (isRating) ...[
                        const SizedBox(width: 6),
                        RatingStars(
                          rating: double.tryParse(value) ?? 5.0,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        trendPositive
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 14,
                        color: trendPositive
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF43F5E),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          trend,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: trendPositive
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF43F5E),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
