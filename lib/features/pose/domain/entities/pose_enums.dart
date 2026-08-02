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

/// How many people appear in the pose.
enum PeopleCount {
  /// A single subject.
  solo,

  /// Two subjects posing together.
  duo,

  /// Three or more subjects.
  group;

  /// Human-readable name for filter chips and detail screens.
  String get label => switch (this) {
    PeopleCount.solo => 'Solo',
    PeopleCount.duo => 'Duo',
    PeopleCount.group => 'Group',
  };

  /// Parses a wire value by enum name, returning null when the value is
  /// null or matches no count.
  static PeopleCount? tryParse(String? value) {
    if (value == null) {
      return null;
    }
    return PeopleCount.values.asNameMap()[value];
  }
}

/// Direction the subject's body faces in the reference photograph.
enum BodyDirection {
  /// Facing the camera head-on.
  front,

  /// Turned away from the camera.
  back,

  /// Perpendicular to the camera.
  side,

  /// Between front and side, roughly 45 degrees.
  threeQuarter;

  /// Human-readable name for filter chips and detail screens.
  String get label => switch (this) {
    BodyDirection.front => 'Front',
    BodyDirection.back => 'Back',
    BodyDirection.side => 'Side',
    BodyDirection.threeQuarter => 'Three-Quarter',
  };

  /// Parses a wire value by enum name or hyphenated alias, returning null
  /// when the value is null or matches no direction.
  static BodyDirection? tryParse(String? value) {
    if (value == null) {
      return null;
    }
    // Support both enum name (threeQuarter) and wire format (three-quarter).
    if (value == 'three-quarter') {
      return BodyDirection.threeQuarter;
    }
    return BodyDirection.values.asNameMap()[value];
  }
}
