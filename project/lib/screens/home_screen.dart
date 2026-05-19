import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/extensions.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../widgets/poker_table.dart';
import '../widgets/glassmorphic_panel.dart';
import '../widgets/game_button.dart';
import '../widgets/chip_display.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';
import 'achievements_screen.dart';
import 'help_screen.dart';

/// 主菜单界面
/// 牌桌背景 + 中央游戏Logo + 按钮列表 + 底部欢乐豆余额
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final StorageService _storage = StorageService();
  final AudioService _audio = AudioService();

  int _balance = 5000;
  bool _isVisible = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _init();

    _animController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 60.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.1, 0.8, curve: Curves.easeOut),
      ),
    );

    // 延迟启动入场动画
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _isVisible = true);
        _animController.forward();
      }
    });
  }

  Future<void> _init() async {
    await _storage.init();
    setState(() {
      _balance = _storage.getBalance();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _navigateTo(Widget screen) {
    _audio.playClick();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: AppDimensions.uiTransitionDuration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PokerTable(
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 主内容
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    // 顶部空白
                    const Spacer(flex: 1),

                    // Logo 区域
                    _buildLogoSection(),

                    const SizedBox(height: 20),

                    // 游戏名称
                    Text(
                      AppStrings.appName,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: context.isSmallScreen ? 36 : 48,
                        letterSpacing: 6,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 按钮区域
                    _buildMenuButtons(),

                    const Spacer(flex: 1),

                    // 底部欢乐豆余额
                    _buildBottomBar(),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Container(
      width: 80,
      height: 110,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF8E1),
            Color(0xFFFFD700),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.2,
        ),
      ),
      child: Center(
        child: Text(
          '\u2660',
          style: TextStyle(
            fontSize: 44,
            color: const Color(0xFF212121),
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButtons() {
    return GlassmorphicPanel(
      width: 280,
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      borderRadius: AppDimensions.radiusLarge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GameButton(
            text: AppStrings.startGame,
            onPressed: () => _navigateTo(const GameScreen()),
            type: GameButtonType.primary,
            width: 240,
            icon: Icons.play_arrow,
          ),
          const SizedBox(height: 12),
          GameButton(
            text: AppStrings.statistics,
            onPressed: () => _navigateTo(const StatisticsScreen()),
            type: GameButtonType.secondary,
            width: 240,
            icon: Icons.bar_chart,
          ),
          const SizedBox(height: 12),
          GameButton(
            text: AppStrings.achievements,
            onPressed: () => _navigateTo(const AchievementsScreen()),
            type: GameButtonType.secondary,
            width: 240,
            icon: Icons.emoji_events,
          ),
          const SizedBox(height: 12),
          GameButton(
            text: AppStrings.settings,
            onPressed: () => _navigateTo(const SettingsScreen()),
            type: GameButtonType.secondary,
            width: 240,
            icon: Icons.settings,
          ),
          const SizedBox(height: 12),
          GameButton(
            text: AppStrings.howToPlay,
            onPressed: () => _navigateTo(const HelpScreen()),
            type: GameButtonType.secondary,
            width: 240,
            icon: Icons.help_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return GlassmorphicPanel(
      width: 200,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      borderRadius: AppDimensions.radiusMedium,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.monetization_on,
            color: AppColors.textGold,
            size: 20,
          ),
          const SizedBox(width: 8),
          ChipDisplay(
            amount: _balance,
            fontSize: 16,
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}
