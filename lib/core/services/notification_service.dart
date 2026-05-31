import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // ── Khởi tạo ────────────────────────────────────────────
  Future<void> init() async {
    if (_initialized) return;

    // Bỏ qua khởi tạo trên Windows, Web hoặc Linux
    if (kIsWeb || Platform.isWindows || Platform.isLinux) {
      debugPrint('⚠️ NotificationService bị vô hiệu hóa trên nền tảng này.');
      return;
    }

    tz.initializeTimeZones();
    // Đặt timezone theo thiết bị — cần thêm flutter_timezone nếu muốn tự động
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    _initialized = true;
  }

  Future<void> cancelWeeklySummary() async {
    // Chặn gọi API Hủy trên nền tảng không hỗ trợ
    if (kIsWeb || Platform.isWindows || Platform.isLinux) return;

    try {
      if (!_initialized) await init();
      await _plugin.cancel(200);
    } catch (e) {
      print('=== cancelWeeklySummary error: $e ===');
    }
  }

  Future<void> cancelMealReminders() async {
    // Chặn gọi API Hủy trên nền tảng không hỗ trợ
    if (kIsWeb || Platform.isWindows || Platform.isLinux) return;

    try {
      if (!_initialized) await init();
      for (int id in [100, 101, 102, 103]) {
        await _plugin.cancel(id);
      }
    } catch (e) {
      print('=== cancelMealReminders error: $e ===');
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    // TODO: điều hướng khi tap notification
    // Ví dụ: navigatorKey.currentState?.pushNamed('/weekly-summary')
  }

  // ── Xin quyền ───────────────────────────────────────────
  Future<bool> requestPermission() async {
    // Bỏ qua xin quyền trên các nền tảng không hỗ trợ
    if (kIsWeb || Platform.isWindows || Platform.isLinux) return true;

    // Android 13+
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();

    // iOS
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);

    return granted ?? true;
  }

  // ── Notification details helper ──────────────────────────
  NotificationDetails _details({
    String channelId = 'nutriscan_general',
    String channelName = 'NutriScan',
    Importance importance = Importance.high,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: importance,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }

  // ── 1. Lập lịch nhắc bữa ăn hàng ngày ──────────────────
  Future<void> scheduleDailyMealReminders({
    required TimeOfDay breakfast,
    required TimeOfDay lunch,
    required TimeOfDay dinner,
    required TimeOfDay snack,
  }) async {
    // Lưu vào SharedPreferences
    await _saveMealTimes(
      breakfast: breakfast,
      lunch: lunch,
      dinner: dinner,
      snack: snack,
    );

    // Chặn gọi API hẹn giờ trên nền tảng không hỗ trợ
    if (kIsWeb || Platform.isWindows || Platform.isLinux) {
      debugPrint(
          '⚠️ Hẹn giờ nhắc bữa ăn (zonedSchedule) không hỗ trợ trên Desktop/Web.');
      return;
    }

    if (!_initialized) await init();
    // Hủy các lịch cũ trước
    await cancelMealReminders();

    final meals = [
      (id: 100, time: breakfast, name: 'Bữa sáng'),
      (id: 101, time: lunch, name: 'Bữa trưa'),
      (id: 102, time: dinner, name: 'Bữa tối'),
      (id: 103, time: snack, name: 'Ăn vặt'),
    ];

    for (final meal in meals) {
      await _plugin.zonedSchedule(
        meal.id,
        '🍽️ Đến giờ ${meal.name} rồi!',
        'Đừng quên ghi lại bữa ăn để theo dõi dinh dưỡng nhé.',
        _nextInstanceOfTime(meal.time),
        _details(
          channelId: 'meal_reminder',
          channelName: 'Nhắc ghi bữa ăn',
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // lặp hàng ngày
      );
    }
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  // ── 2. Lập lịch tổng kết tuần AI (Chủ nhật 20h) ─────────
  Future<void> scheduleWeeklySummaryBait() async {
    // Chặn gọi API hẹn giờ trên nền tảng không hỗ trợ
    if (kIsWeb || Platform.isWindows || Platform.isLinux) {
      debugPrint(
          '⚠️ Lên lịch tổng kết tuần AI (zonedSchedule) không hỗ trợ trên Desktop/Web.');
      return;
    }

    if (!_initialized) await init();
    await _plugin.cancel(200);

    // Tìm Chủ nhật tiếp theo lúc 20h
    final now = tz.TZDateTime.now(tz.local);
    var sunday = now;
    while (sunday.weekday != DateTime.sunday) {
      sunday = sunday.add(const Duration(days: 1));
    }
    var scheduled = tz.TZDateTime(
      tz.local,
      sunday.year,
      sunday.month,
      sunday.day,
      20,
      0,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 7));
    }

    await _plugin.zonedSchedule(
      200,
      '📊 Báo cáo tuần của bạn đã sẵn sàng!',
      'Mở app để xem AI nhận xét dinh dưỡng tuần này nhé!',
      scheduled,
      _details(
        channelId: 'weekly_summary',
        channelName: 'Tổng kết tuần AI',
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents:
          DateTimeComponents.dayOfWeekAndTime, // lặp hàng tuần
    );
  }

  // ── 3. Cảnh báo vượt calo ────────────────────────────────
  Future<void> showImmediateCalorieWarning({
    required int consumed,
    required int goal,
  }) async {
    // Chặn gọi API hiển thị trên nền tảng không hỗ trợ
    if (kIsWeb || Platform.isWindows || Platform.isLinux) return;

    if (!_initialized) await init();
    // Delay 3 giây để user kịp thoát app
    await Future.delayed(const Duration(seconds: 3));

    await _plugin.show(
      300,
      '⚠️ Bạn đã vượt giới hạn calo!',
      'Đã nạp $consumed kcal / mục tiêu $goal kcal hôm nay.',
      _details(
        channelId: 'calorie_warning',
        channelName: 'Cảnh báo calo',
        importance: Importance.max,
      ),
    );
  }

  // ── SharedPreferences helpers ────────────────────────────
  Future<void> _saveMealTimes({
    required TimeOfDay breakfast,
    required TimeOfDay lunch,
    required TimeOfDay dinner,
    required TimeOfDay snack,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notif_breakfast_h', breakfast.hour);
    await prefs.setInt('notif_breakfast_m', breakfast.minute);
    await prefs.setInt('notif_lunch_h', lunch.hour);
    await prefs.setInt('notif_lunch_m', lunch.minute);
    await prefs.setInt('notif_dinner_h', dinner.hour);
    await prefs.setInt('notif_dinner_m', dinner.minute);
    await prefs.setInt('notif_snack_h', snack.hour);
    await prefs.setInt('notif_snack_m', snack.minute);
  }

  Future<Map<String, TimeOfDay>> loadSavedMealTimes() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'breakfast': TimeOfDay(
        hour: prefs.getInt('notif_breakfast_h') ?? 7,
        minute: prefs.getInt('notif_breakfast_m') ?? 0,
      ),
      'lunch': TimeOfDay(
        hour: prefs.getInt('notif_lunch_h') ?? 12,
        minute: prefs.getInt('notif_lunch_m') ?? 0,
      ),
      'dinner': TimeOfDay(
        hour: prefs.getInt('notif_dinner_h') ?? 18,
        minute: prefs.getInt('notif_dinner_m') ?? 0,
      ),
      'snack': TimeOfDay(
        hour: prefs.getInt('notif_snack_h') ?? 15,
        minute: prefs.getInt('notif_snack_m') ?? 0,
      ),
    };
  }
}
