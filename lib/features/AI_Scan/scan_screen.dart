import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutriscan/features/theme/app_theme.dart';

import 'widgets/scanning_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/result_view.dart';

import '../../providers/api_provider.dart';
import '../../models/meal_item_model.dart';

enum ScanState { scanning, loading, result }

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  ScanState _state = ScanState.scanning;
  List<MealItemModel> _detectedFoods = [];
  XFile? _capturedImage;
  String? _errorMessage;

  final ImagePicker _picker = ImagePicker();

  // Mở camera hoặc thư viện (tuỳ chỉnh)
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (image != null) {
      _capturedImage = image;
      await _analyzeImage(image);
    }
  }

  Future<void> _analyzeImage(XFile image) async {
    setState(() {
      _state = ScanState.loading;
      _errorMessage = null;
    });

    try {
      final foodService = ref.read(foodServiceProvider);
      final result = await foodService.analyzeFood(image.path);
      // result là List<dynamic> từ server, mỗi item có thể là Map chứa thông tin món ăn
      final foods = result.map((item) {
        return MealItemModel(
          foodName: item['name'] ?? 'Món ăn',
          calories: (item['calories'] ?? 0).toDouble(),
          protein: (item['protein'] ?? 0).toDouble(),
          carbs: (item['carbs'] ?? 0).toDouble(),
          fat: (item['fat'] ?? 0).toDouble(),
          portion: item['portion'],
        );
      }).toList();

      if (foods.isEmpty) throw Exception('Không nhận diện được món ăn');

      setState(() {
        _detectedFoods = foods;
        _state = ScanState.result;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _state = ScanState.scanning; // quay lại màn hình chụp
      });

      // Hiển thị toast thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${_errorMessage ?? "Không thể phân tích ảnh"}'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _onRetry() => setState(() {
        _state = ScanState.scanning;
        _detectedFoods = [];
        _capturedImage = null;
        _errorMessage = null;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: switch (_state) {
        ScanState.scanning => ScanningView(onCapture: _pickImage),
        ScanState.loading => const LoadingView(),
        ScanState.result => ResultView(
            foods: _detectedFoods,
            onRetry: _onRetry,
          ),
      },
    );
  }
}
