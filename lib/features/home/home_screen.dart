import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_responsive.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/responsive_wrapper.dart';

import 'widgets/ai_tip_card.dart';
import 'widgets/meal_group_list.dart';
import 'widgets/home_sliver_app_bar.dart';

import '../../providers/today_record_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/daily_record_model.dart';
import '../../models/meal_entry_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe dữ liệu ngày hôm nay (đã có offline fallback bên trong provider)
    final todayAsync = ref.watch(todayRecordProvider);

    // Lấy tên người dùng
    final authState = ref.watch(authStateProvider);
    final userProfile = ref.watch(userProfileProvider);
    final userName = authState.value?.userMetadata?['name'] as String? ??
        userProfile.valueOrNull?.name ??
        'Người dùng';

    return Scaffold(
      // Bọc toàn bộ màn hình bằng RefreshIndicator
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          // Invalidate để tải lại từ server (hoặc cache)
          ref.invalidate(todayRecordProvider);
          // Đợi provider hoàn thành
          await ref.read(todayRecordProvider.future);
        },
        // Dùng CustomScrollView thay cho Column tổng
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // Header
            HomeSliverAppBar(
              userName: userName,
              record: todayAsync.valueOrNull,
            ),

            SliverToBoxAdapter(
              child: ResponsiveWrapper(
                useScroll: false,
                child: todayAsync.when(
                  loading: () => const SizedBox(
                    height: 300,
                    child: Center(
                        child: CircularProgressIndicator(
                      color: AppColors.primary,
                    )),
                  ),
                  error: (err, _) {
                    print('=== TODAY ERROR: $err ===');
                    return _buildErrorView(ref);
                  },
                  data: (record) => _buildDataView(context, record),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            'Không thể tải dữ liệu',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => ref.invalidate(todayRecordProvider),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildDataView(BuildContext context, DailyRecordModel? record) {
    // Thay vì return text, tạo record rỗng để hiện UI đầy đủ
    final consumed = record?.caloriesConsumed.toInt() ?? 0;
    final goal = record?.caloriesGoal?.toInt() ?? 2000;
    final meals = record?.meals ?? []; // list rỗng → EmptyMealState sẽ hiện

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        CalorieProgressBar(consumed: consumed, goal: goal),
        const SizedBox(height: 14),
        if (context.isDesktop)
          _buildDesktopLayout(meals)
        else
          _buildMobileLayout(meals),
        const SizedBox(height: 40),
      ],
    );
  }

  // --- LAYOUT CHIA CỘT CHO DESKTOP ---
  Widget _buildDesktopLayout(List<MealEntryModel> meals) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cột trái (Chiếm 2/3 không gian): Danh sách bữa ăn
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Bữa ăn hôm nay',
                actionLabel: 'Xem tất cả',
                onAction: () {},
              ),
              const SizedBox(height: 12),
              MealGroupList(meals: meals),
            ],
          ),
        ),

        const SizedBox(width: 32), // Khoảng cách giữa 2 cột
        // Cột phải (Chiếm 1/3 không gian): Widget AI & Trợ lý
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Trợ lý AI NutriScan',
                onAction: () {},
              ),
              const SizedBox(height: 12),
              AiTipCard(),
            ],
          ),
        ),
      ],
    );
  }

  // --- LAYOUT DỌC CHO MOBILE ---
  Widget _buildMobileLayout(List<MealEntryModel> meals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Bữa ăn hôm nay',
          actionLabel: 'Xem tất cả',
          onAction: () {},
        ),
        const SizedBox(height: 12),
        MealGroupList(meals: meals),
        const SizedBox(height: 20),
        AiTipCard(),
      ],
    );
  }
}
