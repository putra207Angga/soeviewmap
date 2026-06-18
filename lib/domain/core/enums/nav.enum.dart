part of 'main.enums.dart';

enum NavMenu {
  dashboard(icon: Icons.grid_view, label: 'Dashboard', route: Routes.dahsboard),
  templet(icon: Icons.edit_document, label: 'Template', route: Routes.template),
  review(icon: Icons.star_rounded, label: 'Review', route: Routes.review),
  balas(icon: Icons.chat_bubble_rounded, label: 'Balas', route: Routes.balas);

  final IconData icon;
  final String label;
  final String route;

  const NavMenu({required this.icon, required this.label, required this.route});
  static List<NavMenu> get headerNav => [dashboard, templet];
}
