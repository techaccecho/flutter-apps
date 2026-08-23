import 'dart:async';
import 'package:blog/shared/models/arg_state_model.dart';
import 'package:blog/shared/providers/state_api_provider.dart';

class ArgStateRepository {
  final StateApiProvider apiProvider;
  final StreamController<ArgStateModel> _stateController =
      StreamController<ArgStateModel>.broadcast();

  ArgStateModel? _cachedState;

  ArgStateRepository({required this.apiProvider});

  Stream<ArgStateModel> get stateStream => _stateController.stream;
  ArgStateModel? get cachedState => _cachedState;

  Future<ArgStateModel> fetchState() async {
    final state = await apiProvider.getPlayerState();
    _cachedState = state;
    _stateController.add(state);
    return state;
  }

  Future<ArgStateModel> completeStep({
    required String stepId,
    String? passcode,
  }) async {
    final state = await apiProvider.completeStep(
      stepId: stepId,
      passcode: passcode,
    );
    _cachedState = state;
    _stateController.add(state);
    return state;
  }

  Future<ArgStateModel> failStep({required String stepId}) async {
    final state = await apiProvider.failStep(stepId: stepId);
    _cachedState = state;
    _stateController.add(state);
    return state;
  }

  Future<ArgStateModel> claimGuestProgress({
    required String guestUserId,
    String? userId,
  }) async {
    final state = await apiProvider.claimGuestProgress(
      guestUserId: guestUserId,
      userId: userId,
    );
    _cachedState = state;
    _stateController.add(state);
    return state;
  }

  void dispose() {
    _stateController.close();
  }
}
