import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/difficulty.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';
import '../widgets/poker_table.dart';
import '../widgets/glassmorphic_panel.dart';
import '../widgets/game_button.dart';
import '../widgets/icon_button.dart';

/// 设置界面
/// 难度选择 / 癞子模式 / 音效 / BGM / 震动 / 重置数据
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storage = StorageService();
  final AudioService _audio = AudioService();
  final HapticService _haptic = HapticService();

  Difficulty _difficulty = Difficulty.normal;
  bool _laiziEnabled = false;
  bool _soundEnabled = true;
  bool _bgmEnabled = true;
  bool _hapticEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _difficulty = _storage.getDifficulty();
      _laiziEnabled = _storage.getLaiziEnabled();
      _soundEnabled = _storage.getSoundEnabled();
      _bgmEnabled = _storage.getBgmEnabled();
      _hapticEnabled = _storage.getHapticEnabled();
    });
  }

  Future<void> _saveSettings() async {
    await _storage.setDifficulty(_difficulty);
    await _storage.setLaiziEnabled(_laiziEnabled);
    await _storage.setSoundEnabled(_soundEnabled);
    await _storage.setBgmEnabled(_bgmEnabled);
    await _storage.setHapticEnabled(_hapticEnabled);
  }

  void _setDifficulty(Difficulty d) {
    setState(() => _difficulty = d);
    _storage.setDifficulty(d);
    _audio.playClick();
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
              // 设置内容
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingLarge,
                  ),
                  child: Column(
                    children: [
                      // 难度选择
                      _buildSectionTitle('游戏难度'),
                      _buildDifficultySelector(),
                      const SizedBox(height: 16),

                      // 开关设置
                      _buildSectionTitle('游戏设置'),
                      _buildToggleSettings(),
                      const SizedBox(height: 16),

                      // 重置数据
                      _buildSectionTitle('数据管理'),
                      _buildResetSection(),
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
              _saveSettings();
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(width: 16),
          Text(
            AppStrings.settings,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.paddingSmall,
        bottom: AppDimensions.paddingSmall,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: AppStrings.fontFamily,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return GlassmorphicPanel(
      borderRadius: AppDimensions.radiusMedium,
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Row(
        children: [
          Expanded(
            child: _DifficultyButton(
              label: AppStrings.easy,
              isSelected: _difficulty == Difficulty.easy,
              onTap: () => _setDifficulty(Difficulty.easy),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _DifficultyButton(
              label: AppStrings.normal,
              isSelected: _difficulty == Difficulty.normal,
              onTap: () => _setDifficulty(Difficulty.normal),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _DifficultyButton(
              label: AppStrings.hard,
              isSelected: _difficulty == Difficulty.hard,
              onTap: () => _setDifficulty(Difficulty.hard),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSettings() {
    return GlassmorphicPanel(
      borderRadius: AppDimensions.radiusMedium,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
      child: Column(
        children: [
          _buildToggleRow(
            icon: Icons.casino,
            label: AppStrings.laiziMode,
            value: _laiziEnabled,
            onChanged: (v) {
              setState(() => _laiziEnabled = v);
              _storage.setLaiziEnabled(v);
              _audio.playClick();
            },
          ),
          const Divider(color: AppColors.glassBorder, height: 1),
          _buildToggleRow(
            icon: Icons.volume_up,
            label: AppStrings.soundEffects,
            value: _soundEnabled,
            onChanged: (v) {
              setState(() => _soundEnabled = v);
              _audio.setSoundEnabled(v);
              _storage.setSoundEnabled(v);
              _audio.playClick();
            },
          ),
          const Divider(color: AppColors.glassBorder, height: 1),
          _buildToggleRow(
            icon: Icons.music_note,
            label: AppStrings.backgroundMusic,
            value: _bgmEnabled,
            onChanged: (v) {
              setState(() => _bgmEnabled = v);
              _audio.setBgmEnabled(v);
              _storage.setBgmEnabled(v);
              _audio.playClick();
            },
          ),
          const Divider(color: AppColors.glassBorder, height: 1),
          _buildToggleRow(
            icon: Icons.vibration,
            label: AppStrings.hapticFeedback,
            value: _hapticEnabled,
            onChanged: (v) {
              setState(() => _hapticEnabled = v);
              _haptic.setEnabled(v);
              _storage.setHapticEnabled(v);
              _haptic.buttonPress();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontFamily: AppStrings.fontFamily,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryButton,
            activeTrackColor: AppColors.primaryButton.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildResetSection() {
    return GlassmorphicPanel(
      borderRadius: AppDimensions.radiusMedium,
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        children: [
          const Text(
            '重置将清除所有游戏数据，包括欢乐豆余额、统计数据和成就进度。此操作不可撤销。',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontFamily: AppStrings.fontFamily,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          GameButton(
            text: '重置所有数据',
            onPressed: _showResetConfirmDialog,
            type: GameButtonType.danger,
            width: 200,
            icon: Icons.delete_forever,
          ),
        ],
      ),
    );
  }

  void _showResetConfirmDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2E3B2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        title: const Text(
          '确认重置',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontFamily: AppStrings.fontFamily,
          ),
        ),
        content: const Text(
          '确定要重置所有数据吗？这将清除你的欢乐豆、统计数据和成就进度，且无法恢复。',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontFamily: AppStrings.fontFamily,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '取消',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _storage.resetAll();
              _loadSettings();
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text(
              '确定重置',
              style: TextStyle(color: AppColors.dangerButton),
            ),
          ),
        ],
      ),
    );
  }
}

/// 难度选择按钮
class _DifficultyButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DifficultyButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDimensions.uiTransitionDuration,
        curve: AppCurves.uiTransition,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    AppColors.primaryButton,
                    Color(0xFFFFA000),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppDimensions.smallButtonRadius),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryButton
                : Colors.white.withOpacity(0.15),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.textDark : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontFamily: AppStrings.fontFamily,
            ),
          ),
        ),
      ),
    );
  }
}
