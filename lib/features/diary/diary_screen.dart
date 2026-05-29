import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_responsive.dart';
import '../theme/app_theme.dart';

import 'widgets/diary_app_bar.dart';
import 'widgets/daily_tab_view.dart';
import 'widgets/weekly_tab_view.dart';

import '../../models/daily_record_model.dart';
import '../../models/meal_entry_model.dart';
import '../../providers/api_provider.dart';

class DiaryScreen extends ConsumerStatefulWidget {
  const DiaryScreen({super.key});

  @override
  ConsumerState<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends ConsumerState<DiaryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Các biến xử lý Logic Ngày & Dữ liệu
  late List<DateTime> _weekDates;
  int _selectedIndex = 0;
  bool _isLoading = true;

  DailyRecordModel? _currentRecord;
  List<MealEntryModel> _currentMeals = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initWeekDates();
  }

  // Khởi tạo danh sách 7 ngày của tuần hiện tại (Từ Thứ 2 đến Chủ nhật)
  void _initWeekDates() {
    final now = DateTime.now();
    // Weekday: 1 = Thứ 2, 7 = Chủ nhật
    final monday = now.subtract(
      Duration(days: now.weekday - 1),
    ); // Tính ngày Thứ 2

    _weekDates = List.generate(7, (index) => monday.add(Duration(days: index)));

    // Mặc định chọn ngày hôm nay
    _selectedIndex = now.weekday - 1; // -1 vì index từ 0

    // Gọi API lấy dữ liệu của ngày được chọn
    _fetchDataForSelectedDay();
  }

  Future<void> _fetchDataForSelectedDay() async {
    setState(() => _isLoading = true);
    try {
      final selectedDate = _weekDates[_selectedIndex];
      final mealService = ref.read(mealServiceProvider);

      // Thử lấy từ cache isar trước
      final data = await mealService.getDailyRecord(
        date: selectedDate.toIso8601String().substring(0, 10),
      );
      if (data.isNotEmpty) {
        final serverRecord = DailyRecordModel.fromJson(data);
        _currentRecord = serverRecord;
        _currentMeals = serverRecord.meals;
      } else {
        _currentRecord = null;
        _currentMeals = [];
      }
    } catch (_) {
      _currentRecord = null;
      _currentMeals = [];
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _onDaySelected(int index) {
    if (_selectedIndex == index)
      return; // Nếu chọn lại ngày đang xem thì không làm gì
    setState(() => _selectedIndex = index);
    _fetchDataForSelectedDay();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Truyền danh sách ngày và hàm chọn ngày xuống AppBar
          DiaryAppBar(
            weekDates: _weekDates,
            selectedIndex: _selectedIndex,
            onDaySelected: _onDaySelected,
          ),

          if (context.isDesktop) ...[
            _buildDesktopBody(),
          ] else ...[
            _buildMobileBody(context),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-meal'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDesktopBody() {
    return Expanded(
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              return NavigationRail(
                backgroundColor: Colors.white,
                selectedIndex: _tabController.index,
                onDestinationSelected: (i) =>
                    setState(() => _tabController.animateTo(i)),
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
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : DailyTabView(
                        record: _currentRecord,
                        meals: _currentMeals,
                      ),
                WeeklyTabView(weekDates: _weekDates),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBody(BuildContext context) {
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
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : DailyTabView(
                        record: _currentRecord,
                        meals: _currentMeals,
                      ),
                WeeklyTabView(weekDates: _weekDates),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
