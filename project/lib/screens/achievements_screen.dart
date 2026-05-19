import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/achievement.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../widgets/poker_table.dart';
import '../widgets/glassmorphic_panel.dart';
import '../widgets/icon_button.dart';

/// 成就列表界面
/// 网格布局展示所有成就
/// 已解锁：彩色图标 + 进度100%
/// 未解锁：灰色图标 + 进度条
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final StorageService _storage = StorageService();
  final AudioService _audio = AudioService();

  List<Achievement> _achievements = [];
  int _unlockedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  void _loadAchievements() {
    final achievements = _storage.getAchievements();
    setState(() {
      _achievements = achievements;
      _unlockedCount = achievements.where((a) => a.isUnlocked).length;
    });
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'military_tech':
        return Icons.military_tech;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'account_balance':
        return Icons.account_balance;
      case 'local_police':
        return Icons.local_police;
      case 'castle':
        return Icons.castle;
      case 'groups':
        return Icons.groups;
      default:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PokerTable(
        child: SafeArea(
          child: Column(
            children: [
              // 顶部栏
              _buildAppBar(),
              const SizedBox(height: 8),
              // 进度总结
              _buildProgressSummary(),
              const SizedBox(height: 16),
              // 成就网格
              Expanded(
                child: _buildAchievementsGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
      child: Row(
        children: [
          CircleIconButton(
            icon: Icons.arrow_back,
            onPressed: () {
              _audio.playClick();
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(width: 16),
          Text(
            AppStrings.achievements,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSummary() {
    final total = _achievements.length;
    final progress = total > 0 ? _unlockedCount / total : 0.0;

    return GlassmorphicPanel(
      width: 240,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      borderRadius: AppDimensions.radiusMedium,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$_unlockedCount',
                style: const TextStyle(
                  color: AppColors.textGold,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppStrings.fontFamily,
                ),
              ),
              Text(
                ' / $total',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 18,
                  fontFamily: AppStrings.fontFamily,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // 总进度条
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primaryButton,
                      Color(0xFFFFA000),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
        vertical: AppDimensions.paddingSmall,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.35,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _achievements.length,
      itemBuilder: (context, index) {
        return _AchievementCard(
          achievement: _achievements[index],
          iconData: _getIconData(_achievements[index].iconName),
        );
      },
    );
  }
}

/// 单个成就卡片
class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final IconData iconData;

  const _AchievementCard({
    required this.achievement,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;

    return GlassmorphicPanel(
      borderRadius: AppDimensions.radiusMedium,
      padding: const EdgeInsets.all(12),
      backgroundColor: isUnlocked
          ? const Color(0xCC2E4A2E)
          : AppColors.glassBackground,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标
          Stack(
            alignment: Alignment.center,
            children: [
              // 发光效果（已解锁）
              if (isUnlocked)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryButton.withOpacity(0.2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryButton.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              Icon(
                iconData,
                size: 32,
                color: isUnlocked ? AppColors.primaryButton : Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 名称
          Text(
            achievement.name,
            style: TextStyle(
              color: isUnlocked ? AppColors.textPrimary : AppColors.textSecondary,
              fontSize: 14,
              fontWeight: isUnlocked ? FontWeight.w600 : FontWeight.w400,
              fontFamily: AppStrings.fontFamily,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // 描述
          Text(
            achievement.description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontFamily: AppStrings.fontFamily,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // 进度条
          _buildProgressBar(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = achievement.progressPercent;
    final isComplete = progress >= 1.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isComplete
                      ? [AppColors.success, AppColors.success]
                      : [
                          AppColors.warning.withOpacity(0.7),
                          AppColors.warning,
                        ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${achievement.progress} / ${achievement.requirement}',
          style: TextStyle(
            color: isComplete ? AppColors.success : AppColors.textSecondary,
            fontSize: 10,
            fontFamily: AppStrings.fontFamily,
          ),
        ),
      ],
    );
  }
}
