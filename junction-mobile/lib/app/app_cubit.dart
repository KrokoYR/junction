import 'dart:async';

import 'package:fin_zero_id/app/app_cubit_state.dart';
import 'package:fin_zero_id/di.dart';
import 'package:fin_zero_id/log.dart';
import 'package:fin_zero_id/services/route_service.dart';
import 'package:flutter/material.dart';
import 'package:fin_zero_id/utils/fin_cubit.dart';

const _tag = 'app_cubit';

class AppCubit extends FinCubit<AppCubitState> with WidgetsBindingObserver {
  AppCubit()
      : _routeService = di.get(),
        super(
          AppCubitState((b) => b),
        ) {
    _init();
  }

  final RouteService _routeService;

  GlobalKey<NavigatorState> get navigatorKey => _routeService.navigatorKey;

  Map<String, WidgetBuilder> get namedRoutes => _routeService.namedRoutes;

  String get initialRoute => _routeService.initialRoute;

  RouteFactory get onGenerateRoute => _routeService.onGenerateRoute;

  InitialRouteListFactory get onGenerateInitialRoutes =>
      _routeService.onGenerateInitialRoutes;

  void _init() {
    Log.d(_tag, '_init');
  }

  @override
  Future<void> close() async {
    await super.close();
  }
}
