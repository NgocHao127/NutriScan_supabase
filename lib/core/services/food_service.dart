import 'package:dio/dio.dart';
import '../api_service.dart';
import '../../models/food_model.dart';

class FoodService {
  final ApiService _api;
  FoodService(this._api);

  Future<List<dynamic>> analyzeFood(String imagePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imagePath, filename: 'food.jpg'),
    });
    final response = await _api.post('/food/analyze', data: formData);
    final body = _api.mapFromResponse(response.data);
    final items = body?['items'];
    return (items is List) ? items : [];
  }

  Future<List<FoodModel>> searchFoods(String query) async {
    final response = await _api.get('/foods/search', params: {'query': query});
    return (response.data as List).map((e) => FoodModel.fromJson(e)).toList();
  }

  Future<void> addCustomFood({
    required String name,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    double servingSize = 100,
    String servingUnit = 'g',
    String? imageUrl,
  }) async {
    await _api.post('/foods/custom', data: {
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'serving_size': servingSize,
      'serving_unit': servingUnit,
      if (imageUrl != null) 'image_url': imageUrl,
    });
  }

  Future<void> confirmAiFood(FoodModel food) async {
    await _api.post('/foods/confirm-ai', data: {
      'name': food.name,
      'calories': food.calories,
      'protein': food.protein,
      'carbs': food.carbs,
      'fat': food.fat,
      'serving_size': food.servingSize,
      'serving_unit': food.servingUnit,
    });
  }

  Future<String> uploadFoodImage(FormData formData) async {
    final response = await _api.post('/foods/upload-image', data: formData);
    final body = _api.mapFromResponse(response.data);
    return body?['image_url'] as String? ?? '';
  }
}
