part of 'controllers_bindings.dart';

class TemplateControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TemplateController>(() => TemplateController());
  }
}
