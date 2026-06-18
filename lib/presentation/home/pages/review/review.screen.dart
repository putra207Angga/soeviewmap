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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 950;

            if (isWide) {
              // Desktop Viewport Layout (fixed height fit or scrollable if height is small)
              final isTallEnough = constraints.maxHeight > 750;

              Widget content = Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const ReviewFiltersPanel(),
                    const SizedBox(height: 16),
                    isTallEnough
                        ? const Expanded(child: ReviewTableComponent())
                        : const SizedBox(
                            height: 500,
                            child: ReviewTableComponent(),
                          ),
                    const SizedBox(height: 16),
                    const ReviewAnalyticsPanel(),
                  ],
                ),
              );

              if (!isTallEnough) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: content,
                );
              }
              return content;
            } else {
              // Mobile/Tablet Scrollable Column Layout
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const ReviewFiltersPanel(),
                      const SizedBox(height: 16),
                      const SizedBox(
                        height: 520,
                        child: ReviewTableComponent(),
                      ),
                      const SizedBox(height: 16),
                      const ReviewAnalyticsPanel(),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
