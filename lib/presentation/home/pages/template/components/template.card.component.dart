part of 'main.components.dart';

class TemplateCard extends StatelessWidget {
  final int rating;
  final String templateText;
  final VoidCallback onEditTap;
  final VoidCallback onDeleteTap;

  const TemplateCard({
    super.key,
    required this.rating,
    required this.templateText,
    required this.onEditTap,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassContainer(
      glowColor: theme.colorScheme.primary,
      glowOpacity: 0.005,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row: Star Rating RatingStars and Edit/Delete Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  RatingStars(
                    rating: rating.toDouble(),
                    size: 15,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '- ${"star_label".tr} $rating',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed: onEditTap,
                    icon: const Icon(Icons.edit_outlined, size: 13),
                    label: Text(
                      'edit'.tr,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      side: BorderSide(
                        color: theme.colorScheme.primary.withOpacity(0.4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.04),
                      elevation: 0,
                    ),
                  ),
                  if (templateText.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onDeleteTap,
                      icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent),
                      tooltip: 'delete_template_title'.tr,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.04),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: Colors.redAccent.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Template message block (quotes)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withOpacity(0.12)
                  : Colors.grey.shade50.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2E3440).withOpacity(0.5)
                    : Colors.grey.shade200,
                width: 0.8,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  templateText.isEmpty
                      ? Icons.info_outline_rounded
                      : Icons.format_quote_rounded,
                  size: 18,
                  color: templateText.isEmpty
                      ? Colors.orange.withOpacity(0.6)
                      : theme.colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    templateText.isEmpty
                        ? 'Belum ada template balasan untuk rating bintang $rating. Silakan klik tombol Edit di atas untuk menyusun template baru.'
                        : templateText,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                      color: templateText.isEmpty
                          ? (isDark ? Colors.grey.shade500 : Colors.grey.shade400)
                          : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                      height: 1.35,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
