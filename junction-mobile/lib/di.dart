import 'package:fin_zero_id/services/api_service.dart';
import 'package:fin_zero_id/services/prefs_service.dart';
import 'package:fin_zero_id/services/route_service.dart';
import 'package:fin_zero_id/services/secrets_service.dart';
import 'package:get_it/get_it.dart';

final di = GetIt.instance;

extension GetItEx on GetIt {
  Future<void> setup() => setupDi();
}

Future<void> setupDi() async {
  di.registerSingleton<PrefsService>(
    PrefsService(),
  );

  di.registerSingleton<RouteService>(
    RouteService(
      prefs: di.get(),
    ),
  );

  di.registerSingleton<SecretsService>(
    SecretsService(prefs: di.get()),
  );

  di.registerSingleton<ApiService>(ApiService());

  return di.allReady();
}
