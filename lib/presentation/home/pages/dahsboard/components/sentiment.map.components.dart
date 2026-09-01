part of 'main.components.dart';

class SentimentMapComponent extends GetView<DahsboardController> {
  const SentimentMapComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassContainer(
      glowColor: const Color(0xFF8B5CF6), // Violet glow
      glowOpacity: 0.02,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'map_title'.tr,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'map_subtitle'.tr,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              Obx(() {
                if (controller.selectedLocation.value != null) {
                  return TextButton.icon(
                    onPressed: () => controller.filterByLocation(null),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: Text('reset_filter'.tr),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: AspectRatio(
                    aspectRatio:
                        650 / 450, // Match the static map image aspect ratio
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          // 1. Real Static Map Background of RSUD dr. Soebandi
                          // Center coordinates: Latitude -8.151138, Longitude 113.714947 (zoom 17)
                          Positioned.fill(
                            child: Image.network(
                              isDark
                                  ? 'https://static-maps.yandex.ru/1.x/?ll=113.714947,-8.151138&z=17&size=650,450&l=sat' // Satellite view for Dark Mode
                                  : 'https://static-maps.yandex.ru/1.x/?ll=113.714947,-8.151138&z=17&size=650,450&l=map', // Map view for Light Mode
                              fit: BoxFit.fill,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: isDark
                                      ? const Color(0xFF1E222B)
                                      : Colors.grey.shade100,
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.map_outlined,
                                          size: 36,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Gagal memuat Google Maps.\nPastikan terhubung ke internet.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // 2. High-Tech HUD Grid overlay
                          Positioned.fill(
                            child: CustomPaint(
                              painter: MapGridPainter(isDark: isDark),
                            ),
                          ),

                          // 3. Interactive Pins Positioned dynamically
                          ...controller.locations.map((loc) {
                            return Obx(() {
                              final isSelected =
                                  controller.selectedLocation.value == loc.name;
                              final isAnySelected =
                                  controller.selectedLocation.value != null;
                              final opacity = (!isAnySelected || isSelected)
                                  ? 1.0
                                  : 0.45;

                              Color sentimentColor;
                              if (loc.dominantSentiment == 'positive') {
                                sentimentColor = const Color(
                                  0xFF10B981,
                                ); // Emerald
                              } else if (loc.dominantSentiment == 'negative') {
                                sentimentColor = const Color(
                                  0xFFF43F5E,
                                ); // Rose
                              } else {
                                sentimentColor = const Color(
                                  0xFFF59E0B,
                                ); // Amber
                              }

                              return Positioned(
                                left: loc.dx * constraints.maxWidth - 50,
                                top: loc.dy * constraints.maxHeight - 48,
                                child: GestureDetector(
                                  onTap: () =>
                                      controller.filterByLocation(loc.name),
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 200),
                                    opacity: opacity,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Tooltip Tag label
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? theme.colorScheme.primary
                                                : (isDark
                                                      ? const Color(
                                                          0xFF1E222B,
                                                        ).withOpacity(0.9)
                                                      : Colors.white
                                                            .withOpacity(0.9)),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.white
                                                  : sentimentColor,
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.25,
                                                ),
                                                blurRadius: 6,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            loc.name.split(' (').first,
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? Colors.white
                                                  : (isDark
                                                        ? Colors.grey.shade300
                                                        : Colors.grey.shade800),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        // Glowing Pin Core Dot
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            // Ripple ring
                                            AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 400,
                                              ),
                                              width: isSelected ? 24 : 16,
                                              height: isSelected ? 24 : 16,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: sentimentColor
                                                    .withOpacity(0.25),
                                                border: Border.all(
                                                  color: sentimentColor,
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                            // Solid core
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: sentimentColor,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: sentimentColor
                                                        .withOpacity(0.6),
                                                    blurRadius: 6,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            });
                          }),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // Map Legends
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: Color(0xFF10B981), label: 'Vibe Positif'),
              SizedBox(width: 16),
              _LegendItem(color: Color(0xFFF59E0B), label: 'Campuran / Netral'),
              SizedBox(width: 16),
              _LegendItem(color: Color(0xFFF43F5E), label: 'Sentimen Komplain'),
            ],
          ),
        ],
      ),
    );
  }
}

class MapGridPainter extends CustomPainter {
  final bool isDark;

  MapGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // Subtle overlay grid to enhance cyber/HUD feel
    final gridPaint = Paint()
      ..color = isDark
          ? Colors.cyanAccent.withOpacity(0.04)
          : Colors.blue.withOpacity(0.03)
      ..strokeWidth = 0.8;

    double step = 30.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double j = 0; j < size.height; j += step) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), gridPaint);
    }

    // Outer HUD border corners
    final cornerPaint = Paint()
      ..color = isDark
          ? Colors.white.withOpacity(0.12)
          : Colors.black.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    double offset = 8.0;
    double len = 14.0;

    // Top-Left corner
    canvas.drawLine(
      Offset(offset, offset),
      Offset(offset + len, offset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(offset, offset),
      Offset(offset, offset + len),
      cornerPaint,
    );

    // Top-Right corner
    canvas.drawLine(
      Offset(size.width - offset, offset),
      Offset(size.width - offset - len, offset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width - offset, offset),
      Offset(size.width - offset, offset + len),
      cornerPaint,
    );

    // Bottom-Left corner
    canvas.drawLine(
      Offset(offset, size.height - offset),
      Offset(offset + len, size.height - offset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(offset, size.height - offset),
      Offset(offset, size.height - offset - len),
      cornerPaint,
    );

    // Bottom-Right corner
    canvas.drawLine(
      Offset(size.width - offset, size.height - offset),
      Offset(size.width - offset - len, size.height - offset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width - offset, size.height - offset),
      Offset(size.width - offset, size.height - offset - len),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant MapGridPainter oldDelegate) => false;
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
