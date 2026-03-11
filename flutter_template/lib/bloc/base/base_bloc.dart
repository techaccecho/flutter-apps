import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/bloc/base/base_event.dart';
import 'package:flutter_template/bloc/base/base_state.dart';

abstract class AbstractBloc<TEvent extends BaseEvent, TState extends BaseState>
    extends Bloc<TEvent, TState> {
      
  AbstractBloc(TState initialState) : super(initialState) {
    log("state(${initialState.runtimeType.toString()})",
        name: "STATE", error: initialState.properties.toString());
  }

  @override
  void add(TEvent event) {
    log("add(${event.runtimeType.toString()})",
        name: "EVENT", error: event.properties.toString());
    super.add(event);
  }
}