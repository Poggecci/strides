import 'package:flutter/material.dart';
import 'package:strides/models/activities.dart';
import 'package:strides/shared/widgets/add_activity.dart';

class PlanMaker extends StatefulWidget {
  const PlanMaker({super.key});

  @override
  State<PlanMaker> createState() => _PlanMakerState();
}

class _PlanMakerState extends State<PlanMaker> {
  final ActivityPlan _plan =
      // ignore: prefer_const_constructors
      ActivityPlan(activities: [], sessionDuration: Duration.zero);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _plan.activities.length,
            itemBuilder: (context, index) {
              final activity = _plan.activities[index];
              return ListTile(
                title: Text(activity.kind.displayName),
                subtitle: Text(
                    'Duration: ${activity.cycleDuration.inSeconds} seconds'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _plan.activities.removeAt(index);
                    });
                  },
                ),
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            final maybeNewActivity = await showDialog<Activity>(
              context: context,
              builder: (context) => const AddActivity(),
            );
            if (maybeNewActivity != null) {
              setState(() {
                _plan.activities.add(maybeNewActivity);
              });
            }
          },
          child: const Text("Add Activity"),
        ),
      ],
    );
  }
}
