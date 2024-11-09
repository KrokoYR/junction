import 'package:built_value/built_value.dart';

part 'app_cubit_state.g.dart';

abstract class AppCubitState
    implements Built<AppCubitState, AppCubitStateBuilder> {
  factory AppCubitState([void Function(AppCubitStateBuilder) updates]) =
      _$AppCubitState;

  AppCubitState._();
}
