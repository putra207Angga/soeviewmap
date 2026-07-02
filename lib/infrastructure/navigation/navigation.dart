part of 'main.navigations.dart';

class Nav {
  static List<GetPage> routes = [
    GetPage(
      name: Routes.home,
      page: () => const HomeScreen(),
      binding: HomeControllerBinding(),
      middlewares: [AuthMiddleware()],
      children: [
        GetPage(
          name: Routes.dahsboard,
          page: () => const DahsboardScreen(),
          binding: DahsboardControllerBinding(),
        ),
        GetPage(
          name: Routes.review,
          page: () => const ReviewScreen(),
          binding: ReviewControllerBinding(),
        ),
        GetPage(
          name: Routes.template,
          page: () => const TemplateScreen(),
          binding: TemplateControllerBinding(),
        ),
        GetPage(
          name: Routes.balas,
          page: () => const BalasScreen(),
          binding: BalasControllerBinding(),
        ),
        GetPage(
          name: Routes.logBot,
          page: () => const LogBotScreen(),
          binding: LogBotControllerBinding(),
        ),
      ],
    ),
    GetPage(
      name: Routes.authentifikasi,
      page: () => const AuthentifikasiScreen(),
      binding: AuthentifikasiControllerBinding(),
    ),
  ];
}
