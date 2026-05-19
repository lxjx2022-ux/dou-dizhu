import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/card.dart';
import '../utils/constants.dart';

/// 单张扑克牌组件
/// 使用 CustomPaint 绘制精美扑克牌，不依赖外部图片
class PlayingCardWidget extends StatelessWidget {
  final PlayingCard card;
  final bool faceUp;        // 是否正面朝上
  final bool isSelected;    // 是否选中（Y轴上移）
  final bool isLaiZi;       // 是否癞子（高亮边框）
  final double width;
  final double height;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;

  const PlayingCardWidget({
    super.key,
    required this.card,
    this.faceUp = true,
    this.isSelected = false,
    this.isLaiZi = false,
    this.width = AppDimensions.cardWidth,
    this.height = AppDimensions.cardHeight,
    this.onTap,
    this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      child: AnimatedContainer(
        duration: AppDimensions.selectAnimationDuration,
        curve: AppCurves.selectCard,
        transform: Matrix4.translationValues(
          0,
          isSelected ? -AppDimensions.cardLiftOffset : 0,
          0,
        ),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.cardCornerRadius),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? Colors.yellow.withOpacity(0.5)
                    : Colors.black.withOpacity(0.3),
                blurRadius: isSelected ? 8 : 4,
                offset: const Offset(0, 2),
                spreadRadius: isSelected ? 1 : 0,
              ),
            ],
            border: Border.all(
              color: isLaiZi
                  ? Colors.amber
                  : isSelected
                      ? AppColors.primaryButton.withOpacity(0.8)
                      : Colors.white.withOpacity(0.6),
              width: isLaiZi ? 2.5 : (isSelected ? 1.5 : 0.8),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.cardCornerRadius),
            child: faceUp
                ? _CardFace(card: card, width: width, height: height)
                : const _CardBack(),
          ),
        ),
      ),
    );
  }
}

/// 牌面绘制
class _CardFace extends StatelessWidget {
  final PlayingCard card;
  final double width;
  final double height;

  const _CardFace({
    required this.card,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _CardFacePainter(card: card),
      child: SizedBox(width: width, height: height),
    );
  }
}

/// 牌背绘制
class _CardBack extends StatelessWidget {
  const _CardBack();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(AppDimensions.cardWidth, AppDimensions.cardHeight),
      painter: _CardBackPainter(),
    );
  }
}

/// 牌面绘制器
class _CardFacePainter extends CustomPainter {
  final PlayingCard card;

  _CardFacePainter({required this.card});

