import 'infrastructure/main.infrastructures.dart';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize and register SecureStorageServices
  final secureStorage = SecureStorageServices();
  await secureStorage.init();
  Get.put<SecureStorageServices>(secureStorage, permanent: true);

  var initialRoute = await Routes.initialRoute;
  Get.put(ConfigEnvironments());
  Get.put(ApiService());
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
