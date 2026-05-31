import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_responsive.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_widgets.dart';

import 'auth_controller/auth_state.dart';
import 'auth_controller/register_controller.dart';

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

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerControllerProvider);
    final controller = ref.read(registerControllerProvider.notifier);

    ref.listen(registerControllerProvider, (_, next) {
      if (next.status == AuthStatus.success) {
        context.go('/home');
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    });

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
              _buildForm(context, state, controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, RegisterState state,
      RegisterController controller) {
    return Container(
      color: AppColors.bgPage,
      padding: EdgeInsets.fromLTRB(context.hPad, 20, context.hPad, 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthInput(
              label: 'Họ và tên',
              placeholder: 'Nguyễn Minh Khoa',
              controller: _nameCtrl,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Vui lòng nhập họ tên'
                  : null,
            ),

            const SizedBox(height: 14),
            AuthInput(
              label: 'Email',
              placeholder: 'email@gmail.com',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email';
                if (!v.contains('@')) return 'Email không hợp lệ';
                return null;
              },
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
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
                    if (v.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
                    return null;
                  },
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
              validator: (v) {
                if (v == null || v.isEmpty) return 'Vui lòng xác nhận mật khẩu';
                if (v != _passwordCtrl.text) return 'Mật khẩu không khớp';
                return null;
              },
            ),

            const SizedBox(height: 22),
            AuthButton(
              label: 'Tạo tài khoản',
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  controller.register(
                    _nameCtrl.text,
                    _emailCtrl.text,
                    _passwordCtrl.text,
                    _confirmCtrl.text,
                  );
                }
              },
              isLoading: state.isLoading,
            ),

            const SizedBox(height: 16),
            const OrDivider(),

            const SizedBox(height: 16),
            GoogleButton(
              label: 'Đăng ký với Google',
              onPressed: controller.registerWithGoogle,
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
                  onTap: () => context.go('/login'),
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
      ),
    );
  }
}
