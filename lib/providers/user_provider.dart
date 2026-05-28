import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/users_model.dart';
import 'api_provider.dart';

final userProfileProvider = FutureProvider<UserModel?>((ref) async {
  final userService = ref.watch(userServiceProvider);
  print('=== FETCHING USER PROFILE ===');
  try {
    final data = await userService.getProfile();
    print('=== USER PROFILE DATA: $data ===');
    return UserModel.fromJson(data);
  } catch (e) {
    print('=== USER PROFILE ERROR: $e ===');
    // Trả về null nếu lỗi (có thể cải thiện sau với cache)
    return null;
  }
});
