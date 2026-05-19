import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/audio_service.dart';
import '../widgets/glassmorphic_panel.dart';
import '../widgets/game_button.dart';

/// 暂停菜单（毛玻璃覆盖层）
/// [继续游戏, 重新开始, 返回主菜单, 设置]
class PauseScreen extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  const PauseScreen({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    final audio = AudioService();

    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: GlassmorphicPanel(
          width: 320,
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          borderRadius: AppDimensions.radiusLarge,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题
              Text(
                '游戏暂停',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),
              const Icon(
                Icons.pause_circle_outline,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 24),
              // 继续游戏
              GameButton(
                text: AppStrings.continueGame,
                onPressed: () {
                  audio.playClick();
                  onResume();
                },
                type: GameButtonType.success,
                width: 260,
                icon: Icons.play_arrow,
              ),
              const SizedBox(height: 12),
              // 重新开始
              GameButton(
                text: '重新开始',
                onPressed: () {
                  audio.playClick();
                  onRestart();
                },
                type: GameButtonType.primary,
                width: 260,
                icon: Icons.refresh,
              ),
              const SizedBox(height: 12),
              // 返回主菜单
              GameButton(
                text: '返回主菜单',
                onPressed: () {
                  audio.playClick();
                  onQuit();
                },
                type: GameButtonType.danger,
                width: 260,
                icon: Icons.exit_to_app,
              ),
              const SizedBox(height: 12),
              // 音效开关
              _buildSoundToggle(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoundToggle() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '音效',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontFamily: AppStrings.fontFamily,
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: true,
              onChanged: (value) {},
              activeColor: AppColors.primaryButton,
            ),
          ],
        );
      },
    );
  }
}
