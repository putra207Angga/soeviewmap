part of 'controllers_bindings.dart';

class BalasControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BalasController>(() => BalasController());
  }
}
