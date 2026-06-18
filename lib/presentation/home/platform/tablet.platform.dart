part of 'main.platform.dart';

class TabletHome extends GetView<HomeController> {
  const TabletHome({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Row(
        children: [
          _buildCollapsedSidebar(context),
          Expanded(
            child: Scaffold(
              appBar: AppBarComponent(controller: controller),
              endDrawer: const SettingsDrawer(),
              body: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedSidebar(BuildContext context) {
    final items = NavMenu.values;
    return Container(
      width: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // Brand Logo
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.map_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // User Avatar with Status Indicator
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
                child: const Center(
                  child: Text(
                    'SA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Collapsed navigation items
          Expanded(
            child: Obx(
              () => ListView.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final menu = items[index];
                  final isSelected = controller.selectedNavIndex.value == menu;
                  return Tooltip(
                    message: menu.label,
                    preferBelow: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: InkWell(
                        onTap: () => controller.toNavigation(menu.index),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [
                                      const Color(0xFF6366F1).withOpacity(0.08),
                                      const Color(0xFF8B5CF6).withOpacity(0.03),
                                    ],
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF6366F1).withOpacity(0.15)
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                menu.icon,
                                color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade500,
                                size: 20,
                              ),
                              // Glowing left indicator line (very subtle inside button)
                              if (isSelected)
                                Positioned(
                                  left: 2,
                                  child: Container(
                                    width: 3,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          Divider(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 8),
          
          // Bottom Actions
          Tooltip(
            message: 'Lock Screen',
            preferBelow: false,
            child: IconButton(
              icon: const Icon(Icons.lock_outline_rounded, color: Colors.black54, size: 18),
              onPressed: () {
                SecureStorageServices.to.writeBool('is_locked', true);
                Get.offAllNamed(Routes.authentifikasi, arguments: {'mode': 'lock'});
              },
            ),
          ),
          Tooltip(
            message: 'Logout',
            preferBelow: false,
            child: IconButton(
              icon: Icon(Icons.logout_rounded, color: Colors.redAccent.shade200, size: 18),
              onPressed: () {
                SecureStorageServices.to.writeBool('is_logged_in', false);
                SecureStorageServices.to.writeBool('is_locked', false);
                Get.offAllNamed(Routes.authentifikasi, arguments: {'mode': 'login'});
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
