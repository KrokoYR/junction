import 'package:fin_zero_id/pages/home_page.dart';
import 'package:fin_zero_id/log.dart';
import 'package:fin_zero_id/pages/onboarding_step_1_page.dart';
import 'package:fin_zero_id/pages/onboarding_step_2_page.dart';
import 'package:fin_zero_id/pages/onboarding_step_3_page.dart';
import 'package:fin_zero_id/pages/onboarding_step_4_page.dart';
import 'package:fin_zero_id/pages/profile_page.dart';
import 'package:fin_zero_id/pages/qr_page.dart';
import 'package:fin_zero_id/services/prefs_service.dart';
import 'package:flutter/material.dart';

const _tag = 'route_service';

class RouteService {
  RouteService({
    required PrefsService prefs,
  }) : _prefs = prefs {
    _init();
  }

  final PrefsService _prefs;

  final navigatorKey = GlobalKey<NavigatorState>();

  final namedRoutes = {
    HomePage.routeName: (_) => const HomePage(),
    OnboardingStep1Page.routeName: (_) => const OnboardingStep1Page(),
    ProfilePage.routeName: (_) => const ProfilePage(),
    QrPage.routeName: (_) => const QrPage(),
  };

  final initialRoute = HomePage.routeName;

  late final _defaultRoute = _buildRoute(
    RouteSettings(
      name: HomePage.routeName,
    ),
  )!;

  void _init() {
    Log.d(_tag, '_init');
  }

  List<Route<dynamic>> onGenerateInitialRoutes(String initialRoute) {
    Log.d(_tag, 'onGenerateInitialRoutes: $initialRoute');

    if (_prefs.getId() == null) {
      return [_defaultRoute];
    } else {
      return [
        _buildRoute(
          RouteSettings(
            name: ProfilePage.routeName,
          ),
        )!,
      ];
    }
  }

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    Log.d(_tag, 'onGenerateRoute $settings');

    return _buildRoute(settings);
  }

  Route<dynamic>? _buildRoute(RouteSettings settings) {
    Log.d(_tag, '_buildRoute $settings');

    Widget page;
    bool fullscreenDialog = false;
    bool opaque = true;
    final arguments = settings.arguments;

    switch (settings.name) {
      case HomePage.routeName:
        page = const HomePage();
        break;
      case OnboardingStep2Page.routeName:
        page = OnboardingStep2Page(
          arguments: arguments as OnboardingStep2PageArguments,
        );
        break;
      case OnboardingStep3Page.routeName:
        page = OnboardingStep3Page(
          arguments: arguments as OnboardingStep3PageArguments,
        );
        break;
      case OnboardingStep4Page.routeName:
        page = OnboardingStep4Page(
          arguments: arguments as OnboardingStep4PageArguments,
        );
        break;
      case ProfilePage.routeName:
        page = const ProfilePage();
        break;
      default:
        return null;
    }

    return TransparentPageRoute<dynamic>(
      settings: settings,
      builder: (_) => page,
      fullscreenDialog: fullscreenDialog,
      opaque: opaque,
    );
  }
}

class TransparentPageRoute<T> extends MaterialPageRoute<T> {
  bool _opaque = true;

  TransparentPageRoute({
    required super.builder,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
    bool opaque = true,
  }) {
    _opaque = opaque;
  }

  @override
  bool get opaque => _opaque;
}
