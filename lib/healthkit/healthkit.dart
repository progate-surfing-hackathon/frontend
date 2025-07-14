import 'dart:async';

import 'package:flutter/material.dart';
import 'package:health/health.dart';

final health = Health();

List<RecordingMethod> recordingMethodsToFilter = [];

Future<int?> fetchStepData() async {
  int? steps;

  final now = DateTime.now();
  final midnight = DateTime(now.year, now.month, now.day);

  bool stepsPermission =
      await health.hasPermissions([HealthDataType.STEPS]) ?? false;
  if (!stepsPermission) {
    stepsPermission =
        await health.requestAuthorization([HealthDataType.STEPS]);
  }


  bool isHealthConnectAvailable = await health.isHealthConnectAvailable();

  if (isHealthConnectAvailable) {
    print('Health Connect is available');
  } else {
    print('Health Connect is not available, using Google Fit');
  }


  if (stepsPermission) {
    try {
      steps = await health.getTotalStepsInInterval(midnight, now,
          includeManualEntry:
              !recordingMethodsToFilter.contains(RecordingMethod.manual));
    } catch (error) {
      debugPrint("Exception in getTotalStepsInInterval: $error");
    }

    debugPrint('Total number of steps: $steps');
    return steps;
  } else {
    debugPrint("Authorization not granted - error in authorization");
    return null;
  }
}