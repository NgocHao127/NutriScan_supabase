import 'package:dio/dio.dart';
import '../api_service.dart';

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
}