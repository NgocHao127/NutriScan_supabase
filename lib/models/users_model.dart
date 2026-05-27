class UserModel {
  final String uid; // Firebase UID, bắt buộc
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

  UserModel({
    required this.uid,
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
      uid: json['uid'] ?? '',
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

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (goal != null) 'goal': goal,
      if (activityLevel != null) 'activity_level': activityLevel,
      if (calorieGoal != null) 'calorie_goal': calorieGoal,
      // created_at, updated_at Supabase sẽ tự động tạo nên không cần gửi lên
    };
  }
}
