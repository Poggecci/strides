import 'package:flutter/material.dart';
import 'package:strides/models/activities.dart';
import 'package:strides/shared/widgets/add_activity.dart';
import 'package:strides/shared/widgets/duration_picker.dart';
import 'package:strides/pages/active_activity.dart';

class PlanMaker extends StatefulWidget {
  const PlanMaker({super.key});

  @override
  State<PlanMaker> createState() => _PlanMakerState();
}

class _PlanMakerState extends State<PlanMaker> {
  final List<Activity> _activities = [];
  SessionDuration _duration = SessionDuration.time(const Duration(minutes: 30));
  bool _isCycleBased = true;
  final TextEditingController _cycleController =
      TextEditingController(text: '8');

  @override
  void initState() {
    super.initState();
    _cycleController.addListener(_updateCycleDuration);
  }

  @override
  void dispose() {
    _cycleController.removeListener(_updateCycleDuration);
    _cycleController.dispose();
    super.dispose();
  }

  void _updateCycleDuration() {
    if (_isCycleBased) {
      setState(() {
        _duration =
            SessionDuration.cycles(int.tryParse(_cycleController.text) ?? 0);
      });
    }
  }

  void _updateTimeDuration(Duration newDuration) {
    setState(() {
      _duration = SessionDuration.time(newDuration);
    });
  }

  void _startPlan() {
    if (_activities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please add at least one activity to start the plan.')),
      );
      return;
    }
    if (_isCycleBased && _duration.cycleCount! < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a positive number of cycles')),
      );
      return;
    }

    final activityPlan = ActivityPlan(
      activities: _activities,
      duration: _duration,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActiveActivity(plan: activityPlan),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ReorderableListView.builder(
            itemCount: _activities.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final activity = _activities.removeAt(oldIndex);
                _activities.insert(newIndex, activity);
              });
            },
            itemBuilder: (context, index) {
              final activity = _activities[index];
              return ListTile(
                key: ValueKey(activity),
                leading: ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle),
                ),
                title: Text(
                  activity.kind.displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Duration: ${activity.cycleDuration.inSeconds} seconds',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _activities.removeAt(index);
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                tileColor: Colors.grey[200],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _isCycleBased
                        ? TextField(
                            controller: _cycleController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Number of Cycles',
                              border: OutlineInputBorder(),
                            ),
                          )
                        : DurationPicker(
                            duration: _duration.timeDuration ??
                                const Duration(minutes: 30),
                            onChange: _updateTimeDuration,
                            baseUnit: BaseUnit.minute,
                          ),
                  ),
                  const SizedBox(width: 16),
                  ToggleButtons(
                    isSelected: [!_isCycleBased, _isCycleBased],
                    onPressed: (index) {
                      setState(() {
                        _isCycleBased = index == 1;
                        if (_isCycleBased) {
                          _duration = SessionDuration.cycles(
                              int.tryParse(_cycleController.text) ?? 0);
                        } else {
                          _duration = SessionDuration.time(
                              _duration.timeDuration ??
                                  const Duration(minutes: 30));
                        }
                      });
                    },
                    children: const [
                      Icon(Icons.access_time),
                      Icon(Icons.refresh),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final maybeNewActivity = await showDialog<Activity>(
                          context: context,
                          builder: (context) => const AddActivity(),
                        );
                        if (maybeNewActivity != null) {
                          setState(() {
                            _activities.add(maybeNewActivity);
                          });
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Add Activity"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _startPlan,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text("Start Plan"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
