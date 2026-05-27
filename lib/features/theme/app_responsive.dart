import 'package:flutter/material.dart';

// Truy cập nhanh từ bất kỳ đâu qua context
extension Responsive on BuildContext {
  double get sw => MediaQuery.of(this).size.width;
  double get sh => MediaQuery.of(this).size.height;

  bool get isMobile => sw < 600;
  bool get isTablet => sw >= 600 && sw < 1100;
  bool get isDesktop => sw >= 1100;

  // Padding tự động giãn theo màn hình
  double get hPad {
    if (isMobile) return 20;
    if (isTablet) return 40;
    return 60;
  }

  // Độ bo góc (Radius) chuẩn cho các Card
  double get cardRadius {
    if (isMobile) return 12;
    if (isTablet) return 16;
    return 20;
  }

  // Font scale — clamp chặt hơn để không quá to trên desktop
  double fs(double base) {
    if (isDesktop) return base * 1.2;
    if (isTablet) return base * 1.2;
    final scale = (sw / 309).clamp(0.92, 1.2);
    return base * 1.15 * scale;
  }

  double iconSize(double mobile, {double? tablet, double? desktop}) {
    if (isDesktop) return desktop ?? tablet ?? mobile * 1.2;
    if (isTablet) return tablet ?? mobile * 1.1;
    return mobile;
  }

  // Chiều rộng tối đa cho nội dung (Tránh việc text bị dài dằng dặc trên màn hình lớn)
  double get maxContentWidth => 1200.0;

  double get caloRingSize {
    if (isMobile) return 64;
    if (isTablet) return 72;
    return 80;
  }
}

// Widget helper: padding ngang tự động
class HPad extends StatelessWidget {
  final Widget child;
  const HPad({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.hPad),
      child: child,
    );
  }
}
