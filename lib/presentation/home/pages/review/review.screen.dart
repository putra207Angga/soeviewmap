part of '../main.pages.dart';

class ReviewScreen extends GetView<ReviewController> {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0D0E12)
          : const Color(0xFFF3F4F6),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.fetchReviews(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ReviewFiltersPanel(),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: context.width > 600 ? 540 : 440,
                    child: const ReviewTableComponent(),
                  ),
                  const SizedBox(height: 10),
                  const ReviewAnalyticsPanel(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
