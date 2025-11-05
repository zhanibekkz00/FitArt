import 'package:flutter/material.dart';
import 'workout_service.dart';
import 'workout_models.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final _service = WorkoutService();
  late Future<List<WorkoutDto>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getAllWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workouts')),
      body: FutureBuilder<List<WorkoutDto>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final items = snapshot.data ?? const [];
          if (items.isEmpty) {
            return const Center(child: Text('No workouts'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final w = items[index];
              return ListTile(
                title: Text(w.title),
                subtitle: Text('Level: ${w.level}'),
              );
            },
          );
        },
      ),
    );
  }
}



