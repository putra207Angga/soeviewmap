part of 'main.components.dart';

class LanguageSelectorDialog extends StatelessWidget {
  const LanguageSelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentLocale = Get.locale ?? const Locale('id', 'ID');
    final currentCode = '${currentLocale.languageCode}_${currentLocale.countryCode ?? "ID"}';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF13151A) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? const Color(0xFF2E3440) : Colors.grey.shade200,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.6)
                  : const Color(0xFF6366F1).withOpacity(0.12),
              blurRadius: 32,
              spreadRadius: 2,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Premium Gradient Header Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E222B), const Color(0xFF2A2F3D)]
                      : [const Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.translate_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'select_language'.tr,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'RSUD dr. Soebandi',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Multi-Dialek Jatim',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Languages Selection List directly inside Column
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                    children: TranslationService.languages.map((lang) {
                      final isSelected = lang['code'] == currentCode;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              await TranslationService.changeLanguage(lang['code']!);
                              Get.back();
                              Get.snackbar(
                                'select_language'.tr,
                                '${'language_changed'.tr}: ${lang['name']}',
                                snackPosition: SnackPosition.BOTTOM,
                                margin: const EdgeInsets.all(16),
                                backgroundColor: isDark
                                    ? const Color(0xFF2E3440)
                                    : const Color(0xFF1E1B4B),
                                colorText: Colors.white,
                                icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
                                duration: const Duration(seconds: 2),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark
                                        ? const Color(0xFF6366F1).withOpacity(0.18)
                                        : const Color(0xFFEEF2FF))
                                    : (isDark
                                        ? const Color(0xFF1E222B)
                                        : Colors.grey.shade50),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF6366F1)
                                      : (isDark
                                          ? const Color(0xFF2E3440)
                                          : Colors.grey.shade200),
                                  width: isSelected ? 1.8 : 1.0,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF6366F1).withOpacity(0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Row(
                                children: [
                                  // Flag Emoji Badge
                                  Container(
                                    width: 44,
                                    height: 44,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF13151A) : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isDark ? const Color(0xFF2E3440) : Colors.grey.shade200,
                                      ),
                                    ),
                                    child: Text(
                                      lang['flag']!,
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Language Name & Description
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              lang['name']!,
                                              style: TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: isSelected
                                                    ? FontWeight.w900
                                                    : FontWeight.bold,
                                                color: isSelected
                                                    ? (isDark
                                                        ? const Color(0xFF818CF8)
                                                        : const Color(0xFF4F46E5))
                                                    : (isDark
                                                        ? Colors.white
                                                        : const Color(0xFF0F172A)),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            if (lang['region'] != null)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? const Color(0xFF6366F1).withOpacity(0.15)
                                                      : (isDark
                                                          ? const Color(0xFF2E3440)
                                                          : Colors.grey.shade200),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  lang['region']!,
                                                  style: TextStyle(
                                                    fontSize: 8.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: isSelected
                                                        ? const Color(0xFF6366F1)
                                                        : Colors.grey.shade600,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          lang['desc']!,
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            color: isDark
                                                ? Colors.grey.shade400
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Selected Indicator Check Icon
                                  if (isSelected)
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF6366F1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    )
                                  else
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 18,
                                      color: Colors.grey.shade400,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
        ),
      ),
    );
  }
}
