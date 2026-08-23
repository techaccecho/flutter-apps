import 'package:blog/shared/models/arg_state_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArgStateModel Test Suite', () {
    test('serializes and deserializes player state JSON correctly', () {
      final json = {
        'completedStepIds': ['step_1', 'step_2'],
        'unlockedFeatureIds': ['feature_wordsearch'],
        'currentStepId': 'step_3',
        'isLockedOut': false,
        'passcodeAttempts': {'step_7': 2},
      };

      final model = ArgStateModel.fromJson(json);

      expect(model.completedStepIds, containsAll(['step_1', 'step_2']));
      expect(model.unlockedFeatureIds, contains('feature_wordsearch'));
      expect(model.currentStepId, 'step_3');
      expect(model.isLockedOut, false);
      expect(model.passcodeAttempts['step_7'], 2);
      expect(model.isStepCompleted('step_1'), true);
      expect(model.isStepCompleted('step_99'), false);
      expect(model.isFeatureUnlocked('feature_wordsearch'), true);
    });

    test('handles default empty values gracefully', () {
      final model = ArgStateModel.fromJson({});

      expect(model.completedStepIds, isEmpty);
      expect(model.unlockedFeatureIds, isEmpty);
      expect(model.currentStepId, isNull);
      expect(model.isLockedOut, false);
      expect(model.passcodeAttempts, isEmpty);
    });
  });
}
