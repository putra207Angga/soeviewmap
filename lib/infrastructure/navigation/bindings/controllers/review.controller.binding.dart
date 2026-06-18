part of 'controllers_bindings.dart';

class ReviewControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReviewController>(() => ReviewController());
  }
}
