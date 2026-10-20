
class FitnessActivity {
  final String id;
  final String type;
  final int duration;
  final int calories;
  final int steps;
  final DateTime date;

  FitnessActivity({
    required this.id,
    required this.type,
    required this.duration,
    required this.calories,
    required this.steps,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'duration': duration,
        'calories': calories,
        'steps': steps,
        'date': date.toIso8601String(),
      };

  factory FitnessActivity.fromJson(Map<String, dynamic> json) {
    return FitnessActivity(
      id: json['id'],
      type: json['type'],
      duration: json['duration'],
      calories: json['calories'],
      steps: json['steps'],
      date: DateTime.parse(json['date']),
    );
  }
}
