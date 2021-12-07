import 'package:acao_ipbfoz/view/admin_page.dart';
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
      child: (_, __) => const HomePage(),
      guards: [AuthGuard()],
    ),
    ChildRoute(
      '/login',
      child: (_, __) => const LoginPage(),
      transition: TransitionType.fadeIn,
    ),
    ChildRoute(
      '/admin',
      child: (_, __) => const AdminPage(),
      transition: TransitionType.downToUp,
      guards: [AuthGuard()],
    ),
    ChildRoute(
      '/diacono',
      child: (_, args) => DiaconoPage(diaconoId: args.queryParams['id'] ?? ''),
      transition: TransitionType.rightToLeftWithFade,
      guards: [AuthGuard(), HasQueryGuard()],
    ),
    ChildRoute(
      '/familia',
      child: (_, args) => FamiliaPage(referenceId: args.queryParams['id']),
      transition: TransitionType.leftToRightWithFade,
      guards: [AuthGuard()],
    ),
    WildcardRoute(child: (_, __) => const HomePage()),
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

class HasQueryGuard extends RouteGuard {
  HasQueryGuard() : super(redirectTo: '/');

  @override
  // ignore: avoid_renaming_method_parameters
  Future<bool> canActivate(String path, ModularRoute router) async {
    return router.uri.hasQuery;
  }
}
