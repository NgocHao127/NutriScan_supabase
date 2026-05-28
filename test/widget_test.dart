import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutriscan/app.dart'; // import đúng file chứa NutriScanApp

void main() {
  testWidgets('App khởi động thành công', (WidgetTester tester) async {
    await tester.pumpWidget(const NutriScanApp());
    // Đợi một chút để Firebase, Isar khởi tạo (có thể cần mock nếu không có môi trường thật)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}