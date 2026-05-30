import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../theme/app_responsive.dart';
import 'onboarding_controller/onboarding_controller.dart';
import 'onboarding_controller/onboarding_state.dart';

class _OnboardingData {
  final String emoji;
  final String title;
  final String subtitle;
  final Color bgColor;
  final Color accentColor;

  const _OnboardingData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.accentColor,
  });
}

const _pages = [
  _OnboardingData(
    emoji: '🥗',
    title: 'Theo dõi dinh dưỡng\nthông minh',
    subtitle:
        'Ghi lại bữa ăn hàng ngày, theo dõi calo và macro một cách dễ dàng và chính xác.',
    bgColor: Color(0xFFF0F7EB),
    accentColor: AppColors.primary,
  ),
  _OnboardingData(
    emoji: '📸',
    title: 'AI nhận diện\nmón ăn chỉ 1 chạm',
    subtitle:
        'Chỉ cần chụp ảnh món ăn, AI sẽ tự động phân tích và tính toán dinh dưỡng cho bạn.',
    bgColor: Color(0xFFEBF3FA),
    accentColor: Color(0xFF185FA5),
  ),
  _OnboardingData(
    emoji: '🎯',
    title: 'Mục tiêu\ncá nhân hóa cho bạn',
    subtitle:
        'Đặt mục tiêu giảm cân, tăng cơ hoặc duy trì sức khỏe. NutriScan tính toán chính xác theo cơ thể bạn.',
    bgColor: Color(0xFFFAF3EB),
    accentColor: Color(0xFFE67E22),
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    // Navigate khi done
    ref.listen(onboardingControllerProvider, (_, next) {
      if (next.isDone) context.go('/login');
    });

    final page = _pages[state.currentPage];

    return Scaffold(
      backgroundColor: page.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: EdgeInsets.fromLTRB(context.hPad, 12, context.hPad, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: state.isLastPage
                    ? const SizedBox.shrink()
                    : TextButton(
                        onPressed: controller.finish,
                        child: Text(
                          'Bỏ qua',
                          style: TextStyle(
                            fontSize: context.fs(13),
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: controller.goToPage,
                itemCount: _pages.length,
                itemBuilder: (_, i) => _OnboardingPage(data: _pages[i]),
              ),
            ),

            // Bottom controls
            Padding(
              padding: EdgeInsets.fromLTRB(context.hPad, 0, context.hPad, 32),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == state.currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == state.currentPage
                              ? page.accentColor
                              : page.accentColor.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Nút trước và sau
                  Row(
                    children: [
                      // Nút Trước — ẩn ở trang đầu
                      if (state.currentPage > 0)
                        GestureDetector(
                          onTap: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOut,
                            );
                            controller.goToPage(state.currentPage - 1);
                          },
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: page.accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: page.accentColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Icon(Icons.arrow_back_rounded,
                                color: page.accentColor),
                          ),
                        )
                      else
                        const SizedBox(width: 52),

                      const SizedBox(width: 12),

                      // Nút Tiếp / Bắt đầu
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: page.accentColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              if (state.isLastPage) {
                                controller.finish();
                              } else {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeInOut,
                                );
                                controller.nextPage();
                              }
                            },
                            child: Text(
                              state.isLastPage ? 'Bắt đầu ngay!' : 'Tiếp theo',
                              style: TextStyle(
                                fontSize: context.fs(15),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Đăng nhập link
                  if (state.isLastPage) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Đã có tài khoản? ',
                          style: TextStyle(
                            fontSize: context.fs(13),
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: controller.finish,
                          child: Text(
                            'Đăng nhập',
                            style: TextStyle(
                              fontSize: context.fs(13),
                              color: page.accentColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final emojiSize = context.isDesktop
        ? 160.0
        : context.isTablet
            ? 140.0
            : 120.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.hPad),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji illustration
          Container(
            width: emojiSize * 1.6,
            height: emojiSize * 1.6,
            decoration: BoxDecoration(
              color: data.accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                data.emoji,
                style: TextStyle(fontSize: emojiSize),
              ),
            ),
          ),
          const SizedBox(height: 48),

          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.fs(24),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          // Subtitle
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.fs(14),
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
