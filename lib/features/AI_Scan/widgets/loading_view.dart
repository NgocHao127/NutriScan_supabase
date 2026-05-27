import 'package:flutter/material.dart';
import '../../widgets/responsive_layout.dart';
import '../../theme/app_responsive.dart';
import '../../theme/app_theme.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final spinSize = context.iconSize(56, tablet: 64, desktop: 72).toDouble();

    return Stack(
      fit: StackFit.expand, // đảm bảo Stack lấp đầy màn hình
      children: [
        Container(color: const Color(0xFF111111)),
        Container(color: Colors.black54),
        // Spinner + text — dùng Align thay vì Center+Column để không bị mất
        Align(
          alignment: const Alignment(0, -0.2), // hơi lên trên giữa
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: spinSize,
                height: spinSize,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primaryAccent,
                ),
              ),

              const SizedBox(height: 14),
              Text(
                'AI đang phân tích...',
                style: TextStyle(
                  fontSize: context.fs(14),
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 4),
              Text(
                'Nhận diện món ăn từ ảnh',
                style: TextStyle(
                  fontSize: context.fs(12),
                  color: Colors.white38,
                ),
              ),
            ],
          ),
        ),
        // Dùng ResponsiveLayout để định hướng vị trí hiển thị bảng trắng
        Positioned.fill(
          child: ResponsiveLayout(
            mobile: const Align(
              alignment: Alignment.bottomCenter,
              child: LoadingSheet(),
            ),
            tablet: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: context.sw * 0.6,
                child: const LoadingSheet(),
              ),
            ),
            desktop: const DesktopLoadingSheet(),
          ),
        ),
      ],
    );
  }
}

// ── Desktop: Bảng loading dạng thẻ nổi kéo ra từ cạnh phải ──
class DesktopLoadingSheet extends StatelessWidget {
  const DesktopLoadingSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: context.sw * 0.4,
        height: double.infinity,
        margin: const EdgeInsets.only(top: 24, bottom: 24),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 30,
              offset: const Offset(-8, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(32),
          ),
          child: SafeArea(
            top: false,
            bottom: false,
            child: SingleChildScrollView(
              child: const LoadingSheet(isDesktop: true),
            ),
          ),
        ),
      ),
    );
  }
}

class LoadingSheet extends StatelessWidget {
  final bool isDesktop;

  const LoadingSheet({super.key, this.isDesktop = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Tránh bị chèn màu nền nếu đang ở Desktop
        color: isDesktop ? Colors.transparent : AppColors.bgCard,
        borderRadius: isDesktop
            ? BorderRadius.zero
            : BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.all(context.hPad),
      child: Column(
        children: [
          // Chỉ hiện thanh vuốt ngang nhỏ xíu trên Mobile/Tablet
          if (!isDesktop)
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
          if (!isDesktop) const SizedBox(height: 14),
          // Các khối Skeleton mô phỏng nội dung
          SkeletonBox(height: 52),

          const SizedBox(height: 10),
          SkeletonBox(height: 36),

          const SizedBox(height: 10),
          Row(
            children: const [
              Expanded(child: SkeletonBox(height: 60)),

              SizedBox(width: 6),
              Expanded(child: SkeletonBox(height: 60)),

              SizedBox(width: 6),
              Expanded(child: SkeletonBox(height: 60)),
            ],
          ),
        ],
      ),
    );
  }
}

class SkeletonBox extends StatelessWidget {
  final double height;

  const SkeletonBox({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
