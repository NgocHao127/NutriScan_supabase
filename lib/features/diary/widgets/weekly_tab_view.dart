import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_responsive.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

import '../diary_controller/weekly_state.dart';
import '../diary_controller/weekly_controller.dart';

class WeeklyTabView extends ConsumerStatefulWidget {
  final List<DateTime> weekDates; // Nhận danh sách ngày từ DiaryScreen

  const WeeklyTabView({super.key, required this.weekDates});

  @override
  ConsumerState<WeeklyTabView> createState() => _WeeklyTabViewState();
}

class _WeeklyTabViewState extends ConsumerState<WeeklyTabView> {
  @override
  void initState() {
    super.initState();
    // Init controller với weekDates sau frame đầu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(weeklyControllerProvider.notifier).init(widget.weekDates);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weeklyControllerProvider);
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final maxVal = 2500;
    // Chiều cao chart: cố định dp thay vì % sh — không bị khổng lồ trên desktop
    final chartH = context.isDesktop
        ? 180.0
        : context.isTablet
            ? 160.0
            : 130.0;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: context.hPad, vertical: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.maxContentWidth),
          child: context.isDesktop
              ? _buildDesktopLayout(
                  context,
                  state,
                  days,
                  maxVal,
                  chartH,
                )
              : _buildMobileLayout(
                  context,
                  state,
                  days,
                  maxVal,
                  chartH,
                ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    WeeklyState state,
    List<String> days,
    int maxVal,
    double chartH,
  ) {
    final metricCols = context.isTablet ? 3 : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChart(context, state, days, maxVal, chartH),
        const SizedBox(height: 4),
        _buildGoalLabel(context, state.goal),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: metricCols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          childAspectRatio: context.isTablet ? 2.2 : 1.6,
          children: _buildMetricCards(state),
        ),
        const SizedBox(height: 12),
        _buildAiComment(context),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    WeeklyState state,
    List<String> days,
    int maxVal,
    double chartH,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChart(context, state, days, maxVal, chartH,),
        const SizedBox(height: 4),
        _buildGoalLabel(context, state.goal),
        const SizedBox(height: 12),
        Row(
          children: _buildMetricCards(
                  state)
              .map((card) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: card,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        _buildAiComment(context),
        const SizedBox(height: 16),
      ],
    );
  }

  List<Widget> _buildMetricCards(WeeklyState state) {
    return [
      MetricCard(
        value: '$state.avgCals',
        label: 'TB calo / ngày',
        sub: state.avgCals > 0
            ? '${state.avgCals - state.goal} so với mục tiêu'
            : 'Chưa có dữ liệu',
      ),
      MetricCard(
        value: '$state.daysOverGoal / 7',
        label: 'Ngày vượt mục tiêu',
        sub: 'Cố gắng giữ phong độ',
        subColor: state.daysOverGoal > 0 ? AppColors.danger : AppColors.textSecondary,
      ),
      MetricCard(
        value: '${state.avgProtein}g',
        label: 'Protein TB',
        sub: 'mục tiêu ${state.proteinGoal}g',
        subColor: AppColors.protein,
      ),
      const MetricCard(
        value: '0 ngày',
        label: 'Streak ghi log',
        sub: 'Giữ vững nhé!',
      ),
    ];
  }

  Widget _buildChart(
    BuildContext context,
    WeeklyState state,
    List<String> days,
    int maxVal,
    double chartH,
  ) {
    // Tìm index của ngày hôm nay (0-6)
    final todayIndex = DateTime.now().weekday - 1;

    return SizedBox(
      height: chartH,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final val = state.cals[i];
          final barH = val > 0
              ? ((val / maxVal) * (chartH * 0.75)).clamp(8.0, chartH * 0.75)
              : 8.0;
          final isToday = i == todayIndex;

          final color = val == 0
              ? Colors.grey[200]!
              : val > state.goal
                  ? AppColors.danger.withValues(alpha: 0.7)
                  : AppColors.primaryAccent;

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (val > 0)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${(val / 1000).toStringAsFixed(1)}k',
                      style: TextStyle(
                        fontSize: context.fs(9),
                        color: isToday
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight:
                            isToday ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                const SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                    child: Container(
                      height: (barH - 35).clamp(4.0, barH),
                      color: isToday ? AppColors.primary : color,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  days[i],
                  style: TextStyle(
                    fontSize: context.fs(9),
                    color:
                        isToday ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isToday ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGoalLabel(BuildContext context, int goal) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        'Mục tiêu: $goal cal',
        style: TextStyle(fontSize: context.fs(9), color: AppColors.primary),
      ),
    );
  }

  Widget _buildAiComment(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(context.cardRadius),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nhận xét tuần từ AI',
            style: TextStyle(
              fontSize: context.fs(11),
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hiện tại dữ liệu còn ít. Hãy chăm chỉ ghi nhận bữa ăn mỗi ngày để AI có thể phân tích xu hướng dinh dưỡng của bạn nhé!',
            style: TextStyle(
              fontSize: context.fs(12),
              color: AppColors.primaryDark,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
