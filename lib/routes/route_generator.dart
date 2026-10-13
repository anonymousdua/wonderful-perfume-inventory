import 'package:flutter/material.dart';

import '../views/add_perfume_screen.dart';
import '../views/add_seller_screen.dart';
import '../views/app_shell.dart';
import '../views/inventory_screen.dart';
import '../views/sales_screen.dart';
import '../views/splash_screen.dart';

class RouteGenerator {
  // Root navigator
  static const splash = '/';
  static const home = '/home';

  // Navigator inside the shell (the sidebar never moves)
  static const inventory = '/inventory';
  static const sales = '/sales';
  static const addSeller = '/add-seller';
  static const addPerfume = '/add-perfume';

  /// Root routes: splash -> shell.
  static Route<dynamic> generateRoute(RouteSettings setting) {
    final args = setting.arguments;

    switch (setting.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case home:
        if (args is String) {
          return MaterialPageRoute(builder: (_) => AppShell(title: args));
        }
        return MaterialPageRoute(
            builder: (_) => const AppShell(title: 'Wonderful Perfumes'));

      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }

  /// Routes shown in the content area, next to the fixed sidebar.
  static Route<dynamic> generateShellRoute(RouteSettings setting) {
    final Widget page;
    switch (setting.name) {
      case sales:
        page = const SalesScreen();
        break;
      case addSeller:
        page = const AddSellerScreen();
        break;
      case addPerfume:
        page = const AddPerfumeScreen();
        break;
      case inventory:
      default:
        page = const InventoryScreen();
    }
    // No transition animation, so switching tabs feels like a desktop app.
    return PageRouteBuilder(
      settings: setting,
      pageBuilder: (_, __, ___) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }
}
