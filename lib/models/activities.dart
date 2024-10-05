enum ActivityKind {
  jog(
    displayName: "Jog",
    activeName: "Jogging",
  ),
  sprint(displayName: "Sprint", activeName: "Sprinting"),
  walk(displayName: "Walk", activeName: "Walking");

  const ActivityKind({required this.displayName, required this.activeName});

  final String activeName;
  final String displayName;
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
