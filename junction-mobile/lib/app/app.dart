import 'package:fin_zero_id/app/app_cubit.dart';
import 'package:fin_zero_id/app/app_cubit_state.dart';
import 'package:fin_zero_id/fin_colors.dart';
import 'package:fin_zero_id/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _cubit = AppCubit();
  late AppCubitState _state;

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppCubitState>(
      bloc: _cubit,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, AppCubitState state) {
    _state = state;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: MaterialApp(
        title: 'FinZeroID',
        debugShowCheckedModeBanner: false,
        navigatorKey: _cubit.navigatorKey,
        routes: _cubit.namedRoutes,
        initialRoute: _cubit.initialRoute,
        onGenerateRoute: _cubit.onGenerateRoute,
        onGenerateInitialRoutes: _cubit.onGenerateInitialRoutes,
        theme: ThemeData.from(
          colorScheme: const ColorScheme.dark(),
        ).copyWith(
          scaffoldBackgroundColor: FinColors.backgroundColor,
          useMaterial3: false,
        ),
      ),
    );
  }
}
