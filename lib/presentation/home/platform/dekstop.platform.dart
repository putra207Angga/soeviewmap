part of 'main.platform.dart';

class DesktopHome extends GetView<HomeController> {
  const DesktopHome({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Row(
        children: [
          Sidebar(
            onNewOrderPressed: () {
              // 1. Switch active screen to Template tab
              controller.toNavigation(NavMenu.templet.index);
              
              // 2. Register TemplateController if not already registered
              if (!Get.isRegistered<TemplateController>()) {
                TemplateControllerBinding().dependencies();
              }
              final templateCtrl = Get.find<TemplateController>();
              
              // 3. Open create dialog
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) {
                  return CustomTemplateEditDialog(
                    controller: templateCtrl,
                  );
                },
              );
            },
            onLockScreenPressed: () {
              SecureStorageServices.to.writeBool('is_locked', true);
              Get.offAllNamed(Routes.authentifikasi, arguments: {'mode': 'lock'});
            },
            onLogoutPressed: () {
              SecureStorageServices.to.writeBool('is_logged_in', false);
              SecureStorageServices.to.writeBool('is_locked', false);
              Get.offAllNamed(Routes.authentifikasi, arguments: {'mode': 'login'});
            },
            onSelectedDestination: (value) => controller.toNavigation(value),
          ),
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
}
