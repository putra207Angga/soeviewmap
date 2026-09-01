part of 'main.components.dart';

class MenuSearchOption {
  final NavMenu menu;
  final String? targetMonth;
  final String? targetRating; // e.g. "5 Stars", "1 Star"
  final String? targetStatus; // e.g. "Pending", "Replied"
  final String? targetSentiment; // e.g. "Positif", "Negatif"
  final String? actionType; // "new_template", "open_settings"
  final String? customSubtitle;

  MenuSearchOption({
    required this.menu,
    this.targetMonth,
    this.targetRating,
    this.targetStatus,
    this.targetSentiment,
    this.actionType,
    this.customSubtitle,
  });

  String get displayTitle => menu.translatedLabel;

  String? get displaySubtitle {
    if (customSubtitle != null) return customSubtitle;
    final parts = <String>[];
    if (targetMonth != null && targetMonth!.isNotEmpty) {
      parts.add('Periode $targetMonth');
    }
    if (targetStatus != null && targetStatus!.isNotEmpty) {
      parts.add('Status $targetStatus');
    }
    if (targetRating != null && targetRating!.isNotEmpty) {
      parts.add('Rating $targetRating');
    }
    if (targetSentiment != null && targetSentiment!.isNotEmpty) {
      parts.add('Sentimen $targetSentiment');
    }
    if (parts.isNotEmpty) {
      return parts.join('  •  ');
    }
    return null;
  }
}

class AppBarComponent extends StatelessWidget implements PreferredSizeWidget {
  const AppBarComponent({super.key, required this.controller});

  final HomeController controller;

  static String _getMonthNameByIndex(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }

  static String? _extractMonthFromSearch(String text) {
    if (text.isEmpty) return null;
    final lower = text.toLowerCase();
    final now = DateTime.now();

    // 1. ISO Format: YYYY-MM-DD or YYYY-MM (e.g. 2026-09-01 or 2026-09)
    final isoMatch = RegExp(
      r'\b(20\d{2})[-/](0?[1-9]|1[0-2])(?:[-/]([0-3]?\d))?\b',
    ).firstMatch(lower);
    if (isoMatch != null) {
      final year = int.parse(isoMatch.group(1)!);
      final monthIdx = int.parse(isoMatch.group(2)!);
      final monthName = _getMonthNameByIndex(monthIdx);
      if (monthName.isNotEmpty) {
        return '$monthName $year';
      }
    }

    // 2. Format: DD-MM-YYYY or MM/YYYY (e.g. 01-09-2026 or 09/2026)
    final dmyMatch = RegExp(
      r'\b(?:[0-3]?\d[-/])?(0?[1-9]|1[0-2])[-/](20\d{2})\b',
    ).firstMatch(lower);
    if (dmyMatch != null) {
      final monthIdx = int.parse(dmyMatch.group(1)!);
      final year = int.parse(dmyMatch.group(2)!);
      final monthName = _getMonthNameByIndex(monthIdx);
      if (monthName.isNotEmpty) {
        return '$monthName $year';
      }
    }

    // 3. Month names (Indonesian / English)
    final monthMap = {
      'januari': 1,
      'jan': 1,
      'january': 1,
      'februari': 2,
      'feb': 2,
      'february': 2,
      'maret': 3,
      'mar': 3,
      'march': 3,
      'april': 4,
      'apr': 4,
      'mei': 5,
      'may': 5,
      'juni': 6,
      'jun': 6,
      'june': 6,
      'juli': 7,
      'jul': 7,
      'july': 7,
      'agustus': 8,
      'ags': 8,
      'agu': 8,
      'august': 8,
      'september': 9,
      'sep': 9,
      'oktober': 10,
      'okt': 10,
      'october': 10,
      'november': 11,
      'nov': 11,
      'desember': 12,
      'des': 12,
      'december': 12,
    };

    for (final entry in monthMap.entries) {
      if (lower.contains(entry.key)) {
        final yearMatch = RegExp(r'\b(20\d{2})\b').firstMatch(lower);
        final year =
            yearMatch != null ? int.parse(yearMatch.group(1)!) : now.year;
        final monthName = _getMonthNameByIndex(entry.value);
        return '$monthName $year';
      }
    }

    return null;
  }

