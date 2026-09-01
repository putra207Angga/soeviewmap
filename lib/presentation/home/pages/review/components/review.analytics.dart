part of 'main.components.dart';

class ReviewAnalyticsPanel extends GetView<ReviewController> {
  const ReviewAnalyticsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final positiveRate = controller.positiveVibeRate;
      final pendingCount = controller.pendingReviewsCount;
      final avgResponse = controller.avgResponseTime;

      return GridView.count(
        crossAxisCount: context.width > 1000
            ? 3
            : (context.width > 600 ? 2 : 1),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: context.width > 1200
            ? 3.4
            : (context.width > 1000 ? 2.8 : 2.2),
        children: [
          // 1. Positive Ulasan Per Bulan Card
          _buildAnalyticsCard(
            title: 'positive_reviews_monthly'.tr,
            value: '$positiveRate%',
            subtitle: 'positive_increase_desc'.tr,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: positiveRate / 100,
                    minHeight: 5,
                    backgroundColor: const Color(0xFF10B981).withOpacity(0.12),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Avg Response Time Card
          _buildAnalyticsCard(
            title: 'avg_response_time'.tr,
            value: avgResponse,
            subtitle: controller.stats.value != null
                ? '${controller.stats.value!.responseTargetDifferenceMinutes.abs()}m ${"from_target".tr}'
                : '18m ${"from_target".tr}',
            child: Row(
              children: [
                Icon(
                  controller.stats.value != null
                      ? (controller.stats.value!.responseTargetDifferenceMinutes <= 0
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded)
                      : Icons.arrow_downward_rounded,
                  size: 13,
                  color: controller.stats.value != null
                      ? (controller.stats.value!.responseTargetDifferenceMinutes <= 0
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF43F5E))
                      : const Color(0xFF10B981),
                ),
                const SizedBox(width: 4),
                Text(
                  controller.stats.value != null
                      ? '${controller.stats.value!.responseTargetDifferenceMinutes <= 0 ? '-' : '+'}${controller.stats.value!.responseTargetDifferenceMinutes.abs()}m ${"from_target".tr}'
                      : '-18m ${"from_target".tr}',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: controller.stats.value != null
                        ? (controller.stats.value!.responseTargetDifferenceMinutes <= 0
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF43F5E))
                        : const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),

          // 3. Ulasan Pending Card
          _buildAnalyticsCard(
            title: 'pending_reviews_title'.tr,
            value: '$pendingCount',
            subtitle: 'pending_reviews_desc'.tr,
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 13,
                  color: pendingCount > 0
                      ? const Color(0xFFF43F5E)
                      : const Color(0xFF10B981),
                ),
                const SizedBox(width: 4),
                Text(
                  pendingCount > 0 ? 'requires_attention'.tr : 'all_cleared'.tr,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: pendingCount > 0
                        ? const Color(0xFFF43F5E)
                        : const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildAnalyticsCard({
    required String title,
    required String value,
    required String subtitle,
    required Widget child,
  }) {
    return GlassContainer(
      glowOpacity: 0.0,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                        fontSize: 9.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        child,
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 9.0,
                        color: Colors.grey.shade500,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
