part of 'main.platform.dart';

class MobileHome extends GetView<HomeController> {
  const MobileHome({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      extendBody: true,
      endDrawer: const SettingsDrawer(),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF13151A) : Colors.white.withOpacity(0.9),
        elevation: 0,
        scrolledUnderElevation: 1.5,
        title: Obx(
          () => Text(
            controller.selectedNavIndex.value.translatedLabel,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        actions: [
          PopupMenuButton<void>(
            tooltip: 'Notifikasi',
            icon: Obx(() {
              final count = controller.unreadCount.value;
              return Badge(
                label: Text(count.toString()),
                isLabelVisible: count > 0,
                child: Icon(
                  Icons.notifications_outlined,
                  color: isDark ? Colors.grey.shade300 : Colors.black54,
                ),
              );
            }),
            offset: const Offset(0, 42),
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.15),
            shape: const ChatBubbleShapeBorder(
              arrowOffset: 16,
              borderRadius: 16,
            ),
            color: isDark ? const Color(0xFF1E222B) : Colors.white,
            itemBuilder: (context) {
              return [
                PopupMenuItem<void>(
                  enabled: false,
                  child: Container(
                    width: 280,
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
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Notifikasi Sistem',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
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
                          Divider(height: 1, color: Colors.grey.shade100),
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
                                      controller.markNotificationAsRead(
                                        notif.id,
                                      );
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
                                        isDark: false,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          const SizedBox(height: 12),
                          Divider(height: 1, color: Colors.grey.shade100),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              controller.markAllNotificationsAsRead();
                              Navigator.of(context).pop();
                            },
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Text(
                                  'Tandai semua telah dibaca',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
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

          const SizedBox(width: 8),
          Builder(
            builder: (context) => IconButton(
              icon: Icon(
                Icons.settings_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.logout_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              SecureStorageServices.to.writeBool('is_logged_in', false);
              SecureStorageServices.to.writeBool('is_locked', false);
              Get.offAllNamed(
                Routes.authentifikasi,
                arguments: {'mode': 'login'},
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: isDark ? const Color(0xFF2E3440) : Colors.grey.shade100,
            height: 1,
          ),
        ),
      ),
      body: SafeArea(bottom: false, child: child),
      bottomNavigationBar: _buildGlassmorphicBottomBar(context),
    );
  }

  Widget _buildGlassmorphicBottomBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      height: 64,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13151A).withOpacity(0.9) : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3440) : Colors.white.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Obx(() {
          final items = NavMenu.byRole(controller.userProfile.value?.role);
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((menu) {
              final isSelected = controller.selectedNavIndex.value == menu;
              return GestureDetector(
                onTap: () => controller.toNavigation(menu.index),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  height: 64,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary.withOpacity(0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          menu.icon,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : (isDark ? Colors.grey.shade400 : Colors.grey.shade500),
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isSelected ? 4 : 0,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.4),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ),
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
}
