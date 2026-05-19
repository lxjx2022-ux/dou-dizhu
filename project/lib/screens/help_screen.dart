import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/audio_service.dart';
import '../widgets/poker_table.dart';
import '../widgets/glassmorphic_panel.dart';
import '../widgets/icon_button.dart';

/// 玩法说明界面
/// 规则文本 / 牌型大小说明 / 倍率计算说明
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = AudioService();

    return Scaffold(
      body: PokerTable(
        child: SafeArea(
          child: Column(
            children: [
              // 顶部栏
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                ),
                child: Row(
                  children: [
                    CircleIconButton(
                      icon: Icons.arrow_back,
                      onPressed: () {
                        audio.playClick();
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 16),
                    Text(
                      AppStrings.howToPlay,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 内容
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingLarge,
                  ),
                  child: Column(
                    children: [
                      _buildSection(
                        title: '游戏规则',
                        icon: Icons.rule_folder,
                        children: [
                          _buildRuleText(
                            '斗地主是一种三人扑克游戏，使用一副牌（54张），'
                            '包括两张王牌（大王、小王）。',
                          ),
                          const SizedBox(height: 12),
                          _buildNumberedRule(1, '每人发17张牌，留3张底牌'),
                          _buildNumberedRule(2, '玩家抢地主，抢到者获得底牌成为地主'),
                          _buildNumberedRule(3, '地主独自对抗两个农民'),
                          _buildNumberedRule(4, '先出完牌的一方获胜'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        title: '牌型说明',
                        icon: Icons.style,
                        children: [
                          _buildHandTypeRow('单张', '任意一张牌'),
                          _buildHandTypeRow('对子', '两张同点数'),
                          _buildHandTypeRow('三张', '三张同点数'),
                          _buildHandTypeRow('三带一', '三张 + 单张'),
                          _buildHandTypeRow('三带二', '三张 + 对子'),
                          _buildHandTypeRow('顺子', '5张以上连续单张（3-A,不含2和王）'),
                          _buildHandTypeRow('连对', '3对以上连续对子'),
                          _buildHandTypeRow('飞机', '2组以上连续三张'),
                          _buildHandTypeRow('炸弹', '四张同点数'),
                          _buildHandTypeRow('火箭', '大王+小王（最大牌型）'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        title: '牌型大小',
                        icon: Icons.format_list_numbered,
                        children: [
                          _buildRuleText(
                            '火箭（双王）> 炸弹 > 一般牌型',
                          ),
                          const SizedBox(height: 8),
                          _buildRuleText(
                            '炸弹之间：点数大的炸弹更大',
                          ),
                          const SizedBox(height: 8),
                          _buildRuleText(
                            '一般牌型：必须是同类型才能比较，'
                            '比较主牌点数大小',
                          ),
                          const SizedBox(height: 8),
                          _buildRuleText(
                            '顺子/连对/飞机：长度必须相同才能比较，'
                            '比较最小点数',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        title: '倍率规则',
                        icon: Icons.calculate,
                        children: [
                          _buildRateRow('基础倍率', '1倍'),
                          _buildRateRow('抢地主', 'x2'),
                          _buildRateRow('加倍', 'x2'),
                          _buildRateRow('超级加倍', 'x4'),
                          _buildRateRow('炸弹', 'x2'),
                          _buildRateRow('春天/反春', 'x2'),
                          const Divider(color: AppColors.glassBorder, height: 16),
                          _buildRuleText(
                            '春天：地主出完所有牌，农民一张未出',
                          ),
                          const SizedBox(height: 8),
                          _buildRuleText(
                            '反春：农民出完牌，地主只出过第一手',
                          ),
                        ],
                      ),
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

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return GlassmorphicPanel(
      borderRadius: AppDimensions.radiusMedium,
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.textGold, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textGold,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppStrings.fontFamily,
                ),
              ),
            ],
          ),
          const Divider(
            color: AppColors.glassBorder,
            height: 20,
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRuleText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
        fontFamily: AppStrings.fontFamily,
        height: 1.6,
      ),
    );
  }

  Widget _buildNumberedRule(int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.primaryButton.withOpacity(0.2),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: AppColors.primaryButton.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: AppColors.primaryButton,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppStrings.fontFamily,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontFamily: AppStrings.fontFamily,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandTypeRow(String name, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.glassHighlight,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: AppStrings.fontFamily,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontFamily: AppStrings.fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateRow(String name, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontFamily: AppStrings.fontFamily,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primaryButton.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.primaryButton,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: AppStrings.fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
