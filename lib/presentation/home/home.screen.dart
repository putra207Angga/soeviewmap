import 'package:soeviewmap/domain/main.domains.dart';
import 'package:soeviewmap/presentation/screens.dart';
import 'package:flutter/material.dart';
import 'platform/main.platform.dart';
import 'package:get/get.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ResponsiveHome(
      child: Obx(() {
        switch (controller.selectedNavIndex.value) {
          case NavMenu.dashboard:
            return const DahsboardScreen();
          case NavMenu.review:
            return const ReviewScreen();
          case NavMenu.templet:
            return const TemplateScreen();
          case NavMenu.balas:
            return const BalasScreen();
        }
      }),
    );
  }
}
