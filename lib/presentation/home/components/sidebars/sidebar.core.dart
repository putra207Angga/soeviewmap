part of 'main.sidebars.dart';

class Sidebar extends GetView<HomeController> {
  const Sidebar({
    super.key,
    required this.onNewOrderPressed,
    required this.onLockScreenPressed,
    required this.onLogoutPressed,
    this.onSelectedDestination,
  });

  final VoidCallback onNewOrderPressed;
  final VoidCallback onLockScreenPressed;
  final VoidCallback onLogoutPressed;
  final ValueChanged<int>? onSelectedDestination;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 240, // Increased slightly for breathing room
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13151A) : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark ? const Color(0xFF2E3440) : Colors.grey.shade100,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header / Logo & Brand Section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.medical_services_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RSUD Soebandi',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 0.5,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Review Management',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // User Profile Card Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Obx(() {
              final user = controller.userProfile.value;
              final isLoading = controller.isLoadingProfile.value;

              String initials = 'U';
              String name = 'User';
              String role = 'Online';

              if (user != null) {
                name = user.name;
                role = user.role;
                if (name.trim().isNotEmpty) {
                  final parts = name.trim().split(' ');
                  if (parts.length >= 2) {
                    initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
                  } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
                    initials = parts[0][0].toUpperCase();
                  }
                }
              } else if (isLoading) {
                name = 'Loading...';
                role = 'Fetching profile';
                initials = '...';
              } else {
                name = 'Guest';
                role = 'Offline';
                initials = 'G';
              }

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E222B) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2E3440) : Colors.grey.shade100,
                  ),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        // Pulse status dot
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: user != null ? const Color(0xFF10B981) : Colors.grey,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            role,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color: user != null ? const Color(0xFF10B981) : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),

          const SizedBox(height: 12),

          // Action Button: New Template
          Obx(() {
            final isTemplateScreen = controller.selectedNavIndex.value == NavMenu.templet;
            if (isTemplateScreen) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text(
                    'New Template',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: -0.1,
                    ),
                  ),
                  onPressed: onNewOrderPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ).copyWith(
                    backgroundColor: WidgetStateProperty.resolveWith((
                      states,
                    ) {
                      if (states.contains(WidgetState.hovered)) {
                        return const Color(0xFF4F46E5);
                      }
                      return const Color(0xFF6366F1);
                    }),
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // Navigation Links
          Expanded(
            child: Obx(
              () => ListView(
                padding: EdgeInsets.zero,
                children: NavMenu.byRole(controller.userProfile.value?.role)
                    .map(
                      (menu) => SidebarItem(
                        icon: menu.icon,
                        label: menu.label,
                        selected: controller.selectedNavIndex.value == menu,
                        onTap: onSelectedDestination != null
                            ? () => onSelectedDestination?.call(menu.index)
                            : () {},
                      ),
                    )
                    .toList(),
              ),
            ),
          ),

          Divider(
            height: 1,
            color: isDark ? const Color(0xFF2E3440) : Colors.grey.shade100,
          ),
          const SizedBox(height: 8),

          // Bottom Utilities
          _buildUtilityItem(
            icon: Icons.lock_outline_rounded,
            label: 'Lock Screen',
            onTap: onLockScreenPressed,
            context: context,
          ),
          _buildUtilityItem(
            icon: Icons.logout_rounded,
            label: 'Logout',
            onTap: onLogoutPressed,
            isDestructive: true,
            context: context,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildUtilityItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required BuildContext context,
    bool isDestructive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          hoverColor: isDestructive
              ? Colors.red.shade50.withOpacity(0.4)
              : (isDark ? Colors.white10 : Colors.grey.shade50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isDestructive
                      ? Colors.redAccent.shade200
                      : Colors.grey.shade500,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDestructive
                        ? Colors.redAccent.shade200
                        : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                    letterSpacing: -0.15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