  @override
  void paint(Canvas canvas, Size size) {
    // 背景 - 纯白
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(AppDimensions.cardCornerRadius),
      ),
      bgPaint,
    );

    // 内边框 - 微圆角
    final borderPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 2, size.width - 4, size.height - 4),
        Radius.circular(AppDimensions.cardCornerRadius - 2),
      ),
      borderPaint,
    );

    final textColor = card.cardColor;
    final isJoker = card.suit == Suit.joker;

    // 左上角 - 点数 + 花色
    _drawCornerText(
      canvas,
      size,
      text: card.displayName,
      color: textColor,
      isTopLeft: true,
    );

    // 右下角 - 倒置的点数 + 花色
    _drawCornerText(
      canvas,
      size,
      text: card.displayName,
      color: textColor,
      isTopLeft: false,
    );

    // 中央花色/图案
    if (isJoker) {
      _drawJokerCenter(canvas, size, card.rank == 15);
    } else {
      _drawSuitCenter(canvas, size, card.suitSymbol, textColor);
    }

    // 癞子标记
    if (card.isLaiZi) {
      _drawLaiZiMark(canvas, size);
    }
  }

  void _drawCornerText(
    Canvas canvas,
    Size size, {
    required String text,
    required Color color,
    required bool isTopLeft,
  }) {
    final textStyle = TextStyle(
      color: color,
      fontSize: size.width * 0.2,
      fontWeight: FontWeight.bold,
      fontFamily: 'NotoSansSC',
    );

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();

    final suitStyle = TextStyle(
      color: color,
      fontSize: size.width * 0.16,
    );
    final suitPainter = TextPainter(
      text: TextSpan(text: card.suitSymbol, style: suitStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    suitPainter.layout();

    if (isTopLeft) {
      textPainter.paint(canvas, Offset(4, 3));
      suitPainter.paint(canvas, Offset(4, 3 + textPainter.height - 2));
    } else {
      canvas.save();
      canvas.translate(size.width, size.height);
      canvas.rotate(3.14159);
      textPainter.paint(canvas, Offset(4, 3));
      suitPainter.paint(canvas, Offset(4, 3 + textPainter.height - 2));
      canvas.restore();
    }
  }

  void _drawSuitCenter(Canvas canvas, Size size, String symbol, Color color) {
    // 根据点数大小绘制不同数量的花色
    final suitStyle = TextStyle(
      color: color,
      fontSize: size.width * 0.32,
    );
    final suitPainter = TextPainter(
      text: TextSpan(text: symbol, style: suitStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    suitPainter.layout();

    final centerX = (size.width - suitPainter.width) / 2;
    final centerY = (size.height - suitPainter.height) / 2;

    suitPainter.paint(canvas, Offset(centerX, centerY));
  }

  void _drawJokerCenter(Canvas canvas, Size size, bool isBig) {
    // 绘制王冠或星形标记
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.18;

    final paint = Paint()
      ..color = isBig ? const Color(0xFFD32F2F) : const Color(0xFF212121)
      ..style = PaintingStyle.fill;

    // 绘制圆形背景
    canvas.drawCircle(center, radius + 4, paint);

    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, innerPaint);

    // 文字
    final textStyle = TextStyle(
      color: isBig ? const Color(0xFFD32F2F) : const Color(0xFF212121),
      fontSize: size.width * 0.2,
      fontWeight: FontWeight.bold,
      fontFamily: 'NotoSansSC',
    );
    final textPainter = TextPainter(
      text: TextSpan(text: isBig ? '大王' : '小王', style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  void _drawLaiZiMark(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width - 18, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, 18)
      ..close();
    canvas.drawPath(path, paint);

    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: size.width * 0.1,
      fontWeight: FontWeight.bold,
    );
    final textPainter = TextPainter(
      text: TextSpan(text: '赖', style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    canvas.save();
    canvas.translate(size.width - 12, 2);
    canvas.rotate(0.785); // 45度
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 牌背绘制器
class _CardBackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 深蓝绿色背景
    final bgPaint = Paint()
      ..color = const Color(0xFF1A3A5C)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(AppDimensions.cardCornerRadius),
      ),
      bgPaint,
    );

    // 内层边框
    final innerBorderPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4, 4, size.width - 8, size.height - 8),
        Radius.circular(AppDimensions.cardCornerRadius - 3),
      ),
      innerBorderPaint,
    );

    // 交叉图案 - 菱形网格
    final patternPaint = Paint()
      ..color = const Color(0xFF2A5A7C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final step = 8.0;
    for (double x = 0; x < size.width + size.height; x += step) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x - size.height, size.height),
        patternPaint,
      );
      canvas.drawLine(
        Offset(x - size.height, 0),
        Offset(x, size.height),
        patternPaint,
      );
    }

    // 中央圆形图案
    final center = Offset(size.width / 2, size.height / 2);
    final outerCirclePaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 14, outerCirclePaint);

    final innerCirclePaint = Paint()
      ..color = const Color(0xFF1A3A5C)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 10, innerCirclePaint);

    // 中央小花纹
    final starPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    _drawStar(canvas, center, 6, 5, starPaint);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, int points, Paint paint) {
    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * 3.14159 / points) - 3.14159 / 2;
      final r = i.isEven ? radius : radius * 0.4;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  static double cos(double angle) => math.cos(angle);
  static double sin(double angle) => math.sin(angle);

  @override
  bool shouldRepaint(covariant CustomPainter) => false;
}
