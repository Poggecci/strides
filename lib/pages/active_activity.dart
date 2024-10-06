import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:strides/models/activities.dart';
import 'package:audioplayers/audioplayers.dart';

enum ActivityStatus { ongoing, paused, cancelled, completed }

class ActiveActivity extends StatefulWidget {
  final ActivityPlan plan;

  const ActiveActivity({super.key, required this.plan});

  @override
  State<ActiveActivity> createState() => _ActiveActivityState();
}

class _ActiveActivityState extends State<ActiveActivity>
    with SingleTickerProviderStateMixin {
  late ActivityStatus _status;
  late int _activityIndex;
  late Duration _activityTimeElapsed;
  late Duration _sessionTimeElapsed;
  late Duration _sessionTimeChekpoint;
  late int _cyclesCompleted;
  late Ticker _ticker;
  Stopwatch stopwatch = Stopwatch();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final Map<ActivityKind, Duration> _activityTimes = {};

  @override
  void initState() {
    super.initState();
    _status = ActivityStatus.ongoing;
    _activityIndex = 0;
    _activityTimeElapsed = Duration.zero;
    _sessionTimeElapsed = Duration.zero;
    _sessionTimeChekpoint = Duration.zero;

    _cyclesCompleted = 0;
    _ticker = createTicker(_onTick);
    _startStopwatch();
    _playAudioForActivity();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Future<void> _playAudioForActivity() async {
    await _audioPlayer.play(
        AssetSource(widget.plan.activities[_activityIndex].kind.audioCuePath));
  }

  void _onTick(Duration elapsed) {
    if (_status == ActivityStatus.ongoing) {
      setState(() {
        _activityTimeElapsed = stopwatch.elapsed;
        _sessionTimeElapsed = _sessionTimeChekpoint + stopwatch.elapsed;
        if (_activityTimeElapsed >=
            widget.plan.activities[_activityIndex].cycleDuration) {
          _moveToNextActivity();
        }

        if (_isSessionCompleted()) {
          _completeSession();
        }
      });
    }
  }

  void _startStopwatch() async {
    stopwatch.start();
    _ticker.start();
  }

  void _moveToNextActivity() async {
    _updateActivityTimes(
        widget.plan.activities[_activityIndex].kind, _activityTimeElapsed);
    _activityIndex++;
    _sessionTimeChekpoint += _activityTimeElapsed;
    _activityTimeElapsed = Duration.zero;
    stopwatch.reset();
    if (_activityIndex >= widget.plan.activities.length) {
      _activityIndex = 0;
      _cyclesCompleted++;
    }
    await _playAudioForActivity();
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
      _updateActivityTimes(
          widget.plan.activities[_activityIndex].kind, _activityTimeElapsed);
      stopwatch.reset();
      stopwatch.stop();
      _ticker.stop();
    });
  }

  void _pauseSession() {
    setState(() {
      _status = ActivityStatus.paused;
      stopwatch.stop();
      _ticker.stop();
    });
  }

  void _resumeSession() {
    setState(() {
      _status = ActivityStatus.ongoing;
      _ticker.start();
      stopwatch.start();
    });
  }

  void _cancelSession() {
    setState(() {
      _status = ActivityStatus.cancelled;
      _ticker.stop();
      _updateActivityTimes(
          widget.plan.activities[_activityIndex].kind, _activityTimeElapsed);
      stopwatch.stop();
      stopwatch.reset();
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
      stopwatch.reset();
      _startStopwatch();
    });
  }

  void _updateActivityTimes(ActivityKind kind, Duration duration) {
    _activityTimes.update(kind, (value) => value + duration,
        ifAbsent: () => duration);
  }

  Widget _timerDisplay() {
    final currentActivity = widget.plan.activities[_activityIndex];
    final timeLeft = currentActivity.cycleDuration - _activityTimeElapsed;
    final progress = _activityTimeElapsed.inMilliseconds /
        currentActivity.cycleDuration.inMilliseconds;

    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 250,
            height: 250,
            child: CircularProgressIndicator(
              value: 1 - progress,
              strokeWidth: 20,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          Text(
            '${timeLeft.inMinutes.toString().padLeft(2, '0')}:${(timeLeft.inSeconds % 60).toString().padLeft(2, '0')}.${(timeLeft.inMilliseconds % 1000).toString().padLeft(3, '0')}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildOngoingUI() {
    final currentActivity = widget.plan.activities[_activityIndex];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(currentActivity.kind.activeName,
            style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 20),
        _timerDisplay(),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.red.shade50),
                onPressed: _pauseSession,
                child: const Text('Pause')),
            ElevatedButton(
                onPressed: _cancelSession, child: const Text('Cancel')),
          ],
        ),
      ],
    );
  }

  Widget _buildPausedUI() {
    final currentActivity = widget.plan.activities[_activityIndex];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(currentActivity.kind.activeName,
            style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 20),
        _timerDisplay(),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.green.shade50),
                onPressed: _resumeSession,
                child: const Text('Resume')),
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
            '${entry.key.displayName}: ${entry.value.inMinutes} minutes ${entry.value.inSeconds % 60} seconds',
            style: Theme.of(context).textTheme.bodyLarge)),
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
