import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_responsive.dart';
import '../../../models/meal_entry_model.dart';
import '../../../models/meal_item_model.dart';

class MealGroupList extends StatelessWidget {
  final List<MealEntryModel> meals;

  const MealGroupList({super.key, required this.meals});

  @override
  Widget build(BuildContext context) {
    // Nếu danh sách rỗng thì trả về giao diện Trống
    if (meals.isEmpty) {
      return const EmptyMealState();
    }

    // Tự động gom nhóm thức ăn theo bữa
    final grouped = <String, List<MealEntryModel>>{};
    for (final m in meals) {
      grouped.putIfAbsent(m.mealType, () => []).add(m);
    }

    // Lặp qua 4 bữa để render ra các MealGroup
    const types = ['Bữa sáng', 'Bữa trưa', 'Bữa tối', 'Ăn vặt'];

    if (context.isTablet || context.isDesktop) {
      return Column(
        children: types.map((type) {
          final entries = grouped[type] ?? [];
          // Tổng calo của loại bữa này
          final totalCal = entries.fold(0.0, (s, m) => s + m.calories).toInt();
          // Gom tất cả meal_items của loại này
          final mealItems = entries.expand((entry) => entry.items).toList();

          return MealGroup(
            type: type,
            mealItems: mealItems,
            totalCal: totalCal,
            useGrid: context.isDesktop,
          );
        }).toList(),
      );
    }

    return Column(
      children: types.map((type) {
        final entries = grouped[type] ?? [];
        // Tổng calo của loại bữa này
        final totalCal = entries.fold(0.0, (s, m) => s + m.calories).toInt();
        // Gom tất cả meal_items của loại này
        final mealItems = entries.expand((entry) => entry.items).toList();

        return MealGroup(type: type, mealItems: mealItems, totalCal: totalCal);
      }).toList(),
    );
  }
}

class MealGroup extends StatelessWidget {
  final String type;
  final List<MealItemModel> mealItems;
  final int totalCal;
  final bool useGrid;

  const MealGroup({
    super.key,
    required this.type,
    required this.mealItems,
    required this.totalCal,
    this.useGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              type,
              style: TextStyle(
                fontSize: context.fs(11),
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 0.5,
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
            if (mealItems.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                '$totalCal kcal',
                style: TextStyle(
                  fontSize: context.fs(11),
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        if (mealItems.isEmpty)
          const SizedBox.shrink()
        else if (useGrid)
          _buildGrid(context)
        else
          Column(
              children: mealItems.map((item) => MealCard(item: item)).toList()),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 3.2,
      ),
      itemCount: mealItems.length,
      itemBuilder: (_, i) => MealCard(
        item: mealItems[i],
      ),
    );
  }
}

class MealCard extends StatelessWidget {
  final MealItemModel item;

  const MealCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = context.iconSize(36, tablet: 40, desktop: 44);
    final timeStr = item.mealTime != null
        ? "${item.mealTime!.hour.toString().padLeft(2, '0')}:${item.mealTime!.minute.toString().padLeft(2, '0')}"
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(context.cardRadius),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(iconSize * 0.28),
            ),
            child: Center(
              child: Text(
                '🍽️', // Tạm gắn emoji mặc định
                style: TextStyle(fontSize: iconSize * 0.52),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.foodName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: context.fs(13),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      timeStr.isNotEmpty ? timeStr : '',
                      style: TextStyle(
                        fontSize: context.fs(11),
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (timeStr.isNotEmpty && item.portion.isNotEmpty)
                      Text(
                        ' · ',
                        style: TextStyle(
                          fontSize: context.fs(11),
                          color: AppColors.textHint,
                        ),
                      ),
                    if (item.portion.isNotEmpty)
                      Text(
                        item.portion,
                        style: TextStyle(
                          fontSize: context.fs(11),
                          color: AppColors.textHint,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.calories.toInt()} kcal',
                style: TextStyle(
                  fontSize: context.fs(12),
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'P${item.protein.toInt()} · C${item.carbs.toInt()} · F${item.fat.toInt()}', // Giữ nguyên UI, sẽ map thực tế sau
                style: TextStyle(
                  fontSize: context.fs(10),
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmptyMealState extends StatelessWidget {
  final String? mealType;

  const EmptyMealState({super.key, this.mealType});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(context.cardRadius),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon minh họa (có thể thay bằng Image.asset nếu bạn có hình)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant_menu_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 20),
          Text(
            'Bạn chưa ăn gì hôm nay?',
            style: TextStyle(
              fontSize: context.fs(16),
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 8),
          Text(
            'Hãy ghi lại bữa ăn đầu tiên để theo dõi lượng Calo nhé!',
            textAlign: TextAlign.center,
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
