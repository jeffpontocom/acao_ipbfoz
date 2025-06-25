import 'package:flutter_modular/flutter_modular.dart';

import 'main.dart';
import 'view/admin_page.dart';
import 'view/diacono_page.dart';
import 'view/familia_page.dart';
import 'view/home_page.dart';
import 'view/login_page.dart';

class AppModule extends Module {
  @override
  void routes(RouteManager r) {
    r.child(
      '/',
      guards: [AuthGuard()],
      child: (context) {
        return HomePage();
      },
    );
    r.child(
      '/login',
      child: (context) {
        return LoginPage();
      },
    );
    r.child(
      '/admin',
      guards: [AuthGuard()],
      child: (context) {
        return AdminPage();
      },
    );
    r.child(
      '/diacono',
      guards: [AuthGuard(), HasQueryGuard()],
      child: (context) {
        return DiaconoPage(id: r.args.queryParams['id'] ?? '');
      },
    );
    r.child(
      '/familia',
      guards: [AuthGuard(), HasQueryGuard()],
      child: (context) {
        return FamiliaPage(id: r.args.queryParams['id'] ?? '');
      },
    );
  }
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
