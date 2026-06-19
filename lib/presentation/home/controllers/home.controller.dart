import 'package:get/get.dart';
import 'package:soeviewmap/domain/main.domains.dart';
import 'package:soeviewmap/infrastructure/main.infrastructures.dart';

class HomeController extends GetxController {
  final selectedNavIndex = NavMenu.dashboard.obs;
  final userProfile = Rxn<UserProfile>();
  final isLoadingProfile = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
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

  Future<void> fetchUserProfile() async {
    isLoadingProfile.value = true;
    print('HomeController: Starting fetchUserProfile...');
    try {
      final response = await AuthDao.getProfile();
      print(
        'HomeController: Profile loaded successfully: ${response.request!.headers}',
      );
      if (response.statusCode == 200 && response.body != null) {
        userProfile.value = response.body;
        print(
          'HomeController: Profile loaded successfully: ${userProfile.value?.name}',
        );
      }
    } catch (e) {
      print('HomeController: Exception in fetchUserProfile: $e');
    } finally {
      isLoadingProfile.value = false;
      print(
        'HomeController: fetchUserProfile finished. isLoadingProfile: ${isLoadingProfile.value}',
      );
    }
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
