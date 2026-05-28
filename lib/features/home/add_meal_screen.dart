import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../theme/app_theme.dart';
import '../theme/app_responsive.dart';
import '../../models/meal_entry_model.dart';
import '../../models/meal_item_model.dart';
import '../../providers/api_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/today_record_provider.dart';

class AddMealScreen extends ConsumerStatefulWidget {
  final String? initialMealType;

  const AddMealScreen({super.key, this.initialMealType});

  @override
  ConsumerState<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends ConsumerState<AddMealScreen> {
  final _mealNameCtrl = TextEditingController();
  String _selectedMealType = 'Bữa sáng';
  bool _isSaving = false;

  // Danh sách món ăn thêm vào bữa
  final List<_FoodEntry> _foods = [];

  final _mealTypes = ['Bữa sáng', 'Bữa trưa', 'Bữa tối', 'Ăn vặt'];

  // Tự động detect meal type theo giờ
  @override
  void initState() {
    super.initState();
    if (widget.initialMealType != null) {
      _selectedMealType = widget.initialMealType!;
    } else {
      final hour = DateTime.now().hour;
      if (hour >= 5 && hour <= 10) {
        _selectedMealType = 'Bữa sáng';
      } else if (hour > 10 && hour <= 14) {
        _selectedMealType = 'Bữa trưa';
      } else if (hour >= 17 && hour < 22) {
        _selectedMealType = 'Bữa tối';
      } else {
        _selectedMealType = 'Ăn vặt';
      }
    }
  }

  @override
  void dispose() {
    _mealNameCtrl.dispose();
    super.dispose();
  }

  double get _totalCalories => _foods.fold(0, (sum, f) => sum + f.calories);
  double get _totalProtein => _foods.fold(0, (sum, f) => sum + f.protein);
  double get _totalCarbs => _foods.fold(0, (sum, f) => sum + f.carbs);
  double get _totalFat => _foods.fold(0, (sum, f) => sum + f.fat);

  void _addFood() async {
    final result = await showModalBottomSheet<_FoodEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddFoodSheet(),
    );
    if (result != null) {
      setState(() => _foods.add(result));
    }
  }

  void _removeFood(int index) {
    setState(() => _foods.removeAt(index));
  }

  Future<void> _save() async {
    if (_foods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng thêm ít nhất 1 món ăn'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final mealService = ref.read(mealServiceProvider);
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception('Chưa đăng nhập');

      final mealItems = _foods
          .map((f) => MealItemModel(
                id: 0,
                mealId: '',
                foodName: f.name,
                calories: f.calories,
                protein: f.protein,
                carbs: f.carbs,
                fat: f.fat,
                portion: f.portion,
              ))
          .toList();

      final meal = MealEntryModel(
        id: const Uuid().v4(),
        userId: user.id,
        name: _mealNameCtrl.text.trim().isEmpty
            ? _selectedMealType
            : _mealNameCtrl.text.trim(),
        mealType: _selectedMealType,
        mealTime: DateTime.now(),
        calories: _totalCalories,
        protein: _totalProtein,
        carbs: _totalCarbs,
        fat: _totalFat,
        items: mealItems,
      );

      await mealService.logMeal(meal.toJson());
      ref.invalidate(todayRecordProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu bữa ăn!'),
            backgroundColor: AppColors.primaryMid,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(brightness: Brightness.light),
      child: Scaffold(
        backgroundColor: AppColors.bgPage,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    EdgeInsets.fromLTRB(context.hPad, 20, context.hPad, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMealInfo(context),
                    const SizedBox(height: 20),
                    _buildNutritionSummary(context),
                    const SizedBox(height: 20),
                    _buildFoodList(context),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: _buildSaveButton(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(20, topPad + 14, 20, 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.18),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Thêm bữa ăn',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.fs(17),
                    fontWeight: FontWeight.w500,
                  )),
              Text('Ghi lại thủ công',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: context.fs(11),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tên bữa ăn
        Text('Tên bữa ăn (tuỳ chọn)',
            style: TextStyle(
              fontSize: context.fs(11),
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            )),
        const SizedBox(height: 6),
        TextField(
          controller: _mealNameCtrl,
          decoration: InputDecoration(
            hintText: 'VD: Cơm trưa văn phòng',
            hintStyle:
                TextStyle(color: AppColors.textHint, fontSize: context.fs(13)),
            filled: true,
            fillColor: AppColors.bgCard,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.inputBorder, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.primaryMid, width: 1.5),
            ),
          ),
          style:
              TextStyle(fontSize: context.fs(13), color: AppColors.textPrimary),
        ),

        const SizedBox(height: 16),

        // Loại bữa
        Text('Loại bữa',
            style: TextStyle(
              fontSize: context.fs(11),
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            )),
        const SizedBox(height: 8),
        Row(
          children: _mealTypes.map((type) {
            final selected = _selectedMealType == type;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedMealType = type),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.bgCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          selected ? AppColors.primary : AppColors.inputBorder,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    type,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: context.fs(10),
                      fontWeight: FontWeight.w500,
                      color: selected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNutritionSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(context.cardRadius),
      ),
      child: Row(
        children: [
          _NutritionChip(
            label: 'Calo',
            value: '${_totalCalories.toInt()}',
            unit: 'kcal',
          ),
          _NutritionChip(
            label: 'Protein',
            value: '${_totalProtein.toInt()}',
            unit: 'g',
          ),
          _NutritionChip(
            label: 'Carb',
            value: '${_totalCarbs.toInt()}',
            unit: 'g',
          ),
          _NutritionChip(
            label: 'Fat',
            value: '${_totalFat.toInt()}',
            unit: 'g',
          ),
        ],
      ),
    );
  }

  Widget _buildFoodList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Món ăn (${_foods.length})',
                style: TextStyle(
                  fontSize: context.fs(13),
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                )),
            GestureDetector(
              onTap: _addFood,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add,
                        size: context.fs(12), color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('Thêm món',
                        style: TextStyle(
                          fontSize: context.fs(11),
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_foods.isEmpty)
          GestureDetector(
            onTap: _addFood,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(context.cardRadius),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.add_circle_outline,
                      size: 40,
                      color: AppColors.primary.withValues(alpha: 0.5)),
                  const SizedBox(height: 8),
                  Text('Nhấn để thêm món ăn',
                      style: TextStyle(
                        fontSize: context.fs(13),
                        color: AppColors.textSecondary,
                      )),
                ],
              ),
            ),
          )
        else
          ...List.generate(_foods.length, (i) {
            final food = _foods[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                        child: Text('🍽️', style: TextStyle(fontSize: 18))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(food.name,
                            style: TextStyle(
                              fontSize: context.fs(13),
                              fontWeight: FontWeight.w500,
                            )),
                        Text(
                          '${food.calories.toInt()} kcal · ${food.portion}',
                          style: TextStyle(
                            fontSize: context.fs(11),
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'P${food.protein.toInt()} C${food.carbs.toInt()} F${food.fat.toInt()}',
                    style: TextStyle(
                      fontSize: context.fs(10),
                      color: AppColors.textHint,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _removeFood(i),
                    child:
                        Icon(Icons.close, size: 18, color: AppColors.textHint),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.hPad),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Text('Lưu bữa ăn',
                  style: TextStyle(
                    fontSize: context.fs(14),
                    fontWeight: FontWeight.w500,
                  )),
        ),
      ),
    );
  }
}

