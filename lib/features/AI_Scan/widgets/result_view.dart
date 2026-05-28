import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_responsive.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

import '../../../models/food_model.dart';
import '../../../models/meal_entry_model.dart';
import '../../../providers/api_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/today_record_provider.dart';

class FoodScanResult {
  final String name;
  final String emoji;
  final double confidence;
  final double calories;
  final double protein;
  final double carb;
  final double fat;

  const FoodScanResult({
    required this.name,
    required this.emoji,
    required this.confidence,
    required this.calories,
    required this.protein,
    required this.carb,
    required this.fat,
  });

  // Factory để tạo từ FoodItem (kết quả AI trả về)
  factory FoodScanResult.fromFoodItem(
    FoodItem item, {
    double confidence = 0.9,
  }) {
    return FoodScanResult(
      name: item.name,
      emoji: _getEmojiForFood(item.name),
      confidence: confidence,
      calories: item.calories,
      protein: item.protein,
      carb: item.carbs,
      fat: item.fat,
    );
  }

  // Hàm gợi ý emoji đơn giản dựa trên tên món
  static String _getEmojiForFood(String name) {
    if (name.contains('cơm')) return '🍚';
    if (name.contains('phở') || name.contains('bún')) return '🍜';
    if (name.contains('bánh mì')) return '🥖';
    if (name.contains('trứng')) return '🥚';
    if (name.contains('rau')) return '🥬';
    if (name.contains('thịt')) return '🍖';
    if (name.contains('cá')) return '🐟';
    if (name.contains('trái cây') || name.contains('hoa quả')) return '🍎';
    if (name.contains('sữa')) return '🥛';
    return '🍽️';
  }
}

class ResultView extends ConsumerStatefulWidget {
  final List<FoodItem> foods;
  final VoidCallback onRetry;
  final VoidCallback? onSave;

  const ResultView({
    super.key,
    required this.onRetry,
    required this.foods,
    this.onSave,
  });

  @override
  ConsumerState<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends ConsumerState<ResultView> {
  // Tổng hợp từ nhiều món (nếu có)
  FoodScanResult get _aggregatedResult {
    if (widget.foods.isEmpty) {
      return const FoodScanResult(
        name: 'Không xác định',
        emoji: '❓',
        confidence: 0,
        calories: 0,
        protein: 0,
        carb: 0,
        fat: 0,
      );
    }
    // Lấy món đầu tiên làm đại diện (có thể cải tiến sau)
    final first = widget.foods.first;
    return FoodScanResult.fromFoodItem(first);
  }

  @override
  Widget build(BuildContext context) {
    final food = _aggregatedResult;

    // Emoji bg — cố định fontSize
    final emojiFontSize = context.isDesktop
        ? 100.0
        : context.isTablet
            ? 80.0
            : (context.sw * 0.18).clamp(60.0, 120.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background camera
        Container(
          color: const Color(0xFF1E2A18),
          child: Center(
            child: Text(
              food.emoji,
              style: TextStyle(fontSize: emojiFontSize, color: Colors.white54),
            ),
          ),
        ),
        // Back button
        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.hPad,
              vertical: 10,
            ),
            child: Row(
              children: [
                CamBtn(icon: Icons.arrow_back, onTap: widget.onRetry),
                const Spacer(),
              ],
            ),
          ),
        ),
        // Detect badge
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 48),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${food.name} — ${(food.confidence * 100).toInt()}% độ chính xác',
                  style: TextStyle(
                    fontSize: context.fs(11),
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Result sheet — desktop: chia đôi màn hình dọc, không full bottom
        if (context.isDesktop)
          DesktopResultSheet(
            food: food,
            onRetry: widget.onRetry,
            foods: widget.foods,
          )
        else
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ResultSheet(
              food: food,
              onRetry: widget.onRetry,
              foods: widget.foods,
            ),
          ),
      ],
    );
  }
}

// ── Desktop: panel bên phải, dạng thẻ nổi (Floating Panel) kéo ra từ cạnh phải ──
class DesktopResultSheet extends StatelessWidget {
  final FoodScanResult food;
  final VoidCallback onRetry;
  final List<FoodItem> foods;

