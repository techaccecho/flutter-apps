import 'package:blog/shared/models/arg_state_model.dart';
import 'package:blog/shared/util/app_config.dart';
import 'package:dio/dio.dart';

class StateApiProvider {
  final Dio dio;

  StateApiProvider(this.dio);

  Future<ArgStateModel> getPlayerState({String? userId}) async {
    final response = await dio.get(
      '${AppConfig.stateApiBaseUrl}/player/state',
      queryParameters: {
        if (userId != null && userId.trim().isNotEmpty) 'userId': userId.trim(),
      },
      options: Options(
        headers: {'x-api-key': AppConfig.apiKey},
      ),
    );
    return ArgStateModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ArgStateModel> completeStep({
    required String stepId,
    String? passcode,
    String? userId,
  }) async {
    final response = await dio.post(
      '${AppConfig.stateApiBaseUrl}/player/step/complete',
      data: {
        'stepId': stepId,
        if (passcode != null) 'passcode': passcode,
        if (userId != null && userId.trim().isNotEmpty) 'userId': userId.trim(),
      },
      options: Options(
        headers: {'x-api-key': AppConfig.apiKey},
      ),
    );
    return ArgStateModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ArgStateModel> failStep({
    required String stepId,
    String? userId,
  }) async {
    final response = await dio.post(
      '${AppConfig.stateApiBaseUrl}/player/step/fail',
      data: {
        'stepId': stepId,
        if (userId != null && userId.trim().isNotEmpty) 'userId': userId.trim(),
      },
      options: Options(
        headers: {'x-api-key': AppConfig.apiKey},
      ),
    );
    return ArgStateModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ArgStateModel> claimGuestProgress({
    required String guestUserId,
    String? userId,
  }) async {
    final response = await dio.post(
      '${AppConfig.stateApiBaseUrl}/player/claim-guest',
      data: {
        'guestUserId': guestUserId,
        if (userId != null) 'userId': userId,
      },
      options: Options(
        headers: {'x-api-key': AppConfig.apiKey},
      ),
    );
    return ArgStateModel.fromJson(response.data as Map<String, dynamic>);
  }
}
