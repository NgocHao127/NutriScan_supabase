import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../theme/app_responsive.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/common_widgets.dart';

import '../../providers/user_provider.dart';

import 'profile_controller/edit_profile_controller.dart';
import 'profile_controller/edit_profile_state.dart';

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

  final _shapes = [
    ('Thon gọn', Icons.accessibility_new_rounded, 'Ít mỡ'),
    ('Săn chắc', Icons.fitness_center_rounded, 'Cân đối'),
    ('Cơ bắp to', Icons.sports_gymnastics, 'Nhiều cơ'),
    ('Bình thường', Icons.person_outline_rounded, 'Trung bình'),
    ('Thừa cân', Icons.monitor_weight_outlined, 'Mỡ nhiều hơn TB'),
    ('Béo phì', Icons.health_and_safety_outlined, 'Mỡ cao'),
  ];

  bool _controllersLoaded = false;

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

  // Điền controllers khi profile load xong — chỉ 1 lần
  void _fillControllers(EditProfileState state, WidgetRef ref) {
    if (_controllersLoaded || state.isLoading) return;
    _controllersLoaded = true;
    final user = ref.read(userProfileProvider).valueOrNull;
    if (user == null) return;
    _nameCtrl.text = user.name ?? '';
    _emailCtrl.text = user.email ?? '';
    _heightCtrl.text = user.height?.toString() ?? '';
    _weightCtrl.text = user.weight?.toString() ?? '';
    _ageCtrl.text = user.age?.toString() ?? '';
  }

  String get _initials {
    final parts = _nameCtrl.text.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editProfileControllerProvider);
    final controller = ref.read(editProfileControllerProvider.notifier);

    // Điền controllers 1 lần khi load xong
    _fillControllers(state, ref);

    // Lắng nghe kết quả save
    ref.listen(editProfileControllerProvider, (_, next) {
      if (next.isSaved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật hồ sơ thành công!'),
            backgroundColor: AppColors.primaryMid,
          ),
        );
        context.pop();
      } else if (next.status == EditProfileStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Lỗi không xác định'),
            backgroundColor: AppColors.danger,
          ),
        );
      } else if (next.errorMessage != null &&
          next.status == EditProfileStatus.idle) {
        // Validation error
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
        body: state.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : Column(
                children: [
                  _buildHeader(context, state, controller),
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
                            errorText: state.nameError,
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
                                  value: state.selectedGender,
                                  hint: 'Chọn giới tính',
                                  items: _genders,
                                  onChanged: controller.selectGender,
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
                          _buildGoalGrid(context, state, controller),
                          const _SectionLabel('Vóc dáng hiện tại'),
                          _buildBodyShapeGrid(context, state, controller),
                          const _SectionDivider(),
                          const SizedBox(height: 14),
                          const _SectionLabel('Mức độ hoạt động'),
                          _DropdownField(
                            label: 'Mức độ vận động',
                            value: state.selectedActivity,
                            hint: 'Chọn mức độ vận động',
                            items: _activities,
                            onChanged: controller.selectActivity,
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

  Widget _buildHeader(BuildContext context, EditProfileState state,
      EditProfileController controller) {
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
          Expanded(
            child: Column(
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
          ),

          GestureDetector(
            onTap: state.isSaving
                ? null
                : () => controller.save(
                      name: _nameCtrl.text,
                      age: _ageCtrl.text,
                      height: _heightCtrl.text,
                      weight: _weightCtrl.text,
                    ),
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: state.isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Lưu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.fs(13),
                          fontWeight: FontWeight.w500,
                        ),
                      )),
          )
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

  Widget _buildGoalGrid(BuildContext context, EditProfileState state,
      EditProfileController controller) {
    final ratio = context.isDesktop || context.isTablet ? 1.0 : 1.3;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: ratio,
      children: _goals.map((g) {
        final (label, icon, sub) = g;
        return GoalCard(
          icon: icon,
          title: label,
          subtitle: sub,
          isSelected: state.selectedGoal == label,
          onTap: () => controller.selectGoal(label),
        );
      }).toList(),
    );
  }

  Widget _buildBodyShapeGrid(BuildContext context, EditProfileState state,
      EditProfileController controller) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: context.isDesktop ? 1.0 : 1.3,
      children: _shapes.map((s) {
        final (label, icon, sub) = s;
        return GoalCard(
          icon: icon,
          title: label,
          subtitle: sub,
          isSelected: state.selectedBodyShape == label,
          onTap: () => controller.selectBodyShape(label),
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
