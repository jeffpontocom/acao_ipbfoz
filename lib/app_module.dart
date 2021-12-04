import 'package:flutter_modular/flutter_modular.dart';

import 'main.dart';
import 'view/diacono_page.dart';
import 'view/familia_page.dart';
import 'view/home_page.dart';
import 'view/login_page.dart';

class AppModule extends Module {
  @override
  final List<Bind> binds = [];

  @override
  final List<ModularRoute> routes = [
    ChildRoute(
      '/',
      child: (_, __) => HomePage(),
      guards: [AuthGuard()],
    ),
    ChildRoute(
      '/login',
      child: (_, __) => LoginPage(),
      transition: TransitionType.fadeIn,
    ),
    ChildRoute(
      '/diacono',
      child: (_, args) => DiaconoPage(diaconoId: args.queryParams['id']),
      transition: TransitionType.leftToRight,
      guards: [AuthGuard()],
    ),
    ChildRoute(
      '/familia',
      child: (_, args) => FamiliaPage(referenceId: args.queryParams['id']),
      transition: TransitionType.leftToRight,
      guards: [AuthGuard()],
    ),
    //WildcardRoute(child: (_, __) => NotFoundPage()),
  ];
}

class AuthGuard extends RouteGuard {
  AuthGuard() : super(redirectTo: '/login');

  @override
  // ignore: avoid_renaming_method_parameters
  Future<bool> canActivate(String path, ModularRoute router) async {
    return auth.currentUser != null;
  }
}
