import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_record_model.dart';
import 'api_provider.dart';
import 'isar_provider.dart';

final todayRecordProvider = FutureProvider<DailyRecordModel?>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final isar = ref.read(isarProvider);
  final now = DateTime.now();

  // Thử lấy cache Isar (có thể implement logic lấy bản ghi ngày)
  final cached = await ref.read(isarProvider).getDailyRecordByDate(now);

  try {
    final data = await api.getDailyRecord();
    final record = DailyRecordModel.fromJson(data);
    // Cache vào Isar (nếu cần)
    await isar.cacheDailyRecord(record);
    return record;
  } catch (e) {
    // Offline: lấy từ Isar
    return cached;
  }
});
