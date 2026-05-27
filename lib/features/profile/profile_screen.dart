import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_responsive.dart';
import '../theme/app_theme.dart';

import 'widgets/profile_app_bar.dart';
import 'widgets/settings_tab.dart';
import 'widgets/goal_tab.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller cho 2 tab: Mục tiêu và Cài đặt
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // AppBar xanh — CHỈ render 1 lần duy nhất ở đây
          const ProfileAppBar(),

          // Desktop → NavigationRail dọc bên trái
          // Tablet  → TabBar ngang, content không chia cột
          // Mobile  → TabBar ngang, layout đơn giản
          if (context.isDesktop)
            _buildDesktopBody()
          else
            _buildMobileTabletBody(context),
        ],
      ),
    );
  }

  // ── Desktop: NavigationRail dọc + content chia cột bên trong tab ─────────
  Widget _buildDesktopBody() {
    return Expanded(
      child: Row(
        children: [
          ListenableBuilder(
            listenable: _tabController,
            builder: (context, _) => NavigationRail(
              backgroundColor: Colors.white,
              selectedIndex: _tabController.index,
              onDestinationSelected: (i) =>
                  setState(() => _tabController.animateTo(i)),
              labelType: NavigationRailLabelType.all,
              selectedIconTheme: const IconThemeData(color: AppColors.primary),
              selectedLabelTextStyle: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              unselectedLabelTextStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.flag_outlined),
                  selectedIcon: Icon(Icons.flag),
                  label: Text('Mục tiêu'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Cài đặt'),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1, thickness: 0.5),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [GoalTab(), SettingsTab()],
            ),
          ),
        ],
      ),
    );
  }

  // ── Mobile + Tablet: TabBar ngang bình thường ────────────────────────────
  // GoalTab và SettingsTab tự xử lý layout bên trong theo isTablet/isMobile
  Widget _buildMobileTabletBody(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2,
            labelStyle: TextStyle(
              fontSize: context.fs(13),
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Hồ sơ & mục tiêu'),
              Tab(text: 'Cài đặt'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [GoalTab(), SettingsTab()],
            ),
          ),
        ],
      ),
    );
  }
}
