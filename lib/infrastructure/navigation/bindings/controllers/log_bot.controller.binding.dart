import 'package:get/get.dart';

import '../../../../presentation/home/pages/logBot/controllers/log_bot.controller.dart';

class LogBotControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LogBotController>(
      () => LogBotController(),
    );
  }
}
