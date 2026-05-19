import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/extensions.dart';
import '../models/statistics.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../widgets/poker_table.dart';
import '../widgets/glassmorphic_panel.dart';
import '../widgets/icon_button.dart';

/// 战绩统计界面
/// 总局数、胜率、连胜、地主/农民胜率对比、炸弹数、春天数
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final StorageService _storage = StorageService();
  final AudioService _audio = AudioService();

  Statistics _stats = Statistics();

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  void _loadStatistics() {
    setState(() {
      _stats = _storage.getStatistics();
    });
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
              const SizedBox(height: 16),
              // 统计内容
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingLarge,
                  ),
                  child: Column(
                    children: [
                      // 概览卡片
                      _buildOverviewCard(),
                      const SizedBox(height: 16),
                      // 胜率对比
                      _buildWinRateCard(),
                      const SizedBox(height: 16),
                      // 详细数据
                      _buildDetailCard(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
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
            AppStrings.statistics,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard() {
    return GlassmorphicPanel(
      borderRadius: AppDimensions.radiusMedium,
      child: Column(
        children: [
          const Text(
            '游戏概览',
            style: TextStyle(
              color: AppColors.textGold,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              fontFamily: AppStrings.fontFamily,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: '总局数',
                  value: '${_stats.totalGames}',
                  icon: Icons.sports_esports,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: '胜率',
                  value: _stats.winRatePercent,
                  icon: Icons.trending_up,
                  valueColor: _stats.winRate > 0.5
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: '连胜',
                  value: '${_stats.currentStreak}',
                  icon: Icons.local_fire_department,
                  valueColor: _stats.currentStreak > 2
                      ? AppColors.error
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWinRateCard() {
    return GlassmorphicPanel(
      borderRadius: AppDimensions.radiusMedium,
      child: Column(
        children: [
          const Text(
            '角色胜率',
            style: TextStyle(
              color: AppColors.textGold,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              fontFamily: AppStrings.fontFamily,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _RoleStat(
                  label: '地主',
                  wins: _stats.landlordWins,
                  total: _stats.landlordWins +
                      (_stats.losses - _stats.farmerWins).clamp(0, 999999),
                  color: const Color(0xFFFF8F00),
                  icon: Icons.person,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _RoleStat(
                  label: '农民',
                  wins: _stats.farmerWins,
                  total: _stats.farmerWins +
                      (_stats.losses - (_stats.losses - _stats.farmerWins)
                          .clamp(0, 999999))
                          .clamp(0, 999999),
                  color: const Color(0xFF66BB6A),
                  icon: Icons.people,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard() {
    return GlassmorphicPanel(
      borderRadius: AppDimensions.radiusMedium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              '详细数据',
              style: TextStyle(
                color: AppColors.textGold,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: AppStrings.fontFamily,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('胜利次数', '${_stats.wins}', Colors.green),
          _buildDetailRow('失败次数', '${_stats.losses}', Colors.red),
          _buildDetailRow('最高连胜', '${_stats.maxStreak}', AppColors.warning),
          _buildDetailRow('打出炸弹', '${_stats.bombsPlayed}', AppColors.error),
          _buildDetailRow('春天次数', '${_stats.springs}', AppColors.success),
          _buildDetailRow('反春次数', '${_stats.antiSprings}', AppColors.info),
          const Divider(color: AppColors.glassBorder),
          _buildDetailRow(
            '净收益',
            '${_stats.netEarnings >= 0 ? "+" : ""}${_stats.netEarnings.toFormattedString()}',
            _stats.netEarnings >= 0 ? AppColors.success : AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontFamily: AppStrings.fontFamily,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: AppStrings.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}

/// 统计项组件
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.textSecondary,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            fontFamily: AppStrings.fontFamily,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontFamily: AppStrings.fontFamily,
          ),
        ),
      ],
    );
  }
}

/// 角色统计组件
class _RoleStat extends StatelessWidget {
  final String label;
  final int wins;
  final int total;
  final Color color;
  final IconData icon;

  const _RoleStat({
    required this.label,
    required this.wins,
    required this.total,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final rate = total > 0 ? (wins / total * 100).toStringAsFixed(1) : '0.0';

    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          '$wins / $total',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: AppStrings.fontFamily,
          ),
        ),
        const SizedBox(height: 4),
        // 进度条
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: total > 0 ? wins / total : 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.7),
                    color,
                  ],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$rate%',
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: AppStrings.fontFamily,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontFamily: AppStrings.fontFamily,
          ),
        ),
      ],
    );
  }
}
