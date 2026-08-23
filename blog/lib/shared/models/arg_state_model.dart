class ArgStateModel {
  final List<String> completedStepIds;
  final List<String> unlockedFeatureIds;
  final String? currentStepId;
  final bool isLockedOut;
  final Map<String, int> passcodeAttempts;

  const ArgStateModel({
    required this.completedStepIds,
    required this.unlockedFeatureIds,
    this.currentStepId,
    required this.isLockedOut,
    required this.passcodeAttempts,
  });

  factory ArgStateModel.fromJson(Map<String, dynamic> json) {
    final completed = (json['completedStepIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final unlocked = (json['unlockedFeatureIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final attemptsRaw = json['passcodeAttempts'] as Map<String, dynamic>? ?? {};
    final attempts = attemptsRaw.map(
      (key, value) => MapEntry(key, (value as num).toInt()),
    );

    return ArgStateModel(
      completedStepIds: completed,
      unlockedFeatureIds: unlocked,
      currentStepId: json['currentStepId'] as String?,
      isLockedOut: json['isLockedOut'] as bool? ?? false,
      passcodeAttempts: attempts,
    );
  }

  Map<String, dynamic> toJson() => {
        'completedStepIds': completedStepIds,
        'unlockedFeatureIds': unlockedFeatureIds,
        'currentStepId': currentStepId,
        'isLockedOut': isLockedOut,
        'passcodeAttempts': passcodeAttempts,
      };

  bool isStepCompleted(String stepId) => completedStepIds.contains(stepId);
  bool isFeatureUnlocked(String featureId) =>
      unlockedFeatureIds.contains(featureId);
}
