import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../providers/auth_provider.dart';
import '../../../theme/app_theme.dart';
import 'settings_components.dart';

class DataAndAccountSection extends ConsumerStatefulWidget {
  const DataAndAccountSection({super.key});
  @override
  ConsumerState<DataAndAccountSection> createState() =>
      _DataAndAccountSectionState();
}

class _DataAndAccountSectionState extends ConsumerState<DataAndAccountSection> {
  bool _isExporting = false;

  // Nghiệp vụ 1: Giới thiệu ứng dụng
  void _showAppInfo() {
    showAboutDialog(
      context: context,
      applicationName: 'NutriScan',
      applicationVersion: 'v1.0.0',
      applicationIcon: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.health_and_safety,
            color: AppColors.primary, size: 30),
      ),
      applicationLegalese: '© 2026 NutriScan Team.\nAll rights reserved.',
      children: [
        const SizedBox(height: 15),
        const Text(
          'Ứng dụng theo dõi dinh dưỡng và tính toán lượng Calo hàng ngày được hỗ trợ bởi AI.',
          style: TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  // Nghiệp vụ 2: Xuất dữ liệu ra Excel
  Future<void> _exportData() async {
    setState(() => _isExporting = true);

    try {
      // 1. Tạo file Excel mới
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      // 2. Tạo dòng Tiêu đề (Header)
      sheetObject.appendRow([
        TextCellValue("Ngày"),
        TextCellValue("Bữa ăn"),
        TextCellValue("Tên món"),
        TextCellValue("Calo (kcal)"),
        TextCellValue("Protein (g)"),
      ]);

      // TODO: Ở đây bạn sẽ gọi API lấy dữ liệu thật từ Supabase.
      // Dưới đây là dữ liệu giả (Mock Data) để bạn test form mẫu:
      sheetObject.appendRow([
        TextCellValue("29/05/2026"),
        TextCellValue("Bữa sáng"),
        TextCellValue("Phở bò"),
        IntCellValue(430),
        IntCellValue(17)
      ]);
      sheetObject.appendRow([
        TextCellValue("29/05/2026"),
        TextCellValue("Bữa trưa"),
        TextCellValue("Cơm tấm"),
        IntCellValue(600),
        IntCellValue(20)
      ]);

      // 3. Lưu file vào bộ nhớ tạm của điện thoại
      var fileBytes = excel.save();
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/NutriScan_Data.xlsx';
      final file = File(filePath);

      await file.writeAsBytes(fileBytes!);

      // 4. Mở menu chia sẻ (Share) của hệ điều hành
      if (mounted) {
        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          print('=== EXCEL FILE: $filePath ===');
          // Desktop — hiện đường dẫn file
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Expanded(child: Text('Đã lưu: $filePath')),
                  TextButton(
                    onPressed: () async {
                      // Mở file Explorer tới thư mục chứa file
                      await Process.run(
                        'explorer.exe',
                        ['/select,', filePath.replaceAll('/', '\\')],
                      );
                    },
                    child:
                        const Text('Mở thư mục', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              backgroundColor: AppColors.primaryMid,
              duration: const Duration(seconds: 5),
            ),
          );
        } else {
          // Mobile — dùng share
          final xFile = XFile(file.path);
          await SharePlus.instance.share(
            ShareParams(
              files: [xFile],
              text: 'Dữ liệu dinh dưỡng NutriScan của tôi',
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xuất dữ liệu: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ArrowRow(
          icon: Icons.download_outlined,
          iconbg: const Color(0xFFE6F1FB),
          iconcolor: const Color(0xFF185FA5),
          title: _isExporting ? 'Đang tạo file...' : 'Xuất dữ liệu',
          sub: 'Tải về file Excel',
          onTap: _isExporting
              ? null
              : _exportData, // Bấm vào để chạy hàm xuất Excel
        ),
        ArrowRow(
          icon: Icons.info_outline,
          iconbg: AppColors.primaryLight,
          iconcolor: AppColors.primary,
          title: 'Về ứng dụng',
          sub: 'NutriScan v1.0.0',
          onTap: _showAppInfo, // Bấm vào để mở thông tin App
        ),
        const SizedBox(height: 14),
        ArrowRow(
          icon: Icons.logout,
          iconbg: const Color(0xFFFCEBEB),
          iconcolor: AppColors.danger,
          title: 'Đăng xuất',
          titleColor: AppColors.danger,
          borderColor: AppColors.danger.withValues(alpha: 0.2),
          onTap: () async {
            await ref.read(authNotifierProvider.notifier).signOut();
          },
        ),
      ],
    );
  }
}
