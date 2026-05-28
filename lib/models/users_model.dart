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
  final String? email;
  final DateTime? createdAt;
  final DateTime? updatedAt;
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
    this.createdAt,
    this.updatedAt,
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
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
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
    };
  }
}
