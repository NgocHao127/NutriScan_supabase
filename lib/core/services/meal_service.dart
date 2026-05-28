import '../api_service.dart';

class MealService {
  final ApiService _api;
  MealService(this._api);

  Future<Map<String, dynamic>> getDailyRecord({String? date}) async {
    final params = <String, dynamic>{};
    if (date != null) params['date'] = date;
    final response = await _api.get('/meal/daily', params: params);
    return _api.mapFromResponse(response.data) ?? {};
  }

  Future<Map<String, dynamic>> logMeal(Map<String, dynamic> mealData) async {
    final response = await _api.post('/meal/log', data: mealData);
    return _api.mapFromResponse(response.data) ?? {};
  }
}
