import 'package:flutter/material.dart';
import '../../theme/app_responsive.dart';
import '../../theme/app_theme.dart';

class ScanningView extends StatelessWidget {
  final VoidCallback onCapture;
  const ScanningView({super.key, required this.onCapture});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: const Color(0xFF111111)),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.hPad,
              vertical: 10,
            ),
            child: Row(
              children: [
                CamBtn(icon: Icons.arrow_back, onTap: () {}),
                const Spacer(),
                Text(
                  'AI Scan',
                  style: TextStyle(
                    fontSize: context.fs(15),
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                CamBtn(icon: Icons.flash_off, onTap: () {}),
              ],
            ),
          ),
        ),
        // Scan frame + capture button — giữa màn hình
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScanFrame(),

              const SizedBox(height: 40),
              CaptureButton(onCapture: onCapture),
            ],
          ),
        ),
        Positioned(
          bottom: 32,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Thư viện',
                style: TextStyle(
                  fontSize: context.fs(12),
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              Text(
                'Nhập tay',
                style: TextStyle(
                  fontSize: context.fs(12),
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ScanFrame extends StatelessWidget {
  const ScanFrame({super.key});

  @override
  Widget build(BuildContext context) {
    // Cố định dp: không bao giờ to hơn 280 dù màn hình bao lớn
    final frameSize = context.isDesktop
        ? 280.0
        : context.isTablet
        ? 240.0
        : (context.sw * 0.56).clamp(180.0, 280.0);

    return SizedBox(
      width: frameSize,
      height: frameSize,
      child: Stack(
        children: [
          Positioned(top: 0, left: 0, child: Corner(top: true, left: true)),
          Positioned(top: 0, right: 0, child: Corner(top: true, left: false)),
          Positioned(bottom: 0, left: 0, child: Corner(top: false, left: true)),
          Positioned(
            bottom: 0,
            right: 0,
            child: Corner(top: false, left: false),
          ),
          Center(
            child: Text(
              'Đặt món ăn vào khung',
              style: TextStyle(
                fontSize: context.fs(12),
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Corner extends StatelessWidget {
  final bool top;
  final bool left;

  const Corner({super.key, required this.top, required this.left});

  @override
  Widget build(BuildContext context) {
    final size = context.iconSize(24, tablet: 26, desktop: 28).toDouble();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border(
          top: top
              ? BorderSide(color: AppColors.primaryAccent, width: 2.5)
              : BorderSide.none,
          bottom: !top
              ? BorderSide(color: AppColors.primaryAccent, width: 2.5)
              : BorderSide.none,
          left: left
              ? BorderSide(color: AppColors.primaryAccent, width: 2.5)
              : BorderSide.none,
          right: !left
              ? BorderSide(color: AppColors.primaryAccent, width: 2.5)
              : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: top && left ? const Radius.circular(4) : Radius.zero,
          topRight: top && !left ? const Radius.circular(4) : Radius.zero,
          bottomLeft: !top && left ? const Radius.circular(4) : Radius.zero,
          bottomRight: !top && !left ? const Radius.circular(4) : Radius.zero,
        ),
      ),
    );
  }
}

class CaptureButton extends StatelessWidget {
  final VoidCallback onCapture;
  const CaptureButton({super.key, required this.onCapture});

  @override
  Widget build(BuildContext context) {
    final size = context.iconSize(64, tablet: 70, desktop: 76).toDouble();

    return GestureDetector(
      onTap: onCapture,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primaryAccent, width: 2),
        ),
        child: Icon(Icons.search, color: Colors.white, size: size * 0.42),
      ),
    );
  }
}

class CamBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const CamBtn({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sz = context.iconSize(32, tablet: 36, desktop: 40).toDouble();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: sz,
        height: sz,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.4),
        ),
        child: Icon(icon, color: Colors.white, size: sz * 0.46),
      ),
    );
  }
}
