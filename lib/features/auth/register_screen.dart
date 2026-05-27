import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_responsive.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_widgets.dart';
import '../../providers/auth_provider.dart';
import '../../core/api_service.dart';
import '../../providers/api_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isLoading = false;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _nameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmError = null;
    });
    bool ok = true;

    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _nameError = 'Vui lòng nhập họ tên');
      ok = false;
    }

    if (_emailCtrl.text.trim().isEmpty) {
      setState(() => _emailError = 'Vui lòng nhập email');
      ok = false;
    } else if (!_emailCtrl.text.contains('@')) {
      setState(() => _emailError = 'Email không hợp lệ');
      ok = false;
    }

    if (_passwordCtrl.text.isEmpty) {
      setState(() => _passwordError = 'Vui lòng nhập mật khẩu');
      ok = false;
    } else if (_passwordCtrl.text.length < 6) {
      setState(() => _passwordError = 'Mật khẩu tối thiểu 6 ký tự');
      ok = false;
    }

    if (_confirmCtrl.text.isEmpty) {
      setState(() => _confirmError = 'Vui lòng xác nhận mật khẩu');
      ok = false;
    } else if (_confirmCtrl.text != _passwordCtrl.text) {
      setState(() => _confirmError = 'Mật khẩu không khớp');
      ok = false;
    }

    return ok;
  }

  Future<void> _onRegister() async {
    if (!_validate()) return;
    setState(() => _isLoading = true);

    try {
      // Đăng ký Firebase Auth
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
          );
      final user = userCredential.user;
      if (user != null) {
        // Cập nhật tên hiển thị trên Firebase
        await user.updateDisplayName(_nameCtrl.text.trim());

        // Lấy token và gọi API backend để tạo user trong supabase
        final idToken = await user.getIdToken();
        final apiService = ref.read(apiServiceProvider);
        await apiService.login(idToken!);

        // Có thể gọi API cập nhật thêm thông tin (name) nếu backend hỗ trợ
        // Hiện tại endpoint /auth/login chỉ tạo user với uid, email,
        // bạn có thể mở rộng backend để nhận name.

        if (mounted) {
          context.go('/home');
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = 'Đăng ký thất bại';
      if (e.code == 'email-already-in-use') {
        errorMsg = 'Email đã được sử dụng';
      } else if (e.code == 'invalid-email') {
        errorMsg = 'Email không hợp lệ';
      } else if (e.code == 'week-password') {
        errorMsg = 'Mật khẩu quá yếu';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: AppColors.danger),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onGoogleRegister() async {
    try {
      await ref.read(authNotifierProvider.notifier).signInWithGoogle();
      // Router tự chuyển hướng
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đăng ký google: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
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
          child: Column(
            children: [
              AuthHeader(
                leadingAction: GestureDetector(
                  onTap: () => context.go('/login'),
                  child: const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                icon: const AuthHeaderIcon(icon: Icons.person_add_outlined),
                title: 'Tạo tài khoản',
                subtitle: 'Bắt đầu hành trình dinh dưỡng',
              ),
              _buildForm(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Container(
      color: AppColors.bgPage,
      padding: EdgeInsets.fromLTRB(context.hPad, 20, context.hPad, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthInput(
            label: 'Họ và tên',
            placeholder: 'Nguyễn Minh Khoa',
            controller: _nameCtrl,
            errorText: _nameError,
          ),

          const SizedBox(height: 14),
          AuthInput(
            label: 'Email',
            placeholder: 'email@gmail.com',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            errorText: _emailError,
          ),

          const SizedBox(height: 14),
          // Password với strength bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthInput(
                label: 'Mật khẩu',
                placeholder: '••••••••',
                controller: _passwordCtrl,
                isPassword: true,
                errorText: _passwordError,
              ),
              ValueListenableBuilder(
                valueListenable: _passwordCtrl,
                builder: (context, value, child) =>
                    PasswordStrengthBar(password: value.text),
              ),
            ],
          ),

          const SizedBox(height: 14),
          AuthInput(
            label: 'Xác nhận mật khẩu',
            placeholder: 'Nhập lại mật khẩu',
            controller: _confirmCtrl,
            isPassword: true,
            errorText: _confirmError,
          ),

          const SizedBox(height: 22),
          AuthButton(
            label: 'Tạo tài khoản',
            onPressed: _onRegister,
            isLoading: _isLoading,
          ),

          const SizedBox(height: 16),
          const OrDivider(),

          const SizedBox(height: 16),
          GoogleButton(
            label: 'Đăng ký với Google',
            onPressed: _onGoogleRegister,
          ),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Đã có tài khoản? ',
                style: TextStyle(
                  fontSize: context.fs(12),
                  color: AppColors.textSecondary,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  'Đăng nhập',
                  style: TextStyle(
                    fontSize: context.fs(12),
                    color: AppColors.linkText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
