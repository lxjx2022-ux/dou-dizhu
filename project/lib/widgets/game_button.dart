import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

/// 游戏主按钮
/// 大圆角、金黄主色 / 灰蓝次色 / 红色危险色
/// 按下动画（缩放0.95 + 微震动）
enum GameButtonType {
  primary,    // 金黄主色
  secondary,  // 灰蓝次色
  danger,     // 红色危险
  success,    // 绿色成功
}

class GameButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final GameButtonType type;
  final double? width;
  final double height;
  final IconData? icon;
  final bool isEnabled;

  const GameButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = GameButtonType.primary,
    this.width,
    this.height = AppDimensions.buttonHeight,
    this.icon,
    this.isEnabled = true,
  });

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDimensions.buttonPressDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.buttonPress),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _backgroundColor {
    if (!widget.isEnabled) return Colors.grey.shade600;
    switch (widget.type) {
      case GameButtonType.primary:
        return AppColors.primaryButton;
      case GameButtonType.secondary:
        return AppColors.secondaryButton;
      case GameButtonType.danger:
        return AppColors.dangerButton;
      case GameButtonType.success:
        return AppColors.successButton;
    }
  }

  Color get _textColor {
    switch (widget.type) {
      case GameButtonType.primary:
        return AppColors.textDark;
      default:
        return AppColors.textPrimary;
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isEnabled || widget.onPressed == null) return;
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.isEnabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _lightenColor(_backgroundColor, 0.08),
                    _backgroundColor,
                    _darkenColor(_backgroundColor, 0.1),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                          color: _backgroundColor.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: _backgroundColor.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: const Offset(0, 3),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                border: Border.all(
                  color: _isPressed
                      ? Colors.white.withOpacity(0.3)
                      : Colors.white.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: _textColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppStrings.fontFamily,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _lightenColor(Color color, double amount) {
    return Color.fromARGB(
      color.alpha,
      (color.red + (255 - color.red) * amount).toInt().clamp(0, 255),
      (color.green + (255 - color.green) * amount).toInt().clamp(0, 255),
      (color.blue + (255 - color.blue) * amount).toInt().clamp(0, 255),
    );
  }

  Color _darkenColor(Color color, double amount) {
    return Color.fromARGB(
      color.alpha,
      (color.red * (1 - amount)).toInt().clamp(0, 255),
      (color.green * (1 - amount)).toInt().clamp(0, 255),
      (color.blue * (1 - amount)).toInt().clamp(0, 255),
    );
  }
}

/// 小尺寸游戏按钮
class GameSmallButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final GameButtonType type;
  final IconData? icon;
  final bool isEnabled;

  const GameSmallButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = GameButtonType.secondary,
    this.icon,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GameButton(
      text: text,
      onPressed: onPressed,
      type: type,
      width: 100,
      height: AppDimensions.smallButtonHeight,
      icon: icon,
      isEnabled: isEnabled,
    );
  }
}
