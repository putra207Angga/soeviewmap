part of 'main.components.dart';

class AppBarComponent extends StatelessWidget implements PreferredSizeWidget {
  const AppBarComponent({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 8,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF13151A)
          : Colors.white,
      foregroundColor: Theme.of(context).cardColor,
      title: Autocomplete<NavMenu>(
        optionsBuilder: (text) {
          final items = NavMenu.byRole(controller.userProfile.value?.role);
          if (text.text.isEmpty) {
            return items;
          }
          return items.where((option) {
            return option.translatedLabel.toLowerCase().contains(text.text.toLowerCase()) ||
                option.label.toLowerCase().contains(text.text.toLowerCase());
          });
        },
        displayStringForOption: (option) => option.translatedLabel,
        onSelected: (value) => controller.toNavigation(value.index),
        optionsViewBuilder: (context, onSelected, options) => Material(
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(5)),
            side: BorderSide.none,
          ),
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E222B)
              : Colors.white,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options.elementAt(index);
              return ListTile(
                title: Text(option.translatedLabel),
                onTap: () => onSelected(option),
              );
            },
          ),
        ),
        fieldViewBuilder:
            (context, textEditingController, focusNode, onFieldSubmitted) =>
                TextField(
                  focusNode: focusNode,
                  controller: textEditingController,
                  onEditingComplete: onFieldSubmitted,
                  decoration: InputDecoration(
                    hintText: 'search_menu'.tr,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
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
