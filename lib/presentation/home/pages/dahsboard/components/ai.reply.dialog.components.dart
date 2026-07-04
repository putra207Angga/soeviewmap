part of 'main.components.dart';

class AiReplyDialog extends StatefulWidget {
  const AiReplyDialog({super.key, required this.review});
  final ReviewUiModel review;

  @override
  State<AiReplyDialog> createState() => _AiReplyDialogState();
}

class _AiReplyDialogState extends State<AiReplyDialog> {
  final controller = Get.find<DahsboardController>();
  final _replyTextController = TextEditingController();
  String _selectedTone = 'Gen Z Slang';

  @override
  void initState() {
    super.initState();
    // Generate initial draft on open
    _generateDraft();
  }

  @override
  void dispose() {
    _replyTextController.dispose();
    super.dispose();
  }

  void _generateDraft() {
    controller.generateAiReply(widget.review, _selectedTone).then((_) {
      _replyTextController.text = controller.generatedReply.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 500,
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E222B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF2E3440) : Colors.grey.shade200,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.5 : 0.1),
                blurRadius: 36,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dialog Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? const Color(0xFF2E3440)
                          : Colors.grey.shade200,
                      width: 0.8,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ).createShader(bounds),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'AI Smart Reply Assistant',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),

              // Content Area
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Review Context Snippet
                      const Text(
                        'Ulasan Pelanggan:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black.withOpacity(0.15)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
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
                            Row(
                              children: [
                                Text(
                                  widget.review.reviewerName,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                RatingStars(
                                  rating: widget.review.rating,
                                  size: 10,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '"${widget.review.comment}"',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade700,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tone Selector
                      const Text(
                        'Pilih Nada Balasan (Tone):',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildToneSelector(),
                      const SizedBox(height: 16),

                      // Result Draft Text Field
                      const Text(
                        'Draf Balasan AI:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDraftOutput(),
                    ],
                  ),
                ),
              ),

              // Footer Actions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? const Color(0xFF2E3440)
                          : Colors.grey.shade200,
                      width: 0.8,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 8),
                    Obx(() {
                      final isGenerating = controller.isGeneratingReply.value;
                      return ElevatedButton.icon(
                        onPressed: isGenerating
                            ? null
                            : () {
                                controller.submitReply(
                                  widget.review.reviewId,
                                  _replyTextController.text,
                                );
                                Get.back();
                                Get.snackbar(
                                  'Balasan Terkirim',
                                  'Ulasan ${widget.review.reviewerName} berhasil dibalas.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: const Color(0xFF10B981),
                                  colorText: Colors.white,
                                );
                              },
                        icon: const Icon(Icons.send_rounded, size: 14),
                        label: const Text(
                          'Kirim Balasan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToneSelector() {
    final tones = [
      'Gen Z Slang',
      'Professional',
      'Friendly',
      'Concise',
      'Template',
    ];
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: tones.map((tone) {
        final isSelected = _selectedTone == tone;
        Color toneColor;
        switch (tone) {
          case 'Gen Z Slang':
            toneColor = const Color(0xFF8B5CF6); // Violet
            break;
          case 'Professional':
            toneColor = const Color(0xFF06B6D4); // Cyan
            break;
          case 'Friendly':
            toneColor = const Color(0xFF10B981); // Emerald
            break;
          case 'Template':
            toneColor = const Color(0xFFF59E0B); // Amber
            break;
          default:
            toneColor = const Color(0xFF6B7280); // Gray
        }

        return ChoiceChip(
          label: Text(
            tone,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : toneColor,
            ),
          ),
          selected: isSelected,
          selectedColor: toneColor,
          backgroundColor: toneColor.withOpacity(0.06),
          side: BorderSide(
            color: isSelected ? Colors.transparent : toneColor.withOpacity(0.3),
            width: 0.8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          labelPadding: EdgeInsets.zero,
          showCheckmark: false,
          onSelected: (selected) async {
            if (selected) {
              setState(() {
                _selectedTone = tone;
              });

              if (_selectedTone == "Template") {
                final templateCtrl = Get.find<TemplateController>();
                final reviewRating =
                    widget.review.rating.round().clamp(1, 5);
                final templateText =
                    templateCtrl.starTemplates[reviewRating];

                if (templateText != null && templateText.isNotEmpty) {
                  final applied = templateText
                      .replaceAll(
                          '{reviewerName}', widget.review.reviewerName)
                      .replaceAll(
                          '{locationName}', widget.review.locationName);
                  _replyTextController.text = applied;
                  controller.generatedReply.value = applied;
                  return;
                }
                // No template for this rating — fallback to AI draft
              }
              _generateDraft();
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildDraftOutput() {
    return Obx(() {
      final isGenerating = controller.isGeneratingReply.value;
      if (isGenerating) {
        return Container(
          height: 120,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Get.isDarkMode
                ? Colors.black.withOpacity(0.1)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Get.isDarkMode
                  ? const Color(0xFF2E3440)
                  : Colors.grey.shade200,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
              const SizedBox(height: 12),
              Text(
                'Mempersiapkan balasan terkece... ✨',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      }

      return TextField(
        controller: _replyTextController,
        maxLines: 4,
        style: const TextStyle(fontSize: 11, height: 1.4),
        decoration: InputDecoration(
          hintText: 'Tulis balasan di sini...',
          filled: true,
          fillColor: Get.isDarkMode
              ? Colors.black.withOpacity(0.15)
              : Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Get.isDarkMode
                  ? const Color(0xFF2E3440)
                  : Colors.grey.shade200,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Get.isDarkMode
                  ? const Color(0xFF2E3440)
                  : Colors.grey.shade200,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1.2,
            ),
          ),
          contentPadding: const EdgeInsets.all(12),
        ),
      );
    });
  }
}
