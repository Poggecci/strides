enum ActivityKind {
  jog(
      displayName: "Jog",
      activeName: "Jogging",
      audioCuePath: "mixkit-atm-cash-machine-key-press-2841.wav"),
  sprint(
      displayName: "Sprint",
      activeName: "Sprinting",
      audioCuePath: "mixkit-positive-notification-951.wav"),
  walk(
      displayName: "Walk",
      activeName: "Walking",
      audioCuePath: "mixkit-interface-option-select-2573.wav");

  const ActivityKind(
      {required this.displayName,
      required this.activeName,
      required this.audioCuePath});

  final String activeName;
  final String displayName;
  final String audioCuePath;
}

class Activity {
  final ActivityKind kind;
  final Duration cycleDuration;

  const Activity({required this.kind, required this.cycleDuration});
}

class SessionDuration {
  Duration? timeDuration;
  int? cycleCount;
  SessionDuration.time(this.timeDuration) : cycleCount = null;
  SessionDuration.cycles(this.cycleCount) : timeDuration = null;
}

class ActivityPlan {
  final List<Activity> activities;
  final SessionDuration duration;
  const ActivityPlan({required this.activities, required this.duration});
}
