import 'infrastructure/main.infrastructures.dart';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize SecureStorageServices and load env keys before other services
  Get.put<SecureStorageServices>(SecureStorageServices(), permanent: true);
  // Register ConfigEnvironments after SecureStorage loads keys
  Get.put<ConfigEnvironments>(ConfigEnvironments());
  // Initialize SecureStorageServices for env keys before other services
  // Initialise configuration (load decryption keys)
  await ConfigEnvironments.to.initialize();
  // Register ApiService after ConfigEnvironments is ready
  Get.put<ApiService>(ApiService());
  var initialRoute = await Routes.initialRoute;
  runApp(Main(initialRoute));
}

class Main extends StatelessWidget {
  final String initialRoute;
  const Main(this.initialRoute, {super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      builder: (context, child) =>
          Material(child: EnvironmentsBadge(child: child ?? SizedBox.shrink())),
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      initialRoute: initialRoute,
      getPages: Nav.routes,
    );
  }
}
