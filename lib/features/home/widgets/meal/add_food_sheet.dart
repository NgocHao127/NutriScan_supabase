import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutriscan/models/meal_item_model.dart';
import '../../../../models/food_model.dart';
import '../../../../providers/api_provider.dart';
import '../../../theme/app_theme.dart';
import 'sheet_input.dart';

// ==================== Add Food Sheet ====================

class AddFoodSheet extends ConsumerStatefulWidget {
  const AddFoodSheet({super.key});

  @override
  ConsumerState<AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends ConsumerState<AddFoodSheet> {
  final _nameCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _carbsCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _portionCtrl = TextEditingController(text: '1 phần');

  List<FoodModel> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    setState(() {});
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() => _isSearching = true);
      try {
        final foodService = ref.read(foodServiceProvider);
        final results = await foodService.searchFoods(query);
        setState(() => _searchResults = results);
      } catch (e) {
        debugPrint('=== SEARCH ERROR: $e ===');
      } finally {
        setState(() => _isSearching = false);
      }
    });
  }

  void _selectFood(FoodModel food) {
    if (food.source == 'AI') {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Dữ liệu ước tính'),
          content: const Text(
            'Món này được AI ước tính, có thể không chính xác. Xác nhận sẽ gửi lên để kiểm duyệt.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Huỷ'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                _fillFood(food);
                try {
                  final foodService = ref.read(foodServiceProvider);
                  await foodService.confirmAiFood(food);
                } catch (e) {
                  debugPrint('=== CONFIRM AI ERROR: $e ===');
                }
              },
              child: const Text('Dùng thôi'),
            ),
          ],
        ),
      );
      return;
    }
    _fillFood(food);
  }

  // void _showAddCustomFood() {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (_) => CustomFoodSheet(
  //       initialName: _nameCtrl.text,
  //       onSaved: (food) {
  //         _fillFood(food);
  //       },
  //     ),
  //   );
  // }

  void _fillFood(FoodModel food) {
    _nameCtrl.text = food.name;
    _caloriesCtrl.text = food.calories.toString();
    _proteinCtrl.text = food.protein.toString();
    _carbsCtrl.text = food.carbs.toString();
    _fatCtrl.text = food.fat.toString();
    _portionCtrl.text = '${food.servingSize}${food.servingUnit}';
    setState(() => _searchResults = []);
  }

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
      MealItemModel(
        foodName: _nameCtrl.text.trim(),
        calories: double.tryParse(_caloriesCtrl.text) ?? 0,
        protein: double.tryParse(_proteinCtrl.text) ?? 0,
        carbs: double.tryParse(_carbsCtrl.text) ?? 0,
        fat: double.tryParse(_fatCtrl.text) ?? 0,
        portion: _portionCtrl.text.trim().isEmpty ? '1 phần' : _portionCtrl.text.trim(),
      ),
    );
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
          const Text(
            'Thêm món ăn',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SheetInput(
            label: 'Tìm món ăn',
            controller: _nameCtrl,
            hint: 'VD: Cơm trắng',
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 16),
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (_searchResults.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 180),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _searchResults.length,
                itemBuilder: (_, i) {
                  final food = _searchResults[i];
                  return ListTile(
                    dense: true,
                    title: Text(food.name, style: const TextStyle(fontSize: 13)),
                    subtitle: Text(
                      '${food.calories.toInt()} kcal · ${food.servingSize}${food.servingUnit}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: food.source == 'NIN'
                            ? AppColors.primaryLight
                            : food.source == 'AI'
                                ? Colors.orange.withValues(alpha: 0.15)
                                : AppColors.bgPage,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        food.source == 'AI'
                            ? 'AI ước tính'
                            : food.source ?? '',
                        style: TextStyle(
                          fontSize: 10,
                          color: food.source == 'AI'
                              ? Colors.orange
                              : food.source == 'NIN'
                                  ? AppColors.primary
                                  : AppColors.textHint,
                        ),
                      ),
                    ),
                    onTap: () => _selectFood(food),
                  );
                },
              ),
            ),
          // const Padding(
          //   padding: EdgeInsets.symmetric(vertical: 12),
          //   child: Row(
          //     children: [
          //       Expanded(child: Divider()),
          //       Padding(
          //         padding: EdgeInsets.symmetric(horizontal: 8),
          //         child: Text('hoặc tự nhập',
          //             style:
          //                 TextStyle(fontSize: 11, color: AppColors.textHint)),
          //       ),
          //       Expanded(child: Divider()),
          //     ],
          //   ),
          // ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: SheetInput(
                label: 'Calo (kcal) *',
                controller: _caloriesCtrl,
                hint: '250',
                isNumber: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SheetInput(
                label: 'Khẩu phần',
                controller: _portionCtrl,
                hint: '1 tô',
              ),
            ),
          ]),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SheetInput(
                  label: 'Protein (g)',
                  controller: _proteinCtrl,
                  hint: '0',
                  isNumber: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SheetInput(
                  label: 'Carb (g)',
                  controller: _carbsCtrl,
                  hint: '0',
                  isNumber: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SheetInput(
                  label: 'Fat (g)',
                  controller: _fatCtrl,
                  hint: '0',
                  isNumber: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Xác nhận',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
              // const SizedBox(width: 10),
              // TextButton(
              //   onPressed: _showAddCustomFood,
              //   child: const Text('Lưu vào kho',
              //       style: TextStyle(fontSize: 12, color: AppColors.primary)),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== Custom Food Sheet ====================

class CustomFoodSheet extends ConsumerStatefulWidget {
  final String initialName;
  final Function(FoodModel) onSaved;

  const CustomFoodSheet({
    super.key,
    required this.initialName,
    required this.onSaved,
  });

  @override
  ConsumerState<CustomFoodSheet> createState() => _CustomFoodSheetState();
}

class _CustomFoodSheetState extends ConsumerState<CustomFoodSheet> {
  late final TextEditingController _nameCtrl;
  final _caloriesCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _carbsCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _servingSizeCtrl = TextEditingController(text: '100');
  final _servingUnitCtrl = TextEditingController(text: 'g');

  String? _imageUrl;
  bool _isUploadingImage = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _caloriesCtrl.dispose();
    _proteinCtrl.dispose();
    _carbsCtrl.dispose();
    _fatCtrl.dispose();
    _servingSizeCtrl.dispose();
    _servingUnitCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (picked == null) return;

    setState(() => _isUploadingImage = true);
    try {
      final bytes = await picked.readAsBytes();
      final fileName = picked.name;

      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: fileName),
      });

      final foodService = ref.read(foodServiceProvider);
      final url = await foodService.uploadFoodImage(formData);
      setState(() => _imageUrl = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi upload ảnh: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty || _caloriesCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên và calo')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final foodService = ref.read(foodServiceProvider);
      await foodService.addCustomFood(
        name: _nameCtrl.text.trim(),
        calories: double.tryParse(_caloriesCtrl.text) ?? 0,
        protein: double.tryParse(_proteinCtrl.text) ?? 0,
        carbs: double.tryParse(_carbsCtrl.text) ?? 0,
        fat: double.tryParse(_fatCtrl.text) ?? 0,
        servingSize: double.tryParse(_servingSizeCtrl.text) ?? 100,
        servingUnit: _servingUnitCtrl.text.trim().isEmpty ? 'g' : _servingUnitCtrl.text.trim(),
        imageUrl: _imageUrl,
      );

      final food = FoodModel(
        name: _nameCtrl.text.trim(),
        calories: double.tryParse(_caloriesCtrl.text) ?? 0,
        protein: double.tryParse(_proteinCtrl.text) ?? 0,
        carbs: double.tryParse(_carbsCtrl.text) ?? 0,
        fat: double.tryParse(_fatCtrl.text) ?? 0,
        servingSize: double.tryParse(_servingSizeCtrl.text) ?? 100,
        servingUnit: _servingUnitCtrl.text.trim().isEmpty ? 'g' : _servingUnitCtrl.text.trim(),
        source: 'USER',
        status: 'PENDING',
        imageUrl: _imageUrl,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved(food);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã gửi món ăn, chờ kiểm duyệt!'),
            backgroundColor: AppColors.primaryMid,
          ),
        );
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
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPad),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
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
            const Text(
              'Thêm món vào kho',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Món sẽ được kiểm duyệt trước khi hiển thị công khai.',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _isUploadingImage ? null : _pickAndUploadImage,
              child: Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                child: _isUploadingImage
                    ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                    : _imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              _imageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 32,
                                color: AppColors.primary.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Thêm ảnh món ăn (tuỳ chọn)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 14),
            SheetInput(
              label: 'Tên món *',
              controller: _nameCtrl,
              hint: 'VD: Bún bò Huế',
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: SheetInput(
                  label: 'Calo (kcal) *',
                  controller: _caloriesCtrl,
                  hint: '250',
                  isNumber: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SheetInput(
                  label: 'Khẩu phần',
                  controller: _servingSizeCtrl,
                  hint: '100',
                  isNumber: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SheetInput(
                  label: 'Đơn vị',
                  controller: _servingUnitCtrl,
                  hint: 'g',
                ),
              ),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: SheetInput(
                  label: 'Protein (g)',
                  controller: _proteinCtrl,
                  hint: '0',
                  isNumber: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SheetInput(
                  label: 'Carb (g)',
                  controller: _carbsCtrl,
                  hint: '0',
                  isNumber: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SheetInput(
                  label: 'Fat (g)',
                  controller: _fatCtrl,
                  hint: '0',
                  isNumber: true,
                ),
              ),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Gửi kiểm duyệt',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}