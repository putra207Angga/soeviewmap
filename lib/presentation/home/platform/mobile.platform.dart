part of 'main.platform.dart';

class MobileHome extends GetView<HomeController> {
  const MobileHome({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      endDrawer: const SettingsDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        scrolledUnderElevation: 1.5,
        title: Obx(
          () => Text(
            controller.selectedNavIndex.value.label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
        ),
        actions: [
          PopupMenuButton<void>(
            tooltip: 'Notifikasi',
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.black54,
            ),
            offset: const Offset(0, 42),
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.15),
            shape: const ChatBubbleShapeBorder(
              arrowOffset: 16,
              borderRadius: 16,
            ),
            color: Colors.white,
            itemBuilder: (context) {
              return [
                PopupMenuItem<void>(
                  enabled: false,
                  child: Container(
                    width: 280,
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                        Divider(height: 1, color: Colors.grey.shade100),
                        const SizedBox(height: 10),
                        _buildNotificationItem(
                          title: 'Auto-Reply Bintang 5 Terkirim',
                          time: '2m ago',
                          desc: 'Bot membalas ulasan dari Agus Santoso (Poliklinik Kebidanan).',
                          icon: Icons.check_circle_rounded,
                          iconColor: const Color(0xFF10B981),
                          isDark: false,
                        ),
                        const SizedBox(height: 10),
                        _buildNotificationItem(
                          title: 'Ulasan Negatif Masuk (IGD)',
                          time: '15m ago',
                          desc: 'Ulasan bintang 2 masuk. Memerlukan peninjauan manual.',
                          icon: Icons.warning_amber_rounded,
                          iconColor: const Color(0xFFF59E0B),
                          isDark: false,
                        ),
                        const SizedBox(height: 10),
                        _buildNotificationItem(
                          title: 'Webhook Terkoneksi',
                          time: '1h ago',
                          desc: 'Server auto-reply bot berhasil tersinkronisasi.',
                          icon: Icons.rss_feed_rounded,
                          iconColor: const Color(0xFF6366F1),
                          isDark: false,
                        ),
                        const SizedBox(height: 12),
                        Divider(height: 1, color: Colors.grey.shade100),
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
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.black54),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade100, height: 1),
        ),
      ),
      body: SafeArea(bottom: false, child: child),
      bottomNavigationBar: _buildGlassmorphicBottomBar(context),
    );
  }

  Widget _buildGlassmorphicBottomBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Obx(
          () {
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
                              ? Colors.blue.shade50
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          menu.icon,
                          color: isSelected
                              ? Colors.blue
                              : Colors.grey.shade500,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isSelected ? 4 : 0,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.4),
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
        },
      ),
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
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.grey.shade500,
                    ),
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
}