  const DesktopResultSheet({
    super.key,
    required this.food,
    required this.onRetry,
    required this.foods,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: context.sw * 0.4,
        height: double.infinity,
        margin: const EdgeInsets.only(top: 20, bottom: 20),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          // Chỉ bo tròn 2 góc bên trái để tạo cảm giác thẻ dính liền với lề phải
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(32),
          ),
          // Đổ bóng sang trái để tạo chiều sâu, tách biệt với nền Camera
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 30,
              offset: const Offset(-8, 5),
            ),
          ],
        ),
        // ClipRRect đảm bảo khi cuộn nội dung, chữ không bị đâm lẹm ra ngoài phần góc bo
        child: ClipRRect(
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(32),
          ),
          child: SafeArea(
            // Tắt viền an toàn trên dưới vì chúng ta đã dùng margin để chừa khoảng cách rồi
            top: false,
            bottom: false,
            child: SingleChildScrollView(
              child: ResultSheet(
                food: food,
                onRetry: onRetry,
                foods: foods,
                isDesktop: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Result sheet (dùng chung mobile + desktop)
class ResultSheet extends ConsumerStatefulWidget {
  final FoodScanResult food;
  final VoidCallback onRetry;
  final List<FoodItem> foods;
  final bool isDesktop;

  const ResultSheet({
    super.key,
    required this.food,
    required this.onRetry,
    required this.foods,
    this.isDesktop = false,
  });

  @override
  ConsumerState<ResultSheet> createState() => _ResultSheetState();
}

class _ResultSheetState extends ConsumerState<ResultSheet> {
  int portion = 1;
  bool _isSaving = false;

  Future<void> _saveToDiary(double actualCalories) async {
    setState(() => _isSaving = true);
    try {
      final mealService = ref.read(mealServiceProvider);
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception('Chưa đăng nhập');

      final multipliedFoods = widget.foods.map((f) {
        return FoodItem(
          name: f.name,
          calories: f.calories * portion,
          protein: f.protein * portion,
          carbs: f.carbs * portion,
          fat: f.fat * portion,
          portion: '$portion phần',
        );
      }).toList();

      final totalCalories = multipliedFoods.fold(0.0, (s, f) => s + f.calories);

      final hour = DateTime.now().hour;
      String mealType = 'Ăn vặt';
      if (hour >= 5 && hour <= 10) {
        mealType = 'Bữa sáng';
      } else if (hour > 10 && hour <= 14) {
        mealType = 'Bữa trưa';
      } else if (hour >= 17 && hour < 22) {
        mealType = 'Bữa tối';
      }

      final newMeal = MealEntryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.id,
        name: 'Bữa ăn từ scan',
        mealType: mealType,
        mealTime: DateTime.now(),
        calories: totalCalories,
        items: multipliedFoods,
      );

      await mealService.logMeal(newMeal.toJson());

      ref.invalidate(todayRecordProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Đã lưu vào nhật ký!'),
            backgroundColor: Colors.green),
      );
      widget.onRetry();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.danger),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;
    final actualCalories = food.calories * portion;
    final actualProtein = food.protein * portion;
    final actualCarb = food.carb * portion;
    final actualFat = food.fat * portion;
    final portionGrams = 500 * portion;
    // Cố định dp
    final thumbSize = context.iconSize(52, tablet: 58, desktop: 64).toDouble();
    final btnH = context.iconSize(44, tablet: 48, desktop: 52).toDouble();
    final portionBtnSize =
        context.iconSize(28, tablet: 32, desktop: 36).toDouble();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: widget.isDesktop
            ? const BorderRadius.horizontal(left: Radius.circular(20))
            : const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle (chỉ hiện trên mobile/tablet)
          if (!widget.isDesktop) ...[
            SizedBox(height: 10),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],

          const SizedBox(height: 30),
          // Food header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.hPad),
            child: Row(
              children: [
                Container(
                  width: thumbSize,
                  height: thumbSize,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(context.cardRadius),
                  ),
                  child: Center(
                    child: Text(
                      food.emoji,
                      style: TextStyle(fontSize: thumbSize * 0.52),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$portion tô (${portionGrams}g)',
                        style: TextStyle(
                          fontSize: context.fs(11),
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(food.confidence * 100).toInt()}% match',
                    style: TextStyle(
                      fontSize: context.fs(10),
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 20, color: AppColors.primary.withValues(alpha: 0.08)),
          // Calo + portion buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.hPad),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${actualCalories.toInt()}',
                      style: TextStyle(
                        fontSize: context.fs(26),
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'kcal / tổng cộng',
                      style: TextStyle(
                        fontSize: context.fs(11),
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (portion > 1) setState(() => portion--);
                      },
                      child: PortionBtn(
                        icon: Icons.remove,
                        size: portionBtnSize,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$portion tô',
                      style: TextStyle(
                        fontSize: context.fs(12),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => portion++),
                      child: PortionBtn(icon: Icons.add, size: portionBtnSize),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          // Macro grid
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.hPad),
            child: Row(
              children: [
                Expanded(
                  child: MacroCard(
                    label: 'Protein',
                    value: '${actualProtein.toInt()}g',
                    color: AppColors.protein,
                    progress: (actualProtein / 70).clamp(0.0, 1.0),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: MacroCard(
                    label: 'Carb',
                    value: '${actualCarb.toInt()}g',
                    color: AppColors.carb,
                    progress: (actualCarb / 220).clamp(0.0, 1.0),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: MacroCard(
                    label: 'Fat',
                    value: '${actualFat.toInt()}g',
                    color: AppColors.fat,
                    progress: (actualFat / 60).clamp(0.0, 1.0),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          // Action buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.hPad),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: btnH,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            context.cardRadius,
                          ),
                        ),
                        elevation: 0,
                      ),
                      onPressed:
                          _isSaving ? null : () => _saveToDiary(actualCalories),
                      child: _isSaving
                          ? SizedBox(
                              width: btnH * 0.6,
                              height: btnH * 0.6,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Lưu vào nhật ký',
                              style: TextStyle(
                                fontSize: context.fs(13),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: widget.onRetry,
                  child: Container(
                    width: btnH,
                    height: btnH,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(context.cardRadius),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Icon(
                      Icons.refresh,
                      size: context.sw * 0.03,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class PortionBtn extends StatelessWidget {
  final IconData icon;
  final double size;

  const PortionBtn({super.key, required this.icon, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: size * 0.5, color: AppColors.primary),
    );
  }
}

class CamBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const CamBtn({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sz = context.iconSize(32, tablet: 36, desktop: 40).toDouble();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: sz,
        height: sz,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.4),
        ),
        child: Icon(icon, color: Colors.white, size: sz * 0.46),
      ),
    );
  }
}
