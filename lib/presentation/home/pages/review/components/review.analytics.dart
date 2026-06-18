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
            ? 2.1
            : (context.width > 1000 ? 1.75 : 2.0),
        children: [
          // 1. Positive Ulasan Per Bulan Card
          _buildAnalyticsCard(
            title: 'ULASAN POSITIF (BULANAN)',
            value: '$positiveRate%',
            subtitle:
                'Ulasan positif meningkat sebesar +5.2% dibandingkan bulan lalu.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: positiveRate / 100,
                    minHeight: 6,
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
            title: 'AVG WAKTU RESPON',
            value: avgResponse,
            subtitle: 'Lebih cepat 18 menit dari target operasional RSUD.',
            child: Row(
              children: [
                const Icon(
                  Icons.arrow_downward_rounded,
                  size: 14,
                  color: Color(0xFF10B981),
                ),
                const SizedBox(width: 4),
                Text(
                  '-18m dari target',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),

          // 3. Ulasan Pending Card
          _buildAnalyticsCard(
            title: 'ULASAN PENDING',
            value: '$pendingCount',
            subtitle: 'Ulasan menunggu tanggapan resmi dari Tim Humas.',
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: pendingCount > 0
                      ? const Color(0xFFF43F5E)
                      : const Color(0xFF10B981),
                ),
                const SizedBox(width: 4),
                Text(
                  pendingCount > 0 ? 'Requires Attention' : 'All Cleared!',
                  style: TextStyle(
                    fontSize: 11,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        child,
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 9.5,
                        color: Colors.grey.shade500,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}
