import 'dart:async';
import 'package:flutter/material.dart';
import 'package:strides/models/activities.dart';

enum ActivityStatus { ongoing, paused, cancelled, completed }

class ActiveActivity extends StatefulWidget {
  final ActivityPlan plan;

  const ActiveActivity({super.key, required this.plan});

  @override
  State<ActiveActivity> createState() => _ActiveActivityState();
}

class _ActiveActivityState extends State<ActiveActivity> {
  late ActivityStatus _status;
  late int _activityIndex;
  late Duration _activityTimeElapsed;
  late Duration _sessionTimeElapsed;
  late int _cyclesCompleted;
  Timer? _timer;

  final Map<ActivityKind, Duration> _activityTimes = {};

  @override
  void initState() {
    super.initState();
    _status = ActivityStatus.ongoing;
    _activityIndex = 0;
    _activityTimeElapsed = Duration.zero;
    _sessionTimeElapsed = Duration.zero;
    _cyclesCompleted = 0;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_status == ActivityStatus.ongoing) {
        setState(() {
          _activityTimeElapsed += const Duration(seconds: 1);
          _sessionTimeElapsed += const Duration(seconds: 1);
          _updateActivityTimes(widget.plan.activities[_activityIndex].kind,
              const Duration(seconds: 1));

          if (_activityTimeElapsed >=
              widget.plan.activities[_activityIndex].cycleDuration) {
            _moveToNextActivity();
          }

          if (_isSessionCompleted()) {
            _completeSession();
          }
        });
      }
    });
  }

  void _moveToNextActivity() {
    _activityIndex++;
    _activityTimeElapsed = Duration.zero;
    if (_activityIndex >= widget.plan.activities.length) {
      _activityIndex = 0;
      _cyclesCompleted++;
    }
  }

  bool _isSessionCompleted() {
    if (widget.plan.duration.cycleCount != null) {
      return _cyclesCompleted >= widget.plan.duration.cycleCount!;
    } else if (widget.plan.duration.timeDuration != null) {
      return _sessionTimeElapsed >= widget.plan.duration.timeDuration!;
    }
    return false;
  }

  void _completeSession() {
    setState(() {
      _status = ActivityStatus.completed;
      _timer?.cancel();
    });
  }

  void _pauseSession() {
    setState(() {
      _status = ActivityStatus.paused;
      _timer?.cancel();
    });
  }

  void _resumeSession() {
    setState(() {
      _status = ActivityStatus.ongoing;
      _startTimer();
    });
  }

  void _cancelSession() {
    setState(() {
      _status = ActivityStatus.cancelled;
      _timer?.cancel();
    });
  }

  void _restartSession() {
    setState(() {
      _status = ActivityStatus.ongoing;
      _activityIndex = 0;
      _activityTimeElapsed = Duration.zero;
      _sessionTimeElapsed = Duration.zero;
      _cyclesCompleted = 0;
      _activityTimes.clear();
      _startTimer();
    });
  }

  void _updateActivityTimes(ActivityKind kind, Duration duration) {
    _activityTimes.update(kind, (value) => value + duration,
        ifAbsent: () => duration);
  }

  Widget _buildOngoingUI() {
    final currentActivity = widget.plan.activities[_activityIndex];
    final timeLeft = currentActivity.cycleDuration - _activityTimeElapsed;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(currentActivity.kind.activeName,
            style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 20),
        Text(
            'Time left: ${timeLeft.inMinutes}:${(timeLeft.inSeconds % 60).toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                onPressed: _pauseSession, child: const Text('Pause')),
            ElevatedButton(
                onPressed: _cancelSession, child: const Text('Cancel')),
          ],
        ),
      ],
    );
  }

  Widget _buildPausedUI() {
    final currentActivity = widget.plan.activities[_activityIndex];
    final timeLeft = currentActivity.cycleDuration - _activityTimeElapsed;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(currentActivity.kind.activeName,
            style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 20),
        Text(
            'Time left: ${timeLeft.inMinutes}:${(timeLeft.inSeconds % 60).toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                onPressed: _resumeSession, child: const Text('Resume')),
            ElevatedButton(
                onPressed: _cancelSession, child: const Text('Cancel')),
          ],
        ),
      ],
    );
  }

  Widget _buildCompletedOrCancelledUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
            _status == ActivityStatus.completed
                ? 'Session Completed!'
                : 'Session Cancelled',
            style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 20),
        ..._activityTimes.entries.map((entry) => Text(
            '${entry.key.displayName}: ${entry.value.inMinutes} minutes',
            style: Theme.of(context).textTheme.displaySmall)),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Return to Plan')),
            ElevatedButton(
                onPressed: _restartSession, child: const Text('Start Again')),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Active Activity')),
      body: Center(
        child: _status == ActivityStatus.ongoing
            ? _buildOngoingUI()
            : _status == ActivityStatus.paused
                ? _buildPausedUI()
                : _buildCompletedOrCancelledUI(),
      ),
    );
  }
}
