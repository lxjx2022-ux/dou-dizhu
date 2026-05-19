import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/extensions.dart';

/// 欢乐豆显示组件
/// 金币图标 + 数字，数字变化时有动画效果
class ChipDisplay extends StatefulWidget {
  final int amount;
  final double iconSize;
  final double fontSize;
  final bool showAnimation;

  const ChipDisplay({
    super.key,
    required this.amount,
    this.iconSize = 24.0,
    this.fontSize = 18.0,
    this.showAnimation = true,
  });

  @override
  State<ChipDisplay> createState() => _ChipDisplayState();
}

class _ChipDisplayState extends State<ChipDisplay>
    with SingleTickerProviderStateMixin {
  late int _displayAmount;
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _displayAmount = widget.amount;
    if (widget.showAnimation) {
      _pulseController = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      _pulseAnimation = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
        TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
      ]).animate(
        CurvedAnimation(parent: _pulseController!, curve: Curves.easeOut),
      );
    }
  }

  @override
  void didUpdateWidget(covariant ChipDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount) {
      _displayAmount = widget.amount;
      if (widget.showAnimation && _pulseController != null) {
        _pulseController!.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 金币图标
        _GoldCoinIcon(size: widget.iconSize),
        const SizedBox(width: 6),
        // 数字
        Text(
          _displayAmount.toFormattedString(),
          style: TextStyle(
            color: AppColors.textGold,
            fontSize: widget.fontSize,
            fontWeight: FontWeight.w600,
            fontFamily: AppStrings.fontFamily,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );

    if (widget.showAnimation && _pulseAnimation != null) {
      content = AnimatedBuilder(
        animation: _pulseAnimation!,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation!.value,
            child: child,
          );
        },
        child: content,
      );
    }

    return content;
  }
}

/// 金币图标 - CustomPaint 绘制
class _GoldCoinIcon extends StatelessWidget {
  final double size;

  const _GoldCoinIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoldCoinPainter(),
    );
  }
}

class _GoldCoinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 外圆
    final outerPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.3),
        radius: 0.8,
        colors: [
          Color(0xFFFFECB3),
          Color(0xFFFFD700),
          Color(0xFFFFA000),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, outerPaint);

    // 内圆边框
    final innerBorderPaint = Paint()
      ..color = const Color(0xFFFFA000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius * 0.7, innerBorderPaint);

    // 内圆背景
    final innerPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.2, -0.2),
        radius: 0.6,
        colors: [
          Color(0xFFFFF8E1),
          Color(0xFFFFD700),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.7));
    canvas.drawCircle(center, radius * 0.7, innerPaint);

    // ¥ 符号
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '\u00A5',
        style: TextStyle(
          color: Color(0xFFE65100),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
