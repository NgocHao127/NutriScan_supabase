import 'package:flutter/material.dart';
import '../theme/app_responsive.dart';
import '../theme/app_theme.dart';

// ── Input field chuẩn auth ─────────────────────────────────────────────────
class AuthInput extends StatefulWidget {
  final String label;
  final String? placeholder;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? errorText;
  final String? initialValue;

  const AuthInput({
    super.key,
    required this.label,
    required this.controller,
    this.placeholder,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.initialValue,
  });

  @override
  State<AuthInput> createState() => _AuthInputState();
}

class _AuthInputState extends State<AuthInput> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: context.fs(11),
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 5),
        TextField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscure,
          keyboardType: widget.keyboardType,
          style: TextStyle(
            fontSize: context.fs(13),
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: TextStyle(
              color: AppColors.textHint,
              fontSize: context.fs(13),
            ),
            filled: true,
            fillColor: AppColors.bgCard,
            errorText: widget.errorText,
            errorStyle: TextStyle(fontSize: context.fs(11)),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                      color: const Color(0xFF888888),
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.inputBorder,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF4C9A15),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.danger, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Nút chính ──────────────────────────────────────────────────────────────
class AuthButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4C9A15),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: context.fs(14),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

// ── Nút Google ─────────────────────────────────────────────────────────────
class GoogleButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const GoogleButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 13),
          side: const BorderSide(color: Color(0xFFDDDDDD), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        icon: _googleIcon(),
        label: Text(
          label,
          style: TextStyle(fontSize: context.fs(13), color: Colors.black),
        ),
      ),
    );
  }

  Widget _googleIcon() {
    return const SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(painter: _GoogleIconPainter()),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  const _GoogleIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Bán kính của vòng cung (nhỏ hơn width/2 một chút để nét vẽ không bị cắt)
    final radius = size.width * 0.36;
    // Độ dày của nét vẽ
    final strokeWidth = size.width * 0.22;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt; // Cắt phẳng ở hai đầu nét

    final rect = Rect.fromCircle(center: center, radius: radius);
    const double pi = 3.14159265359;

    // Vẽ các phần của chữ G bằng các đường cong (arc)
    // Lưu ý quy tắc góc trong Flutter: 0 là góc 3h (phải), pi/2 là 6h (dưới), pi là 9h (trái), -pi/2 là 12h (trên).

    // 1. Màu xanh dương (Right bottom) - từ góc 3h kéo xuống ~4h30
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, 0, 0.25 * pi, false, paint);

    // 2. Màu xanh lá (Bottom) - từ ~4h30 kéo sang ~8h
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.25 * pi, 0.55 * pi, false, paint);

    // 3. Màu vàng (Left) - từ ~8h kéo lên ~10h30
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 0.8 * pi, 0.4 * pi, false, paint);

    // 4. Màu đỏ (Top) - từ ~10h30 kéo sang ~2h
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -0.8 * pi, 0.6 * pi, false, paint);

    // 5. Thanh ngang chữ G màu xanh dương (Crossbar)
    paint.style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTRB(
        size.width * 0.45, // Bắt đầu từ gần giữa tâm
        size.height * 0.5 - strokeWidth / 2, // Mép trên
        size.width * 0.97, // Kéo dài và bo sát lề phải
        size.height * 0.5 + strokeWidth / 2, // Mép dưới
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Divider "hoặc" ─────────────────────────────────────────────────────────
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE0E0E0), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'hoặc tiếp tục với',
            style: TextStyle(
              fontSize: context.fs(11),
              color: const Color(0xFF999999),
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE0E0E0), thickness: 1)),
      ],
    );
  }
}

// ── Header xanh lá ─────────────────────────────────────────────────────────
class AuthHeader extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final Widget? leadingAction;

  const AuthHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.leadingAction,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 24),
      child: leadingAction != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (leadingAction != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: leadingAction!,
                  ),

                // Logo và tiêu đề căn giữa
                Center(
                  child: Column(
                    children: [
                      icon,

                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: context.fs(19),
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: context.fs(12),
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                icon,

                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: context.fs(19),
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: context.fs(12),
                    color: AppColors.onPrimary,
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Icon box cho header ────────────────────────────────────────────────────
class AuthHeaderIcon extends StatelessWidget {
  final IconData icon;

  const AuthHeaderIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    final sz = context.sw * 0.145;
    return Container(
      width: sz,
      height: sz,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(sz * 0.28),
      ),
      child: Icon(icon, size: sz * 0.5, color: AppColors.onPrimary),
    );
  }
}

// ── Thanh độ mạnh mật khẩu ────────────────────────────────────────────────
class PasswordStrengthBar extends StatelessWidget {
  final String password;

  const PasswordStrengthBar({super.key, required this.password});

  int get _strength {
    if (password.isEmpty) return 0;
    int s = 0;
    if (password.length >= 8) s++;
    if (password.contains(RegExp(r'[A-Z]'))) s++;
    if (password.contains(RegExp(r'[0-9]'))) s++;
    if (password.contains(RegExp(r'[!@#\$%^&*]'))) s++;
    return s;
  }

  String get _label {
    switch (_strength) {
      case 0:
        return '';
      case 1:
        return 'Yếu — thêm chữ hoa và số';
      case 2:
        return 'Trung bình — thêm ký tự đặc biệt';
      case 3:
        return 'Khá mạnh — gần hoàn hảo';
      default:
        return 'Mạnh';
    }
  }

  Color _barColor(int index) {
    if (index >= _strength) return const Color(0xFFE0E0E0);
    switch (_strength) {
      case 1:
        return const Color(0xFFE24B4A);
      case 2:
        return const Color(0xFFEF9F27);
      case 3:
        return const Color(0xFF4C9A15);
      default:
        return const Color(0xFF3B6D11);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        Row(
          children: List.generate(
            4,
            (i) => Expanded(
              child: Container(
                height: 3,
                margin: EdgeInsets.only(right: i < 3 ? 3 : 0),
                decoration: BoxDecoration(
                  color: _barColor(i),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        if (_label.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            _label,
            style: TextStyle(
              fontSize: context.fs(10),
              color: const Color(0xFF999999),
            ),
          ),
        ],
      ],
    );
  }
}
