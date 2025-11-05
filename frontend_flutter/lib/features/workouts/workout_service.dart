import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import 'workout_models.dart';

class WorkoutService {
  WorkoutService({ApiClient? apiClient}) : _api = (apiClient ?? ApiClient()).client;

  final Dio _api;

  Future<List<WorkoutDto>> getAllWorkouts() async {
    final response = await _api.get('/api/workouts');
    final list = (response.data as List).cast<Map<String, dynamic>>();
    return list.map(WorkoutDto.fromJson).toList();
  }
}



