part of 'main.components.dart';

class AppBarComponent extends StatelessWidget implements PreferredSizeWidget {
  const AppBarComponent({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 8,
      backgroundColor: Colors.white,
      foregroundColor: Theme.of(context).cardColor,
      title: Autocomplete<NavMenu>(
        optionsBuilder: (text) {
          final items = NavMenu.byRole(controller.userProfile.value?.role);
          if (text.text.isEmpty) {
            return items;
          }
          return items.where((option) {
            return option.label.toLowerCase().contains(text.text.toLowerCase());
          });
        },
        displayStringForOption: (option) => option.label,
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
                title: Text(option.label),
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
                    hintText: 'Cari menu...',
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
          icon: Icon(
            Icons.notifications_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
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
                  child: Column(
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
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
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
                              '3 Baru',
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
                      _buildNotificationItem(
                        title: 'Auto-Reply Bintang 5 Terkirim',
                        time: '2m ago',
                        desc:
                            'Bot membalas ulasan dari Agus Santoso (Poliklinik Kebidanan).',
                        icon: Icons.check_circle_rounded,
                        iconColor: const Color(0xFF10B981),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      _buildNotificationItem(
                        title: 'Ulasan Negatif Masuk (IGD)',
                        time: '15m ago',
                        desc:
                            'Ulasan bintang 2 masuk. Memerlukan peninjauan manual.',
                        icon: Icons.warning_amber_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      _buildNotificationItem(
                        title: 'Webhook Terkoneksi',
                        time: '1h ago',
                        desc: 'Server auto-reply bot berhasil tersinkronisasi.',
                        icon: Icons.rss_feed_rounded,
                        iconColor: const Color(0xFF6366F1),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      Divider(
                        height: 1,
                        color: isDark
                            ? const Color(0xFF2E3440)
                            : Colors.grey.shade100,
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Tandai semua telah dibaca',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
        ),
        const SizedBox(width: 4),
        if (!context.isTablet) ...{
          Builder(
            builder: (context) => IconButton(
              icon: Icon(
                Icons.settings_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
          const SizedBox(width: 4),
        },
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
