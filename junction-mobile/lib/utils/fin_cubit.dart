import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FinCubit<State> extends Cubit<State> {
  FinCubit(super.initialState);

  @override
  void emit(State state) {
    if (isClosed) return;
    super.emit(state);
  }
}
