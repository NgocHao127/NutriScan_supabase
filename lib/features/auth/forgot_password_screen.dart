import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_responsive.dart';
import '../widgets/auth_widgets.dart';
import '../theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;
  String? _emailError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _onSend() async {
    setState(() => _emailError = null);
    if (_emailCtrl.text.trim().isEmpty) {
      setState(() => _emailError = 'Vui lòng nhập email');
      return;
    }
    if (!_emailCtrl.text.contains('@')) {
      setState(() => _emailError = 'Email không hợp lệ');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        _emailCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _emailError = 'Không thể gửi email. Vui lòng thử lại.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(brightness: Brightness.light),
      child: Scaffold(
        backgroundColor: AppColors.bgPage,
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Column(children: [_buildHeader(context), _buildForm(context)]),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final btnSz = context.sw * 0.082;

    return Container(
      color: AppColors.primary,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPad + 14, 20, 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/login'),
            child: Container(
              width: btnSz,
              height: btnSz,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.18),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: btnSz * 0.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quên mật khẩu',
                style: TextStyle(
                  fontSize: context.fs(17),
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Đặt lại qua email',
                style: TextStyle(
                  fontSize: context.fs(11),
                  color: AppColors.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Container(
      color: AppColors.bgPage,
      padding: EdgeInsets.fromLTRB(context.hPad, 22, context.hPad, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              border: Border.all(color: const Color(0xFFC8DAB8), width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Nhập email đã đăng ký. Chúng tôi sẽ gửi link đặt lại mật khẩu trong vài phút.',
                    style: TextStyle(
                      fontSize: context.fs(12),
                      color: AppColors.primaryDark,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          AuthInput(
            label: 'Email đã đăng ký',
            placeholder: 'minhkhoa@gmail.com',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            errorText: _emailError,
          ),

          const SizedBox(height: 22),
          AuthButton(
            label: 'Gửi link đặt lại',
            onPressed: _onSend,
            isLoading: _isLoading,
          ),

          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: () => context.go('/login'),
              child: Text(
                '← Quay lại đăng nhập',
                style: TextStyle(
                  fontSize: context.fs(12),
                  color: AppColors.linkText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Trạng thái đã gửi email
          if (_emailSent) ...[
            const SizedBox(height: 28),
            const Divider(color: Color(0xFFEEEEEE)),
            const SizedBox(height: 20),
            Text(
              'Email đã được gửi',
              style: TextStyle(
                fontSize: context.fs(13),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFC8DAB8), width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.email_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kiểm tra hộp thư',
                              style: TextStyle(
                                fontSize: context.fs(13),
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                            Text(
                              _emailCtrl.text,
                              style: TextStyle(
                                fontSize: context.fs(11),
                                color: const Color(0xFF999999),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Link hết hạn sau 15 phút. Không thấy email? Kiểm tra thư mục spam.',
                    style: TextStyle(
                      fontSize: context.fs(11),
                      color: const Color(0xFF666666),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _onSend,
                    child: Text(
                      'Gửi lại email',
                      style: TextStyle(
                        fontSize: context.fs(12),
                        color: const Color(0xFF4C9A15),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
