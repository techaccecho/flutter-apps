import 'dart:async';
import 'package:blog/shared/models/arg_state_model.dart';
import 'package:blog/shared/repositories/arg_state_repository.dart';
import 'package:blog/shared/services/storage_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class ArgStateEvent {}

class FetchArgStateEvent extends ArgStateEvent {
  final String? userId;
  FetchArgStateEvent({this.userId});
}

class ClaimGuestArgProgressEvent extends ArgStateEvent {
  final String guestUserId;
  final String? userId;
  ClaimGuestArgProgressEvent({required this.guestUserId, this.userId});
}

class CompleteArgStepEvent extends ArgStateEvent {
  final String stepId;
  final String? passcode;
  final String? userId;
  CompleteArgStepEvent({required this.stepId, this.passcode, this.userId});
}

class FailArgStepEvent extends ArgStateEvent {
  final String stepId;
  final String? userId;
  FailArgStepEvent({required this.stepId, this.userId});
}

// States
abstract class ArgStateStatus {}

class ArgStateInitial extends ArgStateStatus {}

class ArgStateLoading extends ArgStateStatus {}

class ArgStateLoaded extends ArgStateStatus {
  final ArgStateModel model;
  ArgStateLoaded(this.model);
}

class ArgStateError extends ArgStateStatus {
  final String message;
  ArgStateError(this.message);
}

// BLoC
class ArgStateBloc extends Bloc<ArgStateEvent, ArgStateStatus> {
  final ArgStateRepository repository;
  StreamSubscription<ArgStateModel>? _subscription;

  ArgStateBloc({required this.repository}) : super(ArgStateInitial()) {
    on<FetchArgStateEvent>(_onFetchArgState);
    on<ClaimGuestArgProgressEvent>(_onClaimGuestArgProgress);
    on<CompleteArgStepEvent>(_onCompleteArgStep);
    on<FailArgStepEvent>(_onFailArgStep);

    _subscription = repository.stateStream.listen((model) {
      emit(ArgStateLoaded(model));
    });
  }

  Future<void> _onFetchArgState(
    FetchArgStateEvent event,
    Emitter<ArgStateStatus> emit,
  ) async {
    emit(ArgStateLoading());
    try {
      final storedGuestId = StorageHelper.getItem(StorageHelper.guestUserIdKey);
      if (storedGuestId != null &&
          storedGuestId.isNotEmpty &&
          event.userId != null &&
          !event.userId!.startsWith('guest_')) {
        try {
          final model = await repository.claimGuestProgress(
            guestUserId: storedGuestId,
            userId: event.userId,
          );
          StorageHelper.removeItem(StorageHelper.guestUserIdKey);
          emit(ArgStateLoaded(model));
          return;
        } catch (_) {
          // If claim encounters an error, proceed to standard fetch
        }
      }

      final targetUserId = event.userId ?? storedGuestId;
      final model = await repository.fetchState(userId: targetUserId);
      emit(ArgStateLoaded(model));
    } catch (e) {
      emit(ArgStateError(e.toString()));
    }
  }

  Future<void> _onClaimGuestArgProgress(
    ClaimGuestArgProgressEvent event,
    Emitter<ArgStateStatus> emit,
  ) async {
    try {
      final model = await repository.claimGuestProgress(
        guestUserId: event.guestUserId,
        userId: event.userId,
      );
      StorageHelper.setItem(StorageHelper.guestUserIdKey, '');
      emit(ArgStateLoaded(model));
    } catch (e) {
      emit(ArgStateError(e.toString()));
    }
  }

  Future<void> _onCompleteArgStep(
    CompleteArgStepEvent event,
    Emitter<ArgStateStatus> emit,
  ) async {
    try {
      final storedGuestId = StorageHelper.getItem(StorageHelper.guestUserIdKey);
      final targetUserId = event.userId ?? storedGuestId;
      final model = await repository.completeStep(
        stepId: event.stepId,
        passcode: event.passcode,
        userId: targetUserId,
      );
      emit(ArgStateLoaded(model));
    } catch (e) {
      emit(ArgStateError(e.toString()));
    }
  }

  Future<void> _onFailArgStep(
    FailArgStepEvent event,
    Emitter<ArgStateStatus> emit,
  ) async {
    try {
      final storedGuestId = StorageHelper.getItem(StorageHelper.guestUserIdKey);
      final targetUserId = event.userId ?? storedGuestId;
      final model = await repository.failStep(
        stepId: event.stepId,
        userId: targetUserId,
      );
      emit(ArgStateLoaded(model));
    } catch (e) {
      emit(ArgStateError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
