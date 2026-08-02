/// How hard a pose is to recreate for an average subject.
enum PoseDifficulty {
  /// Quick to strike with no special balance or flexibility.
  easy,

  /// Needs some direction or a few attempts to look natural.
  medium,

  /// Demands practice, balance, or precise timing.
  hard;

  /// Human-readable name for filter chips and detail screens.
  String get label => switch (this) {
    PoseDifficulty.easy => 'Easy',
    PoseDifficulty.medium => 'Medium',
    PoseDifficulty.hard => 'Hard',
  };

  /// Parses a wire value by enum name, returning null when the value is
  /// null or matches no difficulty.
  static PoseDifficulty? tryParse(String? value) {
    if (value == null) {
      return null;
    }
    return PoseDifficulty.values.asNameMap()[value];
  }
}

/// Who a pose is designed for.
enum PoseGender {
  /// Composed for a female subject.
  female,

  /// Composed for a male subject.
  male,

  /// Composed for two people posing together.
  couple,

  /// Works equally well for any subject.
  any;

  /// Human-readable name for filter chips and detail screens.
  String get label => switch (this) {
    PoseGender.female => 'Female',
    PoseGender.male => 'Male',
    PoseGender.couple => 'Couple',
    PoseGender.any => 'Anyone',
  };

  /// Parses a wire value by enum name, returning null when the value is
  /// null or matches no gender.
  static PoseGender? tryParse(String? value) {
    if (value == null) {
      return null;
    }
    return PoseGender.values.asNameMap()[value];
  }
}
