import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../theme/app_responsive.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/common_widgets.dart';

import '../../providers/user_provider.dart';
import '../../providers/api_provider.dart';
import '../../models/users_model.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  // Khai báo đầy đủ các Controller ở đây
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  // Không gán cứng mặc định để hiển thị chữ mờ "Chọn..." khi tài khoản chưa có dữ liệu
  String? _selectedGender;
  String? _selectedGoal;
  String? _selectedActivity;

  // Danh sách dữ liệu tĩnh
  final _genders = ['Nam', 'Nữ', 'Khác'];
  final _activities = [
    'Ít vận động (văn phòng)',
    'Vận động nhẹ (1-3 ngày/tuần)',
    'Vận động trung bình (3-5 ngày/tuần)',
    'Vận động nhiều (6-7 ngày/tuần)',
    'Vận động rất nhiều (công việc nặng hoặc tập luyện 2 lần/ngày)',
  ];

  final _goals = [
    ('Giảm cân', Icons.trending_down_rounded, 'Deficit calo'),
    ('Tăng cơ', Icons.fitness_center_rounded, 'Surplus calo'),
    ('Duy trì', Icons.balance_rounded, 'Cân bằng'),
    ('Sức khỏe', Icons.favorite_border_rounded, 'Tổng thể'),
  ];

  String? _nameError;
  String? _selectedBodyShape;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    // Đảm bảo giải phóng bộ nhớ cho các Controller khi đóng màn hình
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  // Tải dữ liệu từ supabase
  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      // Lấy profile từ provider (đã cache hoặc gọi API)
      final userAsync = ref.read(userProfileProvider);
      // Đợi provider load xong nếu đang loading
      UserModel? user;
      if (userAsync is AsyncData) {
        user = userAsync.value;
      } else {
        // Nếu provider chưa sẵn sàng, đợi future
        user = await ref.read(userProfileProvider.future);
      }

      if (user != null) {
        _emailCtrl.text = user.email ?? '';
        _nameCtrl.text = user.name ?? '';
        _heightCtrl.text = user.height?.toString() ?? '';
        _weightCtrl.text = user.weight?.toString() ?? '';
        _ageCtrl.text = user.age?.toString() ?? '';
        _selectedGender = user.gender;
        _selectedGoal = user.goal;
        _selectedActivity = user.activityLevel;
        _selectedBodyShape = user.bodyShape;
      }
    } catch (e) {
      print('Lỗi khi tải thông tin hồ sơ: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  // Kiểm tra dữ liệu trước khi lưu
  bool _validateData() {
    setState(() => _nameError = null); // Reset lỗi trước khi kiểm tra

    // Kiểm tra Tên (Báo lỗi ngay dưới ô nhập)
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _nameError = 'Vui lòng nhập họ tên');
      return false;
    }

    // Kiểm tra các chỉ số cơ thể bắt buộc (Tuổi, Chiều cao, Cân nặng)
    if (_ageCtrl.text.trim().isEmpty ||
        _heightCtrl.text.trim().isEmpty ||
        _weightCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ tuổi, chiều cao và cân nặng'),
          backgroundColor: AppColors.danger,
        ),
      );
      return false;
    }

    // Kiểm tra các Dropdown đã được chọn chưa (khác null)
    if (_selectedGender == null ||
        _selectedGoal == null ||
        _selectedActivity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng chọn giới tính, mục tiêu và mức độ hoạt động',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
      return false;
    }
    // Nếu vượt qua hết các bài kiểm tra trên thì mới cho phép Lưu
    return true;
  }

  // Lưu dữ liệu
  Future<void> _onSave() async {
    if (!_validateData()) return; // Nếu dữ liệu không hợp lệ, không tiếp tục
    setState(() => _isSaving = true);

    try {
      final userService = ref.read(userServiceProvider);
      final updatedData = {
        'name': _nameCtrl.text.trim(),
        'age': int.tryParse(_ageCtrl.text) ?? 0,
        'height': double.tryParse(_heightCtrl.text) ?? 0.0,
        'weight': double.tryParse(_weightCtrl.text) ?? 0.0,
        'gender': _selectedGender,
        'goal': _selectedGoal,
        'activity_level': _selectedActivity,
        'body_shape': _selectedBodyShape,
      };

      // Gọi API cập nhật profile
      await userService.updateProfile(updatedData);

      // Sau khi update, invalidate userProfileProvider để load lại
      ref.invalidate(userProfileProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật hồ sơ thành công!'),
          backgroundColor: AppColors.primaryMid,
        ),
      );
      context.pop(); // Quay lại màn hình trước
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lỗi kết nối. Không thể lưu!'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
    if (mounted) setState(() => _isSaving = false);
  }

  String get _initials {
    final parts = _nameCtrl.text.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(brightness: Brightness.light),
      child: Scaffold(
        backgroundColor: AppColors.bgPage,
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        context.hPad,
                        20,
                        context.hPad,
                        40,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAvatarSection(context),
                          const _SectionDivider(),
                          const _SectionLabel('Thông tin cơ bản'),
                          AuthInput(
                            label: 'Họ và tên',
                            placeholder: 'Nguyễn Minh Khoa',
                            controller: _nameCtrl,
                            errorText: _nameError,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: AuthInput(
                                  label: 'Tuổi',
                                  placeholder: '24',
                                  controller: _ageCtrl,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _DropdownField(
                                  label: 'Giới tính',
                                  value: _selectedGender,
                                  hint: 'Chọn giới tính',
                                  items: _genders,
                                  onChanged: (v) =>
                                      setState(() => _selectedGender = v),
                                ),
                              ),
                            ],
                          ),
                          const _SectionDivider(),
                          const _SectionLabel('Chỉ số cơ thể'),
                          Row(
                            children: [
                              Expanded(
                                child: AuthInput(
                                  label: 'Chiều cao (cm)',
                                  placeholder: '170',
                                  controller: _heightCtrl,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AuthInput(
                                  label: 'Cân nặng (kg)',
                                  placeholder: '65',
                                  controller: _weightCtrl,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const _SectionDivider(),
                          const _SectionLabel('Mục tiêu'),
                          _buildGoalGrid(context),
                          const SizedBox(height: 14),
                          _DropdownField(
                            label: 'Mức độ vận động',
                            value: _selectedActivity,
                            hint: 'Chọn mức độ vận động',
                            items: _activities,
                            onChanged: (v) =>
                                setState(() => _selectedActivity = v),
                          ),
                          const SizedBox(height: 14),
                          const _SectionLabel('Vóc dáng'),
                          _buildBodyShapeGrid(context),
                          const SizedBox(height: 28),
                          AuthButton(
                            label: 'Lưu thay đổi',
                            onPressed: _onSave,
                            isLoading: _isSaving,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
          // Avatar hiển thị chữ cái đầu tên
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: btnSz,
              height: btnSz,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
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
                'Chỉnh sửa hồ sơ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.fs(17),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Cập nhật thông tin cá nhân',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: context.fs(11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: Center(
              child: ValueListenableBuilder(
                valueListenable: _nameCtrl,
                builder: (context, value, child) => Text(
                  _initials,
                  style: TextStyle(
                    fontSize: context.fs(22),
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              //
            },
            child: Text(
              'Thay ảnh đại diện',
              style: TextStyle(
                fontSize: context.fs(12),
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalGrid(BuildContext context) {
    final ratio = context.isDesktop
        ? 1.0
        : context.isTablet
            ? 1.0
            : 1.3;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: ratio,
      children: _goals.map((g) {
        final (label, icon, sub) = g;
        final isSelected = _selectedGoal == label;
        return GoalCard(
          icon: icon,
          title: label,
          subtitle: sub,
          isSelected: isSelected,
          onTap: () => setState(() => _selectedGoal = label),
        );
      }).toList(),
    );
  }

  Widget _buildBodyShapeGrid(BuildContext context) {
    final shapes = [
      ('Thon gọn', Icons.accessibility_new_rounded, 'Ít mỡ'),
      ('Săn chắc', Icons.fitness_center_rounded, 'Cân đối'),
      ('Cơ bắp to', Icons.sports_gymnastics, 'Nhiều cơ'),
      ('Bình thường', Icons.person_outline_rounded, 'Trung bình'),
      ('Thừa cân', Icons.monitor_weight_outlined, 'Mỡ nhiều hơn TB'),
      ('Béo phì', Icons.health_and_safety_outlined, 'Mỡ cao'),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: context.isDesktop ? 1.0 : 1.3,
      children: shapes.map((s) {
        final (label, icon, sub) = s;
        final isSelected = _selectedBodyShape == label;
        return GoalCard(
          icon: icon,
          title: label,
          subtitle: sub,
          isSelected: isSelected,
          onTap: () => setState(() => _selectedBodyShape = label),
        );
      }).toList(),
    );
  }
}

// ── Dropdown Field hoàn chỉnh với chống tràn chữ
class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: context.fs(11),
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          initialValue: value,
          hint: Text(
            hint,
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: context.fs(13),
            ),
          ),
          isExpanded: true, // Rất quan trọng để dropdown không bị vỡ bố cục
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.bgCard,
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
                color: AppColors.primaryMid,
                width: 1.5,
              ),
            ),
          ),
          style: TextStyle(
            fontSize: context.fs(13),
            color: AppColors.textPrimary,
          ),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    overflow: TextOverflow
                        .ellipsis, // Cắt bớt đuôi bằng "..." nếu câu văn quá dài
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: context.fs(11),
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Divider(color: AppColors.divider, thickness: 0.5),
    );
  }
}
