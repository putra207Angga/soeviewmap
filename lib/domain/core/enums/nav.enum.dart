part of 'main.enums.dart';

enum NavMenu {
  dashboard(icon: Icons.grid_view, label: 'Dashboard', route: Routes.dahsboard),
  templet(icon: Icons.edit_document, label: 'Template', route: Routes.template),
  review(icon: Icons.star_rounded, label: 'Review', route: Routes.review),
  balas(icon: Icons.chat_bubble_rounded, label: 'Balas', route: Routes.balas),
  logBot(icon: Icons.android_rounded, label: 'Log Bot', route: Routes.logBot);

  final IconData icon;
  final String label;
  final String route;

  const NavMenu({required this.icon, required this.label, required this.route});
  static List<NavMenu> get headerNav => [dashboard, templet];

  String get translatedLabel {
    switch (this) {
      case NavMenu.dashboard:
        return 'nav_dashboard'.tr;
      case NavMenu.templet:
        return 'nav_template'.tr;
      case NavMenu.review:
        return 'nav_review'.tr;
      case NavMenu.balas:
        return 'nav_balas'.tr;
      case NavMenu.logBot:
        return 'nav_log_bot'.tr;
    }
  }

  static List<NavMenu> byRole(String? role) {
    if (role?.toLowerCase() == 'pde') {
      return NavMenu.values;
    }
    return NavMenu.values.where((menu) => menu != NavMenu.logBot).toList();
  }
}
