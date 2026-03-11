import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/bloc/base/base_state.dart';

extension BaseEmitter<TState extends BaseState> on Emitter<TState> {
  void logCall(TState state) {
    log("call(${state.runtimeType.toString()})",
        name: "STATE", error: state.properties.toString());
    call(state);
  }
}