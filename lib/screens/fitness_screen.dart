import 'package:flutter/material.dart';

import '../models/fitness_activity.dart';
import '../services/fitness_storage.dart';
import '../widgets/fitness_summary_card.dart';
import '../widgets/weekly_chart.dart';

class FitnessScreen extends StatefulWidget {
  const FitnessScreen({super.key});

  @override
  State<FitnessScreen> createState() => _FitnessScreenState();
}

class _FitnessScreenState extends State<FitnessScreen> {
  List<FitnessActivity> activities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final savedActivities = await FitnessStorage.loadActivities();

    if (!mounted) return;

    setState(() {
      activities = savedActivities;
      isLoading = false;
    });
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  List<FitnessActivity> get todayActivities =>
      activities.where((a) => isToday(a.date)).toList();

  int get todaySteps => todayActivities.fold(0, (sum, a) => sum + a.steps);

  int get todayCalories =>
      todayActivities.fold(0, (sum, a) => sum + a.calories);

  int get todayMinutes => todayActivities.fold(0, (sum, a) => sum + a.duration);

  Future<void> addActivity() async {
    final activity = await showDialog<FitnessActivity>(
      context: context,
      builder: (_) => const AddActivityDialog(),
    );

    if (activity == null) return;

    setState(() {
      activities.insert(0, activity);
    });

    await FitnessStorage.saveActivities(activities);
  }

  Future<void> deleteActivity(FitnessActivity activity) async {
    setState(() {
      activities.removeWhere((a) => a.id == activity.id);
    });

    await FitnessStorage.saveActivities(activities);
  }

  String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        title: const Text(
          'FitTrack',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: addActivity,
            tooltip: 'Add activity',
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addActivity,
        backgroundColor: const Color(0xFF6558F5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Log Activity'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          const Text(
            'Your daily activity',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            formatDate(DateTime.now()),
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            // Taller cells give the card contents room without overflow.
            childAspectRatio: 0.85,
            children: [
              FitnessSummaryCard(
                title: 'Steps',
                value: todaySteps.toString(),
                unit: '/ 10,000',
                icon: Icons.directions_walk,
                color: const Color(0xFF6558F5),
                progress: todaySteps / 10000,
              ),
              FitnessSummaryCard(
                title: 'Calories',
                value: todayCalories.toString(),
                unit: 'kcal',
                icon: Icons.local_fire_department,
                color: Colors.deepOrange,
                progress: todayCalories / 500,
              ),
              FitnessSummaryCard(
                title: 'Workout',
                value: todayMinutes.toString(),
                unit: '/ 60 min',
                icon: Icons.fitness_center,
                color: Colors.teal,
                progress: todayMinutes / 60,
              ),
              FitnessSummaryCard(
                title: 'Activities',
                value: todayActivities.length.toString(),
                unit: 'sessions',
                icon: Icons.check_circle_outline,
                color: Colors.blue,
                progress: todayActivities.length / 5,
              ),
            ],
          ),

          const SizedBox(height: 28),
          const Text(
            'Weekly Workout Progress',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          WeeklyChart(activities: activities),

          const SizedBox(height: 28),
          const Text(
            "Today's Activities",
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (todayActivities.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                children: [
                  Icon(Icons.directions_run, size: 42, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('No activities logged today.'),
                  Text(
                    'Tap "Log Activity" to get started.',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...todayActivities.map(
              (activity) => Card(
                color: Colors.white,
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFEAE8FF),
                    child: const Icon(
                      Icons.fitness_center,
                      color: Color(0xFF6558F5),
                    ),
                  ),
                  title: Text(
                    activity.type,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${activity.duration} min • '
                    '${activity.calories} kcal • '
                    '${activity.steps} steps',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => deleteActivity(activity),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AddActivityDialog extends StatefulWidget {
  const AddActivityDialog({super.key});

  @override
  State<AddActivityDialog> createState() => _AddActivityDialogState();
}

class _AddActivityDialogState extends State<AddActivityDialog> {
  final formKey = GlobalKey<FormState>();
  final durationController = TextEditingController();
  final caloriesController = TextEditingController();
  final stepsController = TextEditingController();

  String selectedType = 'Walking';

  final List<String> types = [
    'Walking',
    'Running',
    'Cycling',
    'Gym Workout',
    'Swimming',
    'Yoga',
    'Other',
  ];

  @override
  void dispose() {
    durationController.dispose();
    caloriesController.dispose();
    stepsController.dispose();
    super.dispose();
  }

  String? validateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }

    final number = int.tryParse(value.trim());

    if (number == null || number < 0) {
      return 'Enter a valid number';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Log Fitness Activity'),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Exercise Type',
                  border: OutlineInputBorder(),
                ),
                items: types
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  border: OutlineInputBorder(),
                ),
                validator: validateNumber,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: caloriesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Calories Burned (kcal)',
                  border: OutlineInputBorder(),
                ),
                validator: validateNumber,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: stepsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Steps',
                  border: OutlineInputBorder(),
                ),
                validator: validateNumber,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!formKey.currentState!.validate()) return;

            final activity = FitnessActivity(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              type: selectedType,
              duration: int.parse(durationController.text.trim()),
              calories: int.parse(caloriesController.text.trim()),
              steps: int.parse(stepsController.text.trim()),
              date: DateTime.now(),
            );

            Navigator.pop(context, activity);
          },
          child: const Text('Save Activity'),
        ),
      ],
    );
  }
}
