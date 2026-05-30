import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutriscan/features/theme/app_theme.dart';

import 'widgets/scanning_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/result_view.dart';

import '../../providers/api_provider.dart';
import '../../models/meal_item_model.dart';

import 'scan_controller/scan_controller.dart';
import 'scan_controller/scan_state.dart';

class ScanScreen extends ConsumerWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scanControllerProvider);
    final controller = ref.read(scanControllerProvider.notifier);

    // Lắng nghe lỗi để hiện Snackbar
    ref.listen(scanControllerProvider, (_, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${next.errorMessage}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: switch (state.status) {
        ScanStatus.scanning => ScanningView(
            onCapture: controller.pickAndAnalyze,
          ),
        ScanStatus.loading => const LoadingView(),
        ScanStatus.result => ResultView(
            foods: state.detectedFoods,
            portion: state.portion,
            isSaving: state.isSaving,
            onRetry: controller.retry,
            onIncrement: controller.incrementPortion,
            onDecrement: controller.decrementPortion,
            onSave: (calories) async {
              final saved = await controller.saveToDiary(calories);
              if (saved && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã lưu vào nhật ký!'),
                    backgroundColor: AppColors.primaryMid,
                  ),
                );
                controller.retry();
              }
            },
          ),
      },
    );
  }
}
