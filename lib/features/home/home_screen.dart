import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutriscan/features/home/home_controller/home_state.dart';
import '../theme/app_responsive.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/responsive_wrapper.dart';

import 'widgets/ai_tip_card.dart';
import '../widgets/meal_group_list.dart';
import 'widgets/home_sliver_app_bar.dart';

import 'home_controller/home_controller.dart';
import '../../models/meal_entry_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeControllerProvider);
    final controller = ref.read(homeControllerProvider.notifier);

    return Scaffold(
      // Bọc toàn bộ màn hình bằng RefreshIndicator
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.refresh,
        // Dùng CustomScrollView thay cho Column tổng
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // Header
            HomeSliverAppBar(
              userName: homeAsync.valueOrNull?.userName ?? '...',
              record: homeAsync.valueOrNull?.record,
            ),

            SliverToBoxAdapter(
              child: ResponsiveWrapper(
                useScroll: false,
                child: homeAsync.when(
                  loading: () => const SizedBox(
                    height: 300,
                    child: Center(
                        child: CircularProgressIndicator(
                      color: AppColors.primary,
                    )),
                  ),
                  error: (err, _) => _buildErrorView(onRetry: controller.refresh),
                  data: (state) => _buildDataView(context, state),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-meal'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildErrorView({required VoidCallback onRetry}) {
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
            onPressed: onRetry,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildDataView(BuildContext context, HomeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        CalorieProgressBar(consumed: state.consumed, goal: state.goal),
        const SizedBox(height: 14),
        if (context.isDesktop)
          _buildDesktopLayout(state.meals)
        else
          _buildMobileLayout(state.meals),
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
