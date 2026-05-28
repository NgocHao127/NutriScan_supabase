import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_responsive.dart';
import '../../../models/meal_entry_model.dart';

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
          final items = grouped[type] ?? [];
          final totalCal = items.fold(0.0, (s, m) => s + m.calories).toInt();

          return MealGroup(
            type: type,
            items: items,
            totalCal: totalCal,
            useGrid: context.isDesktop,
          );
        }).toList(),
      );
    }

    return Column(
      children: types.map((type) {
        final items = grouped[type] ?? [];
        final totalCal = items.fold(0.0, (s, m) => s + m.calories).toInt();

        return MealGroup(type: type, items: items, totalCal: totalCal);
      }).toList(),
    );
  }
}

class MealGroup extends StatelessWidget {
  final String type;
  final List<MealEntryModel> items;
  final int totalCal;
  final bool useGrid;

  const MealGroup({
    super.key,
    required this.type,
    required this.items,
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
            if (items.isNotEmpty) ...[
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
        if (items.isEmpty)
          AddMealButton(type: type)
        else if (useGrid)
          _buildGrid(context, items)
        else
          Column(children: items.map((m) => MealCard(meal: m)).toList()),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildGrid(BuildContext context, List<MealEntryModel> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 3.2,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => MealCard(meal: items[i]),
    );
  }
}

class MealCard extends StatelessWidget {
  final MealEntryModel meal;

  const MealCard({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    final iconSize = context.iconSize(36, tablet: 40, desktop: 44);

    // Format thời gian từ DateTime (VD: 14:30)
    final timeStr =
        "${meal.mealTime.hour.toString().padLeft(2, '0')}:${meal.mealTime.minute.toString().padLeft(2, '0')}";

    // Tính toán macro thực tế từ danh sách món ăn
    double totalProtein = 0, totalCarbs = 0, totalFat = 0;
    for (final item in meal.items) {
      totalProtein += item.protein;
      totalCarbs += item.carbs;
      totalFat += item.fat;
    }

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
                '🍲', // Tạm gắn emoji mặc định
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
                  meal.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: context.fs(13),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: context.fs(11),
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${meal.calories.toInt()} kcal',
                style: TextStyle(
                  fontSize: context.fs(12),
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'P${totalProtein.toInt()} · C${totalCarbs.toInt()} · F${totalFat.toInt()}', // Giữ nguyên UI, sẽ map thực tế sau
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

class AddMealButton extends StatelessWidget {
  final String type;

  const AddMealButton({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/add-meal', extra: type),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.cardRadius),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: context.fs(14), color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              'Thêm $type',
              style: TextStyle(
                fontSize: context.fs(12),
                color: AppColors.primary,
              ),
            ),
          ],
        ),
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

          const SizedBox(height: 24),
          // Nút CTA (Call-to-Action)
          ElevatedButton.icon(
            onPressed: () => context.push('/add-meal', extra: mealType),
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            label: const Text(
              'Thêm bữa ăn ngay',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryMid,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
