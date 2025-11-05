import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend_flutter/l10n/app_localizations.dart';
import '../activity/activity_service.dart';
import '../activity/models.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final _service = ActivityService();
  List<ActivityLogDto> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _loading = true);
    try {
      final logs = await _service.getLogs();
      if (!mounted) return;
      // Take last 7 days, sorted by date
      final sorted = logs..sort((a, b) => a.date.compareTo(b.date));
      setState(() => _logs = sorted.length > 7 ? sorted.sublist(sorted.length - 7) : sorted);
    } catch (e) {
      // Ignore errors, show empty state
      if (mounted) setState(() => _logs = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.progress)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.show_chart, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(t.noData, style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                      const SizedBox(height: 8),
                      Text('Add activity data in Activity tab', style: TextStyle(color: Colors.grey.shade500)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadLogs,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(t.last7Days, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 16),
                      _buildChart(t.stepsChart, Colors.blue, _logs.map((e) => e.steps.toDouble()).toList(), _logs),
                      const SizedBox(height: 24),
                      _buildChart(t.caloriesChart, Colors.orange, _logs.map((e) => e.calories.toDouble()).toList(), _logs),
                      const SizedBox(height: 24),
                      _buildChart(t.sleepChart, Colors.purple, _logs.map((e) => e.sleepHours).toList(), _logs),
                    ],
                  ),
                ),
    );
  }

  Widget _buildChart(String title, Color color, List<double> values, List<ActivityLogDto> logs) {
    if (values.isEmpty) return const SizedBox.shrink();
    final spots = values.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  color: color,
                  barWidth: 3,
                  spots: spots,
                  dotData: const FlDotData(show: true),
                ),
              ],
              gridData: FlGridData(show: true, drawVerticalLine: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= logs.length) return const Text('');
                      final date = logs[index].date;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${date.day}/${date.month}',
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
            ),
          ),
        ),
      ],
    );
  }
}
