import 'package:fin_zero_id/app/app.dart';
import 'package:fin_zero_id/di.dart';
import 'package:fin_zero_id/services/prefs_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await di.setup();
  await di.get<PrefsService>().init();

  runApp(const App());
}
