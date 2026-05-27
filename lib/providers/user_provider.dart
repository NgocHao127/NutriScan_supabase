import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/users_model.dart';
import 'api_provider.dart';

final userProfileProvider = FutureProvider<UserModel?>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final data = await apiService.getProfile();
    return UserModel.fromJson(data);
  } catch (e) {
    // Trả về null nếu lỗi (có thể cải thiện sau với cache)
    return null;
  }
});
