import 'package:blog/shared/models/arg_state_model.dart';
import 'package:blog/shared/util/app_config.dart';
import 'package:dio/dio.dart';

class StateApiProvider {
  final Dio dio;

  StateApiProvider(this.dio);

  Future<ArgStateModel> getPlayerState() async {
    final response = await dio.get(
      '${AppConfig.stateApiBaseUrl}/player/state',
      options: Options(
        headers: {'x-api-key': AppConfig.apiKey},
      ),
    );
    return ArgStateModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ArgStateModel> completeStep({
    required String stepId,
    String? passcode,
  }) async {
    final response = await dio.post(
      '${AppConfig.stateApiBaseUrl}/player/step/complete',
      data: {
        'stepId': stepId,
        if (passcode != null) 'passcode': passcode,
      },
      options: Options(
        headers: {'x-api-key': AppConfig.apiKey},
      ),
    );
    return ArgStateModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ArgStateModel> failStep({required String stepId}) async {
    final response = await dio.post(
      '${AppConfig.stateApiBaseUrl}/player/step/fail',
      data: {'stepId': stepId},
      options: Options(
        headers: {'x-api-key': AppConfig.apiKey},
      ),
    );
    return ArgStateModel.fromJson(response.data as Map<String, dynamic>);
  }
}