// ── Bottom sheet thêm món ────────────────────────────────

class _AddFoodSheet extends StatefulWidget {
  const _AddFoodSheet();

  @override
  State<_AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends State<_AddFoodSheet> {
  final _nameCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _carbsCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _portionCtrl = TextEditingController(text: '1 phần');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _caloriesCtrl.dispose();
    _proteinCtrl.dispose();
    _carbsCtrl.dispose();
    _fatCtrl.dispose();
    _portionCtrl.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_nameCtrl.text.trim().isEmpty || _caloriesCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên và calo')),
      );
      return;
    }
    Navigator.pop(
        context,
        _FoodEntry(
          name: _nameCtrl.text.trim(),
          calories: double.tryParse(_caloriesCtrl.text) ?? 0,
          protein: double.tryParse(_proteinCtrl.text) ?? 0,
          carbs: double.tryParse(_carbsCtrl.text) ?? 0,
          fat: double.tryParse(_fatCtrl.text) ?? 0,
          portion: _portionCtrl.text.trim().isEmpty
              ? '1 phần'
              : _portionCtrl.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPad),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 16),
          const Text('Thêm món ăn',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              )),
          const SizedBox(height: 16),
          _SheetInput(
              label: 'Tên món *', ctrl: _nameCtrl, hint: 'VD: Cơm trắng'),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: _SheetInput(
                    label: 'Calo (kcal) *',
                    ctrl: _caloriesCtrl,
                    hint: '250',
                    isNumber: true)),
            const SizedBox(width: 10),
            Expanded(
                child: _SheetInput(
                    label: 'Khẩu phần', ctrl: _portionCtrl, hint: '1 tô')),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: _SheetInput(
                    label: 'Protein (g)',
                    ctrl: _proteinCtrl,
                    hint: '0',
                    isNumber: true)),
            const SizedBox(width: 10),
            Expanded(
                child: _SheetInput(
                    label: 'Carb (g)',
                    ctrl: _carbsCtrl,
                    hint: '0',
                    isNumber: true)),
            const SizedBox(width: 10),
            Expanded(
                child: _SheetInput(
                    label: 'Fat (g)',
                    ctrl: _fatCtrl,
                    hint: '0',
                    isNumber: true)),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: _confirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text('Xác nhận',
                  style: TextStyle(fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetInput extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String hint;
  final bool isNumber;

  const _SheetInput({
    required this.label,
    required this.ctrl,
    required this.hint,
    this.isNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            )),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          keyboardType: isNumber
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textHint),
            filled: true,
            fillColor: AppColors.bgPage,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.inputBorder, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.primaryMid, width: 1.5),
            ),
          ),
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

// ── Helper widgets ────────────────────────────────────────

class _NutritionChip extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _NutritionChip({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              )),
          Text('$unit\n$label',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.fs(9),
                color: AppColors.onPrimary,
                height: 1.3,
              )),
        ],
      ),
    );
  }
}

// ── Data class ───────────────────────────────────────────

class _FoodEntry {
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String portion;

  const _FoodEntry({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.portion,
  });
}
