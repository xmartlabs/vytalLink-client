import 'package:auto_route/auto_route.dart';
import 'package:flutter_template/ui/home/home_screen.dart';
import 'package:flutter_template/ui/section/section_router.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(
  replaceInRouteName: 'Page|Screen|Router,Route',
)
class AppRouter extends _$AppRouter {
  @override
  final List<AutoRoute> routes;
  final String? initialRoute;

  AppRouter({this.initialRoute})
      : routes = [
          AutoRoute(
            page: AuthenticatedSectionRoute.page,
            path: '/',
            children: [
              RedirectRoute(path: '', redirectTo: initialRoute ?? 'home'),
              AutoRoute(path: 'home', page: HomeRoute.page),
            ],
          ),
        ];
}
