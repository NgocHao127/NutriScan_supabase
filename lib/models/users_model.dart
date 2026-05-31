class UserModel {
  final String id; // UUID từ Supabase
  final String? name;
  final int? age;
  final String? gender;
  final double? height;
  final double? weight;
  final String? goal;
  final String? activityLevel;
  final int? calorieGoal;
  final int? proteinGoal;
  final int? carbsGoal;
  final int? fatGoal;
  final String? email;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double? bmi;
  final String? bmiCategory;
  final String? bodyShape;
  final bool? notifyMeal;
  final bool? notifyWeekly;
  final bool? notifyAlert;
  String? get uid => id;

  UserModel({
    required this.id,
    this.email,
    this.name,
    this.age,
    this.height,
    this.weight,
    this.goal,
    this.activityLevel,
    this.gender,
    this.calorieGoal,
    this.proteinGoal,
    this.carbsGoal,
    this.fatGoal,
    this.createdAt,
    this.updatedAt,
    this.bmi,
    this.bmiCategory,
    this.bodyShape,
    this.notifyMeal,
    this.notifyWeekly,
    this.notifyAlert,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['uid'] ?? json['id'] ?? '',
      email: json['email'],
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      goal: json['goal'],
      activityLevel: json['activity_level'],
      calorieGoal: json['calorie_goal'],
      proteinGoal: json['proteinGoal'],
      carbsGoal: json['carbsGoal'],
      fatGoal: json['fatGoal'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      bmi: (json['bmi'] as num?)?.toDouble(),
      bmiCategory: json['bmi_category'],
      bodyShape: json['body_shape'],
      notifyMeal: json['notify_meal'],
      notifyWeekly: json['notify_weekly'],
      notifyAlert: json['notify_alert'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (goal != null) 'goal': goal,
      if (activityLevel != null) 'activity_level': activityLevel,
      if (calorieGoal != null) 'calorie_goal': calorieGoal,
      if (proteinGoal != null) 'protein_goal': proteinGoal,
      if (carbsGoal != null) 'carbs_goal': carbsGoal,
      if (fatGoal != null) 'fat_goal': fatGoal,
      if (bodyShape != null) 'body_shape': bodyShape,
      if (notifyMeal != null) 'notify_meal': notifyMeal,
      if (notifyWeekly != null) 'notify_weekly': notifyWeekly,
      if (notifyAlert != null) 'notify_alert': notifyAlert,
    };
  }
}

extension UserExtension on UserModel? {
  int get safeCaloriesGoal => this?.calorieGoal ?? 2000;
  double get safeProteinGoal => (this?.proteinGoal ?? 150).toDouble();
  double get safeCarbsGoal => (this?.carbsGoal ?? 250).toDouble();
  double get safeFatGoal => (this?.fatGoal ?? 65).toDouble();

  String get safeGoal => this?.goal ?? 'Chưa đặt mục tiêu';
  String get safeActivityLevel => this?.activityLevel ?? 'Chưa cập nhật';
}
