import 'package:get/get.dart';

import '../../../../presentation/authentifikasi/controllers/authentifikasi.controller.dart';

class AuthentifikasiControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthentifikasiController>(
      () => AuthentifikasiController(),
    );
  }
}
