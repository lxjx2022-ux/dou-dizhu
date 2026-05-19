import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// 炸弹特效组件
/// 屏幕震动效果 + 金色光晕扩散动画
/// 持续时间1200ms
class BombEffect extends StatefulWidget {
  final VoidCallback? onComplete;

  const BombEffect({
    super.key,
    this.onComplete,
  });

  @override
  State<BombEffect> createState() => _BombEffectState();
}

class _BombEffectState extends State<BombEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _textScaleAnimation;
  late Animation<double> _textOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDimensions.bombAnimationDuration,
      vsync: this,
    );

    // 光晕扩散 - 从中心向外
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.bomb),
    );

    // 震动效果
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: -0.8), weight: 10),
      TweenSequenceItem(tween: Tween(begin: -0.8, end: 0.6), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 0.6, end: -0.5), weight: 10),
      TweenSequenceItem(tween: Tween(begin: -0.5, end: 0.4), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 0.4, end: -0.3), weight: 10),
      TweenSequenceItem(tween: Tween(begin: -0.3, end: 0.2), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 0.2, end: -0.1), weight: 10),
      TweenSequenceItem(tween: Tween(begin: -0.1, end: 0.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 10),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // 文字放大
    _textScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.4), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 0.8, curve: Curves.easeOut),
    ));

    // 文字淡入淡出
    _textOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // 震动偏移
        final shakeX = _shakeAnimation.value * 15 * math.cos(_controller.value * 20);
        final shakeY = _shakeAnimation.value * 10 * math.sin(_controller.value * 15);

        return Transform.translate(
          offset: Offset(shakeX, shakeY),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 暗色遮罩
              Container(
                color: Colors.black.withOpacity(_glowAnimation.value * 0.3),
              ),

              // 金色光晕 - 多层
              Center(
                child: _buildGlowLayer(
                  size,
                  radius: size.width * _glowAnimation.value,
                  color: Colors.orange.withOpacity(0.3 * (1 - _glowAnimation.value)),
                ),
              ),
              Center(
                child: _buildGlowLayer(
                  size,
                  radius: size.width * 0.6 * _glowAnimation.value,
                  color: Colors.yellow.withOpacity(0.4 * (1 - _glowAnimation.value)),
                ),
              ),
              Center(
                child: _buildGlowLayer(
                  size,
                  radius: size.width * 0.3 * _glowAnimation.value,
                  color: Colors.white.withOpacity(0.3 * (1 - _glowAnimation.value)),
                ),
              ),

              // 爆炸闪光
              Center(
                child: Container(
                  width: 80 * _glowAnimation.value,
                  height: 80 * _glowAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.8 * (1 - _glowAnimation.value)),
                        Colors.yellow.withOpacity(0.4 * (1 - _glowAnimation.value)),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // "炸弹" 文字
              Center(
                child: Opacity(
                  opacity: _textOpacityAnimation.value,
                  child: Transform.scale(
                    scale: _textScaleAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\u{1F4A5}', // 爆炸emoji
                          style: TextStyle(
                            fontSize: 60,
                            shadows: [
                              Shadow(
                                color: Colors.orange.withOpacity(0.8),
                                blurRadius: 30,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '炸弹！',
                          style: TextStyle(
                            color: Colors.yellow,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppStrings.fontFamily,
                            shadows: [
                              Shadow(
                                color: Colors.orange.withOpacity(0.8),
                                blurRadius: 20,
                              ),
                              Shadow(
                                color: Colors.red.withOpacity(0.5),
                                blurRadius: 40,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlowLayer(Size size, {required double radius, required Color color}) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withOpacity(0),
          ],
        ),
      ),
    );
  }
}

/// 春天特效组件
class SpringEffect extends StatefulWidget {
  final bool isAntiSpring;
  final VoidCallback? onComplete;

  const SpringEffect({
    super.key,
    this.isAntiSpring = false,
    this.onComplete,
  });

  @override
  State<SpringEffect> createState() => _SpringEffectState();
}

class _SpringEffectState extends State<SpringEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _ringAnimation;
  late Animation<double> _textScaleAnimation;
  late Animation<double> _textOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDimensions.springAnimationDuration,
      vsync: this,
    );

    _ringAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.spring),
    );

    _textScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.2, end: 1.3), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.05), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.9, curve: Curves.easeOut),
    ));

    _textOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // 绿色光效扩散
            Center(
              child: _buildRing(
                size.width * _ringAnimation.value * 1.2,
                Colors.green.withOpacity(0.15 * (1 - _ringAnimation.value)),
              ),
            ),
            Center(
              child: _buildRing(
                size.width * _ringAnimation.value * 0.8,
                AppColors.tableGreenLight.withOpacity(0.2 * (1 - _ringAnimation.value)),
              ),
            ),
            Center(
              child: _buildRing(
                size.width * _ringAnimation.value * 0.4,
                Colors.white.withOpacity(0.15 * (1 - _ringAnimation.value)),
              ),
            ),

            // 文字
            Center(
              child: Opacity(
                opacity: _textOpacityAnimation.value,
                child: Transform.scale(
                  scale: _textScaleAnimation.value,
                  child: Text(
                    widget.isAntiSpring ? '反春！' : '春天！',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppStrings.fontFamily,
                      shadows: [
                        Shadow(
                          color: AppColors.success.withOpacity(0.8),
                          blurRadius: 30,
                        ),
                        Shadow(
                          color: Colors.green.withOpacity(0.6),
                          blurRadius: 60,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRing(double diameter, Color color) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withOpacity(0),
          ],
        ),
      ),
    );
  }
}
