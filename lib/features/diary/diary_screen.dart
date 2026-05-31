import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_responsive.dart';
import '../theme/app_theme.dart';

import 'widgets/diary_app_bar.dart';
import 'widgets/daily_tab_view.dart';
import 'widgets/weekly_tab_view.dart';

import 'diary_controller/diary_controller.dart';
import 'diary_controller/diary_state.dart';

class DiaryScreen extends ConsumerStatefulWidget {
  const DiaryScreen({super.key});

  @override
  ConsumerState<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends ConsumerState<DiaryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Thêm lắng nghe sự thay đổi của tab để ẩn/hiện FloatingActionButton
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    // Gọi bộ cập nhật giao diện khi tab bắt đầu chuyển đổi sang trang mới
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diaryControllerProvider);
    final controller = ref.read(diaryControllerProvider.notifier);

    return Scaffold(
      body: Column(
        children: [
          // Truyền danh sách ngày và hàm chọn ngày xuống AppBar
          DiaryAppBar(
            weekDates: state.weekDates,
            selectedIndex: state.selectedIndex,
            onDaySelected: controller.selectDay,
          ),

          if (context.isDesktop)
            _buildDesktopBody(context, state)
          else
            _buildMobileBody(context, state),
        ],
      ),
      // Ẩn hoàn toàn nút Add nếu người dùng đang ở Tab theo tuần (index == 1)
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () async {
                final saved = await context.push('/add-meal');
                if (saved == true) controller.refresh();
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildDesktopBody(BuildContext context, DiaryState state) {
    return Expanded(
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              return NavigationRail(
                backgroundColor: Colors.white,
                selectedIndex: _tabController.index,
                onDestinationSelected: (i) {
                  _tabController.animateTo(i);
                  setState(() {}); // Đồng bộ lại việc ẩn hiện FAB trên Desktop
                },
                labelType: NavigationRailLabelType.all,
                selectedIconTheme: const IconThemeData(
                  color: AppColors.primary,
                ),
                selectedLabelTextStyle: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                unselectedLabelTextStyle: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.calendar_today_outlined),
                    label: Text('Theo ngày'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.bar_chart_outlined),
                    label: Text('Theo tuần'),
                  ),
                ],
              );
            },
          ),
          const VerticalDivider(width: 1, thickness: 0.5),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDailyTab(state),
                WeeklyTabView(weekDates: state.weekDates),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBody(BuildContext context, DiaryState state) {
    return Expanded(
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2,
            labelStyle: TextStyle(
              fontSize: context.fs(13),
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Theo ngày'),
              Tab(text: 'Theo tuần'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDailyTab(state),
                WeeklyTabView(weekDates: state.weekDates),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTab(DiaryState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return DailyTabView(
      record: state.currentRecord,
      meals: state.currentMeals,
    );
  }
}
