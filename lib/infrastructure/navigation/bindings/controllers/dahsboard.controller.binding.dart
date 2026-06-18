part of 'controllers_bindings.dart';

class DahsboardControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DahsboardController>(() => DahsboardController());
  }
}
