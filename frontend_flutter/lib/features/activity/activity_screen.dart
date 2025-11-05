import 'package:flutter/material.dart';
import 'package:frontend_flutter/l10n/app_localizations.dart';
import 'activity_service.dart';
import 'models.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _service = ActivityService();

  // Summary form
  final _formKey = GlobalKey<FormState>();
  final _stepsCtrl = TextEditingController(text: '7000');
  final _calCtrl = TextEditingController(text: '350');
  final _sleepCtrl = TextEditingController(text: '7.0');
  DateTime _date = DateTime.now();
  bool _saving = false;
  String? _formError;

  // Water
  List<WaterEntryDto> _water = [];
  bool _waterLoading = true;
  final _waterMlCtrl = TextEditingController(text: '250');
  DateTime _waterDate = DateTime.now();

  // Nutrition
  List<NutritionEntryDto> _foods = [];
  bool _foodLoading = true;
  final _foodNameCtrl = TextEditingController();
  final _foodCalCtrl = TextEditingController(text: '200');
  final _foodProtCtrl = TextEditingController();
  final _foodFatCtrl = TextEditingController();
  final _foodCarbCtrl = TextEditingController();
  DateTime _foodDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _loadWater();
    _loadFood();
  }

  Future<void> _saveSummary() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _formError = null;
    });
    try {
      final dto = ActivityLogDto(
        steps: int.parse(_stepsCtrl.text),
        calories: int.parse(_calCtrl.text),
        sleepHours: double.parse(_sleepCtrl.text),
        date: _date,
        notes: null,
      );
      await _service.logActivity(dto);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.saved)));
    } catch (e) {
      setState(() => _formError = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _loadWater() async {
    setState(() => _waterLoading = true);
    try {
      final list = await _service.getWater();
      if (!mounted) return;
      setState(() => _water = list);
    } finally {
      if (mounted) setState(() => _waterLoading = false);
    }
  }

  Future<void> _addWater() async {
    final dto = WaterEntryDto(
      date: ActivityLogDto.formatDate(_waterDate),
      milliliters: int.tryParse(_waterMlCtrl.text) ?? 0,
    );
    await _service.addWater(dto);
    await _loadWater();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.waterAdded)));
    }
  }

  Future<void> _loadFood() async {
    setState(() => _foodLoading = true);
    try {
      final list = await _service.getNutrition();
      if (!mounted) return;
      setState(() => _foods = list);
    } finally {
      if (mounted) setState(() => _foodLoading = false);
    }
  }

  Future<void> _addFood() async {
    final dto = NutritionEntryDto(
      date: ActivityLogDto.formatDate(_foodDate),
      food: _foodNameCtrl.text.trim(),
      calories: int.tryParse(_foodCalCtrl.text) ?? 0,
      proteinG: _foodProtCtrl.text.trim().isEmpty ? null : double.tryParse(_foodProtCtrl.text),
      fatG: _foodFatCtrl.text.trim().isEmpty ? null : double.tryParse(_foodFatCtrl.text),
      carbsG: _foodCarbCtrl.text.trim().isEmpty ? null : double.tryParse(_foodCarbCtrl.text),
    );
    await _service.addNutrition(dto);
    await _loadFood();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.foodAdded)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.activityNav),
        bottom: TabBar(
          controller: _tab,
          tabs: [
            Tab(text: t.summary, icon: const Icon(Icons.directions_run)),
            Tab(text: t.water, icon: const Icon(Icons.local_drink)),
            Tab(text: t.nutrition, icon: const Icon(Icons.restaurant)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: t.exportCsv,
            icon: const Icon(Icons.download),
            onPressed: () async {
              final csv = await _service.exportCsv();
              if (!mounted) return;
              showModalBottomSheet(context: context, builder: (ctx) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.csvPreview, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(csv)),
                    ],
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _buildSummaryTab(),
          _buildWaterTab(),
          _buildFoodTab(),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    final t = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.date),
              subtitle: Text('${_date.toLocal()}'.split(' ').first),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _stepsCtrl,
              decoration: InputDecoration(labelText: t.stepsLabel),
              keyboardType: TextInputType.number,
              validator: (v) => (v == null || int.tryParse(v) == null) ? t.enterSteps : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _calCtrl,
              decoration: InputDecoration(labelText: t.caloriesBurned),
              keyboardType: TextInputType.number,
              validator: (v) => (v == null || int.tryParse(v) == null) ? t.enterCalories : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _sleepCtrl,
              decoration: InputDecoration(labelText: t.sleepHoursLabel),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => (v == null || double.tryParse(v) == null) ? t.enterSleepHours : null,
            ),
            const SizedBox(height: 16),
            if (_formError != null) ...[
              Text(_formError!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
            ],
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _saving ? null : _saveSummary,
                child: _saving
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(t.save),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterTab() {
    final t = AppLocalizations.of(context)!;
    return RefreshIndicator(
      onRefresh: _loadWater,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            Expanded(
              child: TextField(
                controller: _waterMlCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: t.milliliters),
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text('${_waterDate.toLocal()}'.split(' ').first),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _waterDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => _waterDate = picked);
              },
            ),
            const SizedBox(width: 8),
            FilledButton.icon(onPressed: _addWater, icon: const Icon(Icons.add), label: Text(t.add)),
          ]),
          const SizedBox(height: 12),
          if (_waterLoading) const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
          ..._water.map((w) => Card(
                child: ListTile(
                  title: Text('${w.milliliters} ml'),
                  subtitle: Text(w.date),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildFoodTab() {
    final t = AppLocalizations.of(context)!;
    return RefreshIndicator(
      onRefresh: _loadFood,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _foodNameCtrl,
            decoration: InputDecoration(labelText: t.food),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _foodCalCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: t.calories),
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text('${_foodDate.toLocal()}'.split(' ').first),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _foodDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => _foodDate = picked);
              },
            ),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _foodProtCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: t.proteinG),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _foodFatCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: t.fatG),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _foodCarbCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: t.carbsG),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(onPressed: _addFood, icon: const Icon(Icons.add), label: Text(t.add)),
          ),
          const SizedBox(height: 12),
          if (_foodLoading) const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
          ..._foods.map((n) => Card(
                child: ListTile(
                  title: Text('${n.food} • ${n.calories} kcal'),
                  subtitle: Text('${n.date}  P:${n.proteinG ?? '-'} F:${n.fatG ?? '-'} C:${n.carbsG ?? '-'}'),
                ),
              )),
        ],
      ),
    );
  }
}
