part of 'controllers_bindings.dart';

class HomeControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<DahsboardController>(() => DahsboardController());
    Get.lazyPut<ReviewController>(() => ReviewController());
    Get.lazyPut<TemplateController>(() => TemplateController());
    Get.lazyPut<BalasController>(() => BalasController());
  }
}
