import 'package:get/get.dart';
import 'package:soeviewmap/domain/main.domains.dart';
import 'package:soeviewmap/infrastructure/main.infrastructures.dart';

class HomeController extends GetxController {
  //todo: Implement HomeController

  final selectedNavIndex = NavMenu.dashboard.obs;
  @override
  void onInit() {
    super.onInit();
    ever(selectedNavIndex, (callback) {
      final getNav = Nav.routes.first.children.singleWhere(
        (e) => e.name == callback.route,
        orElse: () => Nav.routes.first.children.first,
      );
      // Mengaktifkan dependencies/bindings secara manual untuk sub-route terpilih
      // getNav.binding?.dependencies();
      for (final binding in getNav.bindings) {
        binding.dependencies();
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void toNavigation(int index) {
    final menu = NavMenu.values.firstWhere((e) => e.index == index);
    selectedNavIndex.value = menu;
  }
}
