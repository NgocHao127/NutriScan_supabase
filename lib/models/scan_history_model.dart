class ScanHistoryModel {
  final String? id; // server ID (có thể null khi tạo mới)
  final String userId;
  final String? foodId; // ID của FoodItem hoặc null
  final double? confidence;
  final DateTime scannedAt;
  final String? imageUrl;

  ScanHistoryModel({
    this.id,
    required this.userId,
    this.foodId,
    this.confidence,
    required this.scannedAt,
    this.imageUrl,
  });

  factory ScanHistoryModel.fromJson(Map<String, dynamic> json) {
    return ScanHistoryModel(
      id: json['id']?.toString(),
      userId: json['user_id'] ?? '',
      foodId: json['food_id']?.toString(),
      confidence: (json['confidence'] as num?)?.toDouble(),
      scannedAt: DateTime.parse(json['scanned_at']),
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      if (foodId != null) 'food_id': foodId,
      if (confidence != null) 'confidence': confidence,
      'scanned_at': scannedAt.toIso8601String(),
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }
}
