import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 胜利彩纸特效
/// 从屏幕顶部随机飘落彩色纸片
/// 使用自定义粒子系统实现（不依赖外部包）
class ConfettiEffect extends StatefulWidget {
  final Duration duration;
  final VoidCallback? onComplete;
  final int particleCount;

  const ConfettiEffect({
    super.key,
    this.duration = const Duration(milliseconds: 3000),
    this.onComplete,
    this.particleCount = 80,
  });

  @override
  State<ConfettiEffect> createState() => _ConfettiEffectState();
}

class _ConfettiEffectState extends State<ConfettiEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // 生成随机粒子
    final random = math.Random();
    _particles = List.generate(widget.particleCount, (index) {
      return ConfettiParticle(
        x: random.nextDouble(), // 0~1 相对位置
        size: 6.0 + random.nextDouble() * 10.0,
        color: _confettiColors[random.nextInt(_confettiColors.length)],
        speed: 0.3 + random.nextDouble() * 0.7,
        wobbleSpeed: 1.0 + random.nextDouble() * 3.0,
        wobbleAmount: 5.0 + random.nextDouble() * 15.0,
        rotationSpeed: random.nextDouble() * 4.0 - 2.0,
        shape: random.nextBool()
            ? ConfettiShape.rectangle
            : ConfettiShape.circle,
        delay: random.nextDouble() * 0.5,
      );
    });

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
          children: _particles.map((particle) {
            final adjustedProgress =
                ((particle.delay + _controller.value) / (1 + particle.delay))
                    .clamp(0.0, 1.0);

            final x = particle.x * size.width +
                math.sin(adjustedProgress * particle.wobbleSpeed * math.pi * 4) *
                    particle.wobbleAmount;
            final y = -20 + adjustedProgress * (size.height + 60);
            final rotation =
                adjustedProgress * particle.rotationSpeed * math.pi * 4;
            final opacity = adjustedProgress < 0.8
                ? 1.0
                : (1.0 - adjustedProgress) / 0.2;

            return Positioned(
              left: x,
              top: y,
              child: Opacity(
                opacity: opacity,
                child: Transform.rotate(
                  angle: rotation,
                  child: _buildParticle(particle),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildParticle(ConfettiParticle particle) {
    if (particle.shape == ConfettiShape.circle) {
      return Container(
        width: particle.size,
        height: particle.size,
        decoration: BoxDecoration(
          color: particle.color,
          shape: BoxShape.circle,
        ),
      );
    } else {
      return Container(
        width: particle.size * 0.6,
        height: particle.size,
        decoration: BoxDecoration(
          color: particle.color,
          borderRadius: BorderRadius.circular(1),
        ),
      );
    }
  }
}

enum ConfettiShape {
  rectangle,
  circle,
}

class ConfettiParticle {
  final double x;
  final double size;
  final Color color;
  final double speed;
  final double wobbleSpeed;
  final double wobbleAmount;
  final double rotationSpeed;
  final ConfettiShape shape;
  final double delay;

  ConfettiParticle({
    required this.x,
    required this.size,
    required this.color,
    required this.speed,
    required this.wobbleSpeed,
    required this.wobbleAmount,
    required this.rotationSpeed,
    required this.shape,
    required this.delay,
  });
}

const List<Color> _confettiColors = [
  Color(0xFFFF6B6B), // 红
  Color(0xFF4ECDC4), // 青
  Color(0xFF45B7D1), // 蓝
  Color(0xFF96CEB4), // 绿
  Color(0xFFFFEEAD), // 黄
  Color(0xFFD4A5A5), // 粉
  Color(0xFF9B59B6), // 紫
  Color(0xFF3498DB), // 深蓝
  Color(0xFF1ABC9C), // 翡翠
  Color(0xFFF1C40F), // 金黄
];

/// 使用 confetti 包的包装器（如果可用）
/// 如果 confetti 包不可用，回退到自定义实现
class ConfettiWrapper extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback? onComplete;

  const ConfettiWrapper({
    super.key,
    this.isPlaying = false,
    this.onComplete,
  });

  @override
  State<ConfettiWrapper> createState() => _ConfettiWrapperState();
}

class _ConfettiWrapperState extends State<ConfettiWrapper> {
  bool _showing = false;

  @override
  void didUpdateWidget(covariant ConfettiWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      setState(() => _showing = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_showing) return const SizedBox.shrink();

    return ConfettiEffect(
      duration: const Duration(milliseconds: 3000),
      onComplete: () {
        setState(() => _showing = false);
        widget.onComplete?.call();
      },
    );
  }
}
