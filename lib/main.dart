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
    final isDark = SecureStorageServices.to.readBool('settings_dark_mode', defaultValue: false);
    return GetMaterialApp(
      builder: (context, child) =>
          Material(child: EnvironmentsBadge(child: child ?? SizedBox.shrink())),
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF6366F1),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF8B5CF6),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF818CF8),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF818CF8),
          secondary: Color(0xFF9F7AEA),
        ),
      ),
      initialRoute: initialRoute,
      getPages: Nav.routes,
      translations: AppTranslation(),
      locale: TranslationService.getSavedLocale(),
      fallbackLocale: const Locale('id', 'ID'),
    );
  }
}
