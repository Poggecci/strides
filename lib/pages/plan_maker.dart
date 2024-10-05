import 'package:flutter/material.dart';
import 'package:strides/models/activities.dart';
import 'package:strides/shared/widgets/add_activity.dart';

class PlanMaker extends StatefulWidget {
  const PlanMaker({super.key});

  @override
  State<PlanMaker> createState() => _PlanMakerState();
}

class _PlanMakerState extends State<PlanMaker> {
  final List<Activity> _activities = [];
  SessionDuration? _duration;

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
                // Update trailing widget to include spacing
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
                    const SizedBox(width: 8), // Add space between the icons
                  ],
                ),
                tileColor: Colors.grey[200], // Optional: to make it stand out
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
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
      ],
    );
  }
}
