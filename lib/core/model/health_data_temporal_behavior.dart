import 'package:health/health.dart';

/// Defines how different health data types should be handled temporally
enum HealthDataTemporalBehavior {
  /// Data represents a point in time (e.g., weight, heart rate)
  /// Should be assigned to the segment containing the measurement time
  instantaneous,

  /// Data represents an activity over a duration (e.g., steps, calories)
  /// Should be distributed proportionally across segments it spans
  cumulative,

  /// Data represents a session/state over time (e.g., sleep, workouts)
  /// Should be assigned to the segment where it predominately occurs
  sessional,

  /// Data represents a period between two points (e.g., sleep phases)
  /// Should be assigned in full to the segment containing the end time
  durational;

  /// Get the temporal behavior for a given health data type
  static HealthDataTemporalBehavior forHealthDataType(HealthDataType type) =>
      switch (type) {
        // Instantaneous measurements
        HealthDataType.WEIGHT ||
        HealthDataType.HEIGHT ||
        HealthDataType.HEART_RATE ||
        HealthDataType.BLOOD_PRESSURE_SYSTOLIC ||
        HealthDataType.BLOOD_PRESSURE_DIASTOLIC ||
        HealthDataType.BLOOD_GLUCOSE ||
        HealthDataType.BODY_TEMPERATURE =>
          HealthDataTemporalBehavior.instantaneous,

        // Cumulative activities
        HealthDataType.STEPS ||
        HealthDataType.ACTIVE_ENERGY_BURNED ||
        HealthDataType.DISTANCE_DELTA ||
        HealthDataType.WATER ||
        HealthDataType.FLIGHTS_CLIMBED =>
          HealthDataTemporalBehavior.cumulative,

        // Sessional activities
        HealthDataType.WORKOUT ||
        HealthDataType.MINDFULNESS =>
          HealthDataTemporalBehavior.sessional,

        // Durational states (sleep phases)
        HealthDataType.SLEEP_SESSION ||
        HealthDataType.SLEEP_ASLEEP ||
        HealthDataType.SLEEP_AWAKE ||
        HealthDataType.SLEEP_DEEP ||
        HealthDataType.SLEEP_LIGHT ||
        HealthDataType.SLEEP_REM =>
          HealthDataTemporalBehavior.durational,

        // Default to instantaneous for unknown types
        _ => HealthDataTemporalBehavior.instantaneous,
      };

  /// Check if this data type spans time boundaries
  bool get spansTimeBoundaries => switch (this) {
        HealthDataTemporalBehavior.instantaneous => false,
        HealthDataTemporalBehavior.cumulative => true,
        HealthDataTemporalBehavior.sessional => true,
        HealthDataTemporalBehavior.durational => true,
      };

  /// Check if this data type should be distributed across segments
  bool get shouldDistribute => switch (this) {
        HealthDataTemporalBehavior.instantaneous => false,
        HealthDataTemporalBehavior.cumulative => true,
        HealthDataTemporalBehavior.sessional => false,
        HealthDataTemporalBehavior.durational =>
          false, // Assigned to end-time segment only
      };
}
