import 'package:flutter/material.dart';
import 'package:strides/models/activities.dart';

class ActiveActivity extends StatelessWidget {
  final ActivityPlan plan;

  const ActiveActivity({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Active Activity')),
      body: Center(
        child: Text(
            'Active Activity Page - Plan with ${plan.activities.length} activities'),
      ),
    );
  }
}