  static String? _extractRatingFromSearch(String text) {
    final lower = text.toLowerCase();
    final starMatch = RegExp(
      r'\b(?:bintang|star|rating)\s*([1-5])\b|\b([1-5])\s*(?:bintang|star)\b',
    ).firstMatch(lower);
    if (starMatch != null) {
      final ratingNum = starMatch.group(1) ?? starMatch.group(2);
      if (ratingNum != null) {
        return '$ratingNum Stars';
      }
    }
    return null;
  }

  static String? _extractStatusFromSearch(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('pending') ||
        lower.contains('perlu dibalas') ||
        lower.contains('belum dibalas')) {
      return 'Pending';
    }
    if (lower.contains('terkirim') ||
        lower.contains('replied') ||
        lower.contains('sudah dibalas')) {
      return 'Replied';
    }
    return null;
  }

  static String? _extractSentimentFromSearch(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('positif') || lower.contains('positive')) {
      return 'Positif';
    }
    if (lower.contains('negatif') || lower.contains('negative')) {
      return 'Negatif';
    }
    if (lower.contains('netral') || lower.contains('neutral')) {
      return 'Netral';
    }
    return null;
  }

  void _handleMenuSelection(MenuSearchOption option, BuildContext context) {
    if (option.actionType == 'open_settings') {
      Scaffold.of(context).openEndDrawer();
      Get.snackbar(
        'Pengaturan',
        'Membuka Panel Pengaturan Aplikasi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.isDarkMode
            ? const Color(0xFF1E222B)
            : Colors.white.withOpacity(0.95),
        colorText: Get.isDarkMode ? Colors.white : Colors.black,
        icon: const Icon(Icons.settings_rounded, color: Colors.blueAccent),
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (option.actionType == 'open_tutorial') {
      showDialog(
        context: context,
        builder: (context) => const HelperTutorialDialog(),
      );
      return;
    }

    if (option.actionType == 'new_template') {
      controller.toNavigation(NavMenu.templet.index);
      Get.snackbar(
        'Template Baru',
        'Membuka Halaman Template Balasan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.isDarkMode
            ? const Color(0xFF1E222B)
            : Colors.white.withOpacity(0.95),
        colorText: Get.isDarkMode ? Colors.white : Colors.black,
        icon: const Icon(
          Icons.add_circle_outline_rounded,
          color: Colors.blueAccent,
        ),
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    controller.toNavigation(option.menu.index);

    final details = <String>[];

    if (option.targetMonth != null && option.targetMonth!.isNotEmpty) {
      final month = option.targetMonth!;
      if (Get.isRegistered<BalasController>()) {
        Get.find<BalasController>().changeMonth(month);
      }
      details.add('Periode: $month');
    }

    if (option.targetRating != null && option.targetRating!.isNotEmpty) {
      final rating = option.targetRating!;
      if (Get.isRegistered<ReviewController>()) {
        Get.find<ReviewController>().selectedRating.value = rating;
      }
      details.add('Rating: $rating');
    }

    if (option.targetStatus != null && option.targetStatus!.isNotEmpty) {
      final status = option.targetStatus!;
      if (Get.isRegistered<ReviewController>()) {
        Get.find<ReviewController>().selectedStatus.value = status;
      }
      details.add('Status: $status');
    }

    if (option.targetSentiment != null && option.targetSentiment!.isNotEmpty) {
      details.add('Sentimen: ${option.targetSentiment!}');
    }

    Get.snackbar(
      'Navigasi Pintar',
      details.isNotEmpty
          ? 'Membuka ${option.menu.translatedLabel} (${details.join(', ')})'
          : 'Membuka ${option.menu.translatedLabel}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.isDarkMode
          ? const Color(0xFF1E222B)
          : Colors.white.withOpacity(0.95),
      colorText: Get.isDarkMode ? Colors.white : Colors.black,
      icon: const Icon(
        Icons.auto_awesome_rounded,
        color: Colors.blueAccent,
      ),
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      titleSpacing: 16,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: isDark ? const Color(0xFF13151A) : Colors.white,
      foregroundColor: Theme.of(context).cardColor,
      title: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Autocomplete<MenuSearchOption>(
            optionsBuilder: (textEditingValue) {
              final queryText = textEditingValue.text.trim();
              final role = controller.userProfile.value?.role;
              final allMenus = NavMenu.byRole(role);

              if (queryText.isEmpty) {
                return allMenus
                    .map((m) => MenuSearchOption(menu: m))
                    .toList();
              }

              final lowerQuery = queryText.toLowerCase();
              final extraOptions = <MenuSearchOption>[];

              if (lowerQuery.contains('pengaturan') ||
                  lowerQuery.contains('setting') ||
                  lowerQuery.contains('dark') ||
                  lowerQuery.contains('tema')) {
                extraOptions.add(
                  MenuSearchOption(
                    menu: NavMenu.dashboard,
                    actionType: 'open_settings',
                    customSubtitle: '⚙️ Buka Drawer Pengaturan Aplikasi',
                  ),
                );
              }

              if (lowerQuery.contains('baru') ||
                  lowerQuery.contains('tambah') ||
                  lowerQuery.contains('template baru')) {
                extraOptions.add(
                  MenuSearchOption(
                    menu: NavMenu.templet,
                    actionType: 'new_template',
                    customSubtitle: '➕ Buat Template Balasan Baru',
                  ),
                );
              }

              if (lowerQuery.contains('panduan') ||
                  lowerQuery.contains('tutorial') ||
                  lowerQuery.contains('bantuan') ||
                  lowerQuery.contains('helper')) {
                extraOptions.add(
                  MenuSearchOption(
                    menu: NavMenu.dashboard,
                    actionType: 'open_tutorial',
                    customSubtitle: '📘 Buka Pusat Panduan & Tutorial Aplikasi',
                  ),
                );
              }

              final targetMonth = _extractMonthFromSearch(queryText);
              final targetRating = _extractRatingFromSearch(queryText);
              final targetStatus = _extractStatusFromSearch(queryText);
              final targetSentiment = _extractSentimentFromSearch(queryText);

              String menuKeyword = queryText;
              if (queryText.contains('/')) {
                menuKeyword = queryText.split('/').first.trim();
              } else {
                menuKeyword = queryText
                    .replaceAll(
                      RegExp(
                        r'\b(20\d{2}|januari|februari|maret|april|mei|juni|juli|agustus|september|oktober|november|desember|jan|feb|mar|apr|jun|jul|ags|agu|sep|okt|nov|des|bintang|star|rating|pending|terkirim|replied|positif|negatif|netral)\b',
                        caseSensitive: false,
                      ),
                      '',
                    )
                    .replaceAll('/', '')
                    .trim();
              }

              List<NavMenu> matchedMenus;
              if (menuKeyword.isEmpty) {
                matchedMenus = allMenus;
              } else {
                matchedMenus = allMenus.where((option) {
                  final lowerKey = menuKeyword.toLowerCase();
                  return option.translatedLabel
                          .toLowerCase()
                          .contains(lowerKey) ||
                      option.label.toLowerCase().contains(lowerKey);
                }).toList();

                if (matchedMenus.isEmpty) {
                  matchedMenus = allMenus;
                }
              }

              final menuOptions = matchedMenus.map(
                (m) => MenuSearchOption(
                  menu: m,
                  targetMonth: targetMonth,
                  targetRating: targetRating,
                  targetStatus: targetStatus,
                  targetSentiment: targetSentiment,
                ),
              ).toList();

              return [...extraOptions, ...menuOptions];
            },
            displayStringForOption: (option) => option.displayTitle,
            onSelected: (option) => _handleMenuSelection(option, context),
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 6,
                  shadowColor: Colors.black.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  color: isDark ? const Color(0xFF1E222B) : Colors.white,
                  child: Container(
                    width: 380,
                    constraints: const BoxConstraints(maxHeight: 280),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2E3440)
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      shrinkWrap: true,
                      itemCount: options.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        thickness: 1,
                        color: isDark
                            ? const Color(0xFF2E3440)
                            : Colors.grey.shade100,
                      ),
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          leading: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              option.menu.icon,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            option.displayTitle,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          subtitle: option.displaySubtitle != null
                              ? Row(
                                  children: [
                                    const Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 11,
                                      color: Colors.blueAccent,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        option.displaySubtitle!,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: Colors.grey.shade400,
                          ),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
            fieldViewBuilder:
                (context, textEditingController, focusNode, onFieldSubmitted) {
              return ValueListenableBuilder<TextEditingValue>(
                valueListenable: textEditingController,
                builder: (context, value, child) {
                  return Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E222B)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2E3440)
                            : const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      focusNode: focusNode,
                      controller: textEditingController,
                      onSubmitted: (val) {
                        final targetMonth = _extractMonthFromSearch(val);
                        final targetRating = _extractRatingFromSearch(val);
                        final targetStatus = _extractStatusFromSearch(val);
                        final targetSentiment = _extractSentimentFromSearch(val);

                        if (val.toLowerCase().contains('pengaturan') ||
                            val.toLowerCase().contains('setting')) {
                          _handleMenuSelection(
                            MenuSearchOption(
                              menu: NavMenu.dashboard,
                              actionType: 'open_settings',
                            ),
                            context,
                          );
                          return;
                        }

                        String menuKey = val;
                        if (val.contains('/')) {
                          menuKey = val.split('/').first.trim();
                        }
                        final role = controller.userProfile.value?.role;
                        final all = NavMenu.byRole(role);
                        final match = all.firstWhere(
                          (m) =>
                              m.translatedLabel
                                  .toLowerCase()
                                  .contains(menuKey.toLowerCase()) ||
                              m.label
                                  .toLowerCase()
                                  .contains(menuKey.toLowerCase()),
                          orElse: () => NavMenu.balas,
                        );
                        _handleMenuSelection(
                          MenuSearchOption(
                            menu: match,
                            targetMonth: targetMonth,
                            targetRating: targetRating,
                            targetStatus: targetStatus,
                            targetSentiment: targetSentiment,
                          ),
                          context,
                        );
                      },
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Cari menu / tanggal (misal: / 2026-09)',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade400,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 18,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade500,
                        ),
                        suffixIcon: value.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: Colors.grey.shade400,
                                ),
                                onPressed: () {
                                  textEditingController.clear();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      actions: [
        const SizedBox(width: 4),
        PopupMenuButton<void>(
          tooltip: 'Notifikasi',
          icon: Obx(() {
            final count = controller.unreadCount.value;
            return Badge(
              label: Text(count.toString()),
              isLabelVisible: count > 0,
              child: Icon(
                Icons.notifications_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }),
          offset: const Offset(0, 42),
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.15),
          shape: const ChatBubbleShapeBorder(arrowOffset: 16, borderRadius: 16),
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E222B)
              : Colors.white,
          itemBuilder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return [
              PopupMenuItem<void>(
                enabled: false,
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Obx(() {
                    final items = controller.notifications;
                    final count = controller.unreadCount.value;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.notifications_active_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Notifikasi Sistem',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            if (count > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$count Baru',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Divider(
                          height: 1,
                          color: isDark
                              ? const Color(0xFF2E3440)
                              : Colors.grey.shade100,
                        ),
                        const SizedBox(height: 10),

                        // Notifications List
                        if (items.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text(
                                'Tidak ada notifikasi',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                          )
                        else
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 250),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              itemCount: items.length,
                              separatorBuilder: (_, index) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, idx) {
                                final notif = items[idx];
                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    controller.markNotificationAsRead(notif.id);
                                    Navigator.of(context).pop();
                                  },
                                  child: Opacity(
                                    opacity: notif.isRead ? 0.6 : 1.0,
                                    child: _buildNotificationItem(
                                      title: notif.title,
                                      time: formatTimeAgo(notif.createdAt),
                                      desc: notif.body,
                                      icon: _getIconData(notif),
                                      iconColor: _getIconColor(notif),
                                      isDark: isDark,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 12),
                        Divider(
                          height: 1,
                          color: isDark
                              ? const Color(0xFF2E3440)
                              : Colors.grey.shade100,
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            controller.markAllNotificationsAsRead();
                            Navigator.of(context).pop();
                          },
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                'Tandai semua telah dibaca',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ];
          },
        ),
        Builder(
          builder: (context) => IconButton(
            tooltip: 'settings_title'.tr,
            icon: Icon(
              Icons.settings_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String time,
    required String desc,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(fontSize: 8, color: Colors.grey.shade500),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inSeconds < 60) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  IconData _getIconData(NotificationModel notif) {
    final title = notif.title.toLowerCase();
    final rating = notif.rating;
    if (rating != null && rating <= 2) {
      return Icons.warning_amber_rounded;
    }
    if (title.contains('negatif') ||
        title.contains('warning') ||
        title.contains('error')) {
      return Icons.warning_amber_rounded;
    }
    if (title.contains('terkirim') ||
        title.contains('sukses') ||
        title.contains('success')) {
      return Icons.check_circle_rounded;
    }
    return Icons.rss_feed_rounded;
  }

  Color _getIconColor(NotificationModel notif) {
    final title = notif.title.toLowerCase();
    final rating = notif.rating;
    if (rating != null && rating <= 2) {
      return const Color(0xFFF59E0B);
    }
    if (title.contains('negatif') ||
        title.contains('warning') ||
        title.contains('error')) {
      return const Color(0xFFEF4444);
    }
    if (title.contains('terkirim') ||
        title.contains('sukses') ||
        title.contains('success')) {
      return const Color(0xFF10B981);
    }
    return const Color(0xFF6366F1);
  }

  @override
  Size get preferredSize => Size.fromHeight(Get.context!.isTablet ? 50 : 60);
}

class ChatBubbleShapeBorder extends ShapeBorder {
  final double arrowWidth;
  final double arrowHeight;
  final double arrowOffset;
  final double borderRadius;

  const ChatBubbleShapeBorder({
    this.arrowWidth = 14.0,
    this.arrowHeight = 8.0,
    this.arrowOffset = 24.0,
    this.borderRadius = 12.0,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.only(top: arrowHeight);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final r = borderRadius;
    final ah = arrowHeight;
    final aw = arrowWidth;

    final arrowX = rect.right - arrowOffset - (aw / 2);

    final path = Path()
      ..moveTo(rect.left + r, rect.top + ah)
      // Top arrow
      ..lineTo(arrowX - (aw / 2), rect.top + ah)
      ..lineTo(arrowX, rect.top)
      ..lineTo(arrowX + (aw / 2), rect.top + ah)
      // Top-right corner
      ..lineTo(rect.right - r, rect.top + ah)
      ..arcToPoint(
        Offset(rect.right, rect.top + ah + r),
        radius: Radius.circular(r),
      )
      // Bottom-right corner
      ..lineTo(rect.right, rect.bottom - r)
      ..arcToPoint(
        Offset(rect.right - r, rect.bottom),
        radius: Radius.circular(r),
      )
      // Bottom-left corner
      ..lineTo(rect.left + r, rect.bottom)
      ..arcToPoint(
        Offset(rect.left, rect.bottom - r),
        radius: Radius.circular(r),
      )
      // Top-left corner
      ..lineTo(rect.left, rect.top + ah + r)
      ..arcToPoint(
        Offset(rect.left + r, rect.top + ah),
        radius: Radius.circular(r),
      )
      ..close();

    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
