import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:soeviewmap/domain/main.domains.dart';
import 'package:soeviewmap/presentation/screens.dart';
import 'package:soeviewmap/infrastructure/main.infrastructures.dart';

import '../components/main.components.dart';
import '../pages/template/components/main.components.dart';

part 'dekstop.platform.dart';
part 'mobile.platform.dart';
part 'tablet.platform.dart';

class ResponsiveHome extends GetView<HomeController> {
  const ResponsiveHome({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // context.width registers a dependency on MediaQuery,
    // causing this widget to rebuild automatically when the viewport is resized.
    final width = context.width;

    if (width < 600) {
      return MobileHome(child: child);
    } else if (width < 1000) {
      return TabletHome(child: child);
    } else {
      return DesktopHome(child: child);
    }
  }
}
