import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_state.dart';
import '../../../providers/today_record_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/user_provider.dart';

class HomeController extends AutoDisposeAsyncNotifier<HomeState> {
  @override
  FutureOr<HomeState> build() async {
    //Lấy thông tin user
    final authState = ref.watch(authStateProvider);
    final userProfile = ref.watch(userProfileProvider);

    final userName = authState.value?.userMetadata?['name'] as String? ??
        userProfile.valueOrNull?.name ??
        'Người dùng';

    // Lấy record từ todayAsync
    final record = await ref.watch(todayRecordProvider.future);

    // Trả về Data sạch
    return HomeState(
      userName: userName,
      record: record,
    );
  }

  // Refresh dữ liệu
  Future<void> refresh() async {
    ref.invalidate(todayRecordProvider);
  }
}

final homeControllerProvider =
    AutoDisposeAsyncNotifierProvider<HomeController, HomeState>(
  HomeController.new,
);
