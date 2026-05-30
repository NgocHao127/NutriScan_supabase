import '../../../models/meal_item_model.dart';

enum ScanStatus { scanning, loading, result }

class ScanState {
  final ScanStatus status;
  final List<MealItemModel> detectedFoods;
  final String? errorMessage;
  final int portion;
  final bool isSaving;

  const ScanState({
    this.status = ScanStatus.scanning,
    this.detectedFoods = const [],
    this.errorMessage,
    this.portion = 1,
    this.isSaving = false,
  });

  bool get isScanning => status == ScanStatus.scanning;
  bool get isLoading  => status == ScanStatus.loading;
  bool get isResult   => status == ScanStatus.result;

  ScanState copyWith({
    ScanStatus? status,
    List<MealItemModel>? detectedFoods,
    String? errorMessage,
    int? portion,
    bool? isSaving,
  }) {
    return ScanState(
      status:        status        ?? this.status,
      detectedFoods: detectedFoods ?? this.detectedFoods,
      errorMessage:  errorMessage,
      portion:       portion       ?? this.portion,
      isSaving:      isSaving      ?? this.isSaving,
    );
  }
}