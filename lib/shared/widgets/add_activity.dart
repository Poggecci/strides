import 'package:flutter/material.dart';
import 'package:strides/models/activities.dart';
import 'package:strides/shared/widgets/duration_picker.dart';

class AddActivity extends StatefulWidget {
  const AddActivity({super.key});

  @override
  State<AddActivity> createState() => _AddActivityState();
}

class _AddActivityState extends State<AddActivity> {
  ActivityKind selectedKind = ActivityKind.jog;
  Duration selectedDuration = const Duration(seconds: 30);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Activity'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Kind:'),
              const SizedBox(width: 10),
              DropdownButton<ActivityKind>(
                value: selectedKind,
                onChanged: (ActivityKind? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedKind = newValue;
                    });
                  }
                },
                items: ActivityKind.values.map((ActivityKind kind) {
                  return DropdownMenuItem<ActivityKind>(
                    value: kind,
                    child: Text(kind.displayName),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Duration:'),
          const SizedBox(height: 5),
          DurationPicker(
            duration: selectedDuration,
            onChange: (Duration duration) {
              setState(() {
                selectedDuration = duration;
              });
            },
            baseUnit: BaseUnit.second,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Activity newActivity = Activity(
              kind: selectedKind,
              cycleDuration: selectedDuration,
            );
            Navigator.of(context).pop(newActivity);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
