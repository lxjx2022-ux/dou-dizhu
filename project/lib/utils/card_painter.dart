import 'dart:math' show Random, pi;
import 'package:flutter/material.dart';
import '../models/card.dart' as card_model;

// =============================================================================
// 扑克牌绘制器 - 使用 Flutter CustomPainter 绘制精美拟物风格扑克牌
// =============================================================================

class CardPainter extends CustomPainter {
  final card_model.Card? card; // null = 牌背
  final bool faceUp;
  final bool isSelected;

  CardPainter({this.card, this.faceUp = true, this.isSelected = false});

  @override
  void paint(Canvas canvas, Size size) {
    if (!faceUp || card == null) {
      _drawBack(canvas, size);
    } else {
      _drawFace(canvas, size, card!);
    }
  }

  // =========================================================================
  // 牌背绘制
  // =========================================================================
  void _drawBack(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(6),
    );

    // 深蓝底色
    final bgPaint = Paint()
      ..color = const Color(0xFF1A3A5C)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rect, bgPaint);

    // 外边框 - 深色
    final borderPaint = Paint()
      ..color = const Color(0xFF0D2137)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rect, borderPaint);

    // 内边框 - 稍亮
    final innerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(3, 3, size.width - 6, size.height - 6),
      const Radius.circular(4),
    );
    final innerBorderPaint = Paint()
      ..color = const Color(0xFF2E5C8A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawRRect(innerRect, innerBorderPaint);

    // 中心菱形网格图案
    final patternPaint = Paint()
      ..color = const Color(0xFF244E78)
      ..style = PaintingStyle.fill;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (int i = -2; i <= 2; i++) {
      for (int j = -3; j <= 3; j++) {
        final dx = centerX + i * 12;
        final dy = centerY + j * 16 + (i % 2) * 8;
        final path = Path()
          ..moveTo(dx, dy - 5)
          ..lineTo(dx + 5, dy)
          ..lineTo(dx, dy + 5)
          ..lineTo(dx - 5, dy)
          ..close();
        canvas.drawPath(path, patternPaint);
      }
    }

    // 中心金色圆形Logo
    final logoPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), 10, logoPaint);

    // Logo 边框
    final logoBorderPaint = Paint()
      ..color = const Color(0xFF0D2137)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(centerX, centerY), 10, logoBorderPaint);

    // 内部小菱形装饰
    final innerDiamondPaint = Paint()
      ..color = const Color(0x80FFD700)
      ..style = PaintingStyle.fill;
    final diamondPath = Path()
      ..moveTo(centerX, centerY - 5)
      ..lineTo(centerX + 4, centerY)
      ..lineTo(centerX, centerY + 5)
      ..lineTo(centerX - 4, centerY)
      ..close();
    canvas.drawPath(diamondPath, innerDiamondPaint);
  }

  // =========================================================================
  // 牌面绘制
  // =========================================================================
  void _drawFace(Canvas canvas, Size size, card_model.Card card) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(6),
    );

    // 白色牌面背景
    final bgPaint = Paint()
      ..color = const Color(0xFFF5F5F5)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rect, bgPaint);

    // 微阴影效果
    final shadowPaint = Paint()
      ..color = const Color(0x1A000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawRRect(rect, shadowPaint);

    // 边框
    final borderPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawRRect(rect, borderPaint);

    if (card.isJoker) {
      _drawJoker(canvas, size, card);
    } else {
      _drawStandardCard(canvas, size, card);
    }
  }

  // =========================================================================
  // 王牌绘制
  // =========================================================================
  void _drawJoker(Canvas canvas, Size size, card_model.Card card) {
    final isRed = card.rank == 15; // 大王为红色
    final color = isRed ? const Color(0xFFD32F2F) : const Color(0xFF212121);

    // 顶部 "JOKER" 文字
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'JOKER',
        style: TextStyle(
          color: color,
          fontSize: size.width * 0.18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size.width - textPainter.width) / 2, size.height * 0.08),
    );

    // 中央皇冠/小丑图案
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    _drawJokerCrown(canvas, size, color);

    // 小王/大字
    final labelPainter = TextPainter(
      text: TextSpan(
        text: isRed ? '大' : '小',
        style: TextStyle(
          color: color,
          fontSize: size.width * 0.35,
          fontWeight: FontWeight.w300,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    labelPainter.layout();
    labelPainter.paint(
      canvas,
      Offset((size.width - labelPainter.width) / 2, centerY + 8),
    );

    // 底部倒置的 JOKER
    canvas.save();
    canvas.translate(size.width, size.height);
    canvas.rotate(pi);
    textPainter.paint(
      canvas,
      Offset((size.width - textPainter.width) / 2, size.height * 0.08),
    );
    canvas.restore();
  }

  // 绘制皇冠图案
  void _drawJokerCrown(Canvas canvas, Size size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final crownPath = Path()
      ..moveTo(centerX - 18, centerY - 2)
      ..lineTo(centerX - 12, centerY - 18)
      ..lineTo(centerX - 6, centerY - 8)
      ..lineTo(centerX, centerY - 22)
      ..lineTo(centerX + 6, centerY - 8)
      ..lineTo(centerX + 12, centerY - 18)
      ..lineTo(centerX + 18, centerY - 2)
      ..lineTo(centerX + 12, centerY + 6)
      ..lineTo(centerX - 12, centerY + 6)
      ..close();
    canvas.drawPath(crownPath, paint);

    // 皇冠上的宝石
    final gemPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX - 12, centerY - 18), 2, gemPaint);
    canvas.drawCircle(Offset(centerX, centerY - 22), 2.5, gemPaint);
    canvas.drawCircle(Offset(centerX + 12, centerY - 18), 2, gemPaint);
  }

  // =========================================================================
  // 标准牌绘制
  // =========================================================================
  void _drawStandardCard(Canvas canvas, Size size, card_model.Card card) {
    final color = card.isRed ? const Color(0xFFD32F2F) : const Color(0xFF212121);
    final suitSymbol = card.suitSymbol;
    final rankText = card.displayName;

    // 左上角点数
    final rankPainter = TextPainter(
      text: TextSpan(
        text: rankText,
        style: TextStyle(
          color: color,
          fontSize: size.width * 0.22,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    rankPainter.layout();
    rankPainter.paint(canvas, const Offset(4, 2));

    // 左上角花色
    final suitPainter = TextPainter(
      text: TextSpan(
        text: suitSymbol,
        style: TextStyle(
          color: color,
          fontSize: size.width * 0.18,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    suitPainter.layout();
    suitPainter.paint(canvas, Offset(4, rankPainter.height + 1));

    // 中心淡色花色背景（大）
    final centerSuitPainter = TextPainter(
      text: TextSpan(
        text: suitSymbol,
        style: TextStyle(
          color: color.withOpacity(0.12),
          fontSize: size.width * 0.6,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    centerSuitPainter.layout();
    centerSuitPainter.paint(
      canvas,
      Offset(
        (size.width - centerSuitPainter.width) / 2,
        (size.height - centerSuitPainter.height) / 2,
      ),
    );

    // 根据点数绘制中心图案
    _drawCenterPattern(canvas, size, card, color);

    // 右下角倒置的点数+花色
    canvas.save();
    canvas.translate(size.width, size.height);
    canvas.rotate(pi);
    rankPainter.paint(canvas, const Offset(4, 2));
    suitPainter.paint(canvas, Offset(4, rankPainter.height + 1));
    canvas.restore();
  }

  // =========================================================================
  // 中心图案绘制
  // =========================================================================
  void _drawCenterPattern(
    Canvas canvas,
    Size size,
    card_model.Card card,
    Color color,
  ) {
    switch (card.rank) {
      case 1: // A
        _drawAcePattern(canvas, size, card, color);
        break;
      case 13: // K - 皇冠
        _drawCrownPattern(canvas, size, color);
        break;
      case 12: // Q - 后冠
        _drawQueenCrownPattern(canvas, size, color);
        break;
      case 11: // J - 骑士头盔
        _drawJackHelmetPattern(canvas, size, color);
        break;
      default:
        // 数字牌：根据点数数量绘制花色图标排列
        _drawNumberPattern(canvas, size, card, color);
    }
  }

  // A 的特殊图案
  void _drawAcePattern(
    Canvas canvas,
    Size size,
    card_model.Card card,
    Color color,
  ) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // 大花色符号
    final symbolPainter = TextPainter(
      text: TextSpan(
        text: card.suitSymbol,
        style: TextStyle(
          color: color.withOpacity(0.8),
          fontSize: size.width * 0.35,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    symbolPainter.layout();
    symbolPainter.paint(
      canvas,
      Offset(
        centerX - symbolPainter.width / 2,
        centerY - symbolPainter.height / 2,
      ),
    );

    // "A" 字母装饰
    final aPainter = TextPainter(
      text: TextSpan(
        text: 'A',
        style: TextStyle(
          color: color,
          fontSize: size.width * 0.2,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    aPainter.layout();
    aPainter.paint(
      canvas,
      Offset(centerX - aPainter.width / 2, size.height * 0.15),
    );
  }

  // K 皇冠图案
  void _drawCrownPattern(Canvas canvas, Size size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.3, size.height * 0.45)
      ..lineTo(size.width * 0.35, size.height * 0.3)
      ..lineTo(size.width * 0.42, size.height * 0.38)
      ..lineTo(size.width * 0.5, size.height * 0.25)
      ..lineTo(size.width * 0.58, size.height * 0.38)
      ..lineTo(size.width * 0.65, size.height * 0.3)
      ..lineTo(size.width * 0.7, size.height * 0.45)
      ..lineTo(size.width * 0.65, size.height * 0.55)
      ..lineTo(size.width * 0.35, size.height * 0.55)
      ..close();
    canvas.drawPath(path, paint);

    // 宝石装饰
    final gemPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.3),
      2,
      gemPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.25),
      2.5,
      gemPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.65, size.height * 0.3),
      2,
      gemPaint,
    );

    // K 字母
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'K',
        style: TextStyle(
          color: color,
          fontSize: size.width * 0.3,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        size.height * 0.55,
      ),
    );
  }

  // Q 后冠图案
  void _drawQueenCrownPattern(Canvas canvas, Size size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 后冠（比皇冠更圆润）
    final path = Path()
      ..moveTo(size.width * 0.3, size.height * 0.45)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.25,
        size.width * 0.42,
        size.height * 0.35,
      )
      ..quadraticBezierTo(
        size.width * 0.46,
        size.height * 0.22,
        size.width * 0.5,
        size.height * 0.28,
      )
      ..quadraticBezierTo(
        size.width * 0.54,
        size.height * 0.22,
        size.width * 0.58,
        size.height * 0.35,
      )
      ..quadraticBezierTo(
        size.width * 0.65,
        size.height * 0.25,
        size.width * 0.7,
        size.height * 0.45,
      )
      ..lineTo(size.width * 0.65, size.height * 0.55)
      ..lineTo(size.width * 0.35, size.height * 0.55)
      ..close();
    canvas.drawPath(path, paint);

    // 顶部珍珠装饰
    final pearlPaint = Paint()
      ..color = const Color(0xFFFFF8E1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.42, size.height * 0.3),
      2.5,
      pearlPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.24),
      3,
      pearlPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.58, size.height * 0.3),
      2.5,
      pearlPaint,
    );

    // Q 字母
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Q',
        style: TextStyle(
          color: color,
          fontSize: size.width * 0.3,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        size.height * 0.55,
      ),
    );
  }

  // J 骑士头盔图案
  void _drawJackHelmetPattern(Canvas canvas, Size size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 骑士头盔
    final path = Path()
      ..moveTo(size.width * 0.35, size.height * 0.55)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.35,
        size.width * 0.5,
        size.height * 0.25,
      )
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.35,
        size.width * 0.65,
        size.height * 0.55,
      )
      ..lineTo(size.width * 0.6, size.height * 0.55)
      ..quadraticBezierTo(
        size.width * 0.6,
        size.height * 0.4,
        size.width * 0.5,
        size.height * 0.35,
      )
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.4,
        size.width * 0.4,
        size.height * 0.55,
      )
      ..close();
    canvas.drawPath(path, paint);

    // 面甲缝隙
    final slitPaint = Paint()
      ..color = const Color(0xFFF5F5F5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(size.width * 0.42, size.height * 0.42),
      Offset(size.width * 0.58, size.height * 0.42),
      slitPaint,
    );

    // J 字母
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'J',
        style: TextStyle(
          color: color,
          fontSize: size.width * 0.3,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        size.height * 0.55,
      ),
    );
  }

  // =========================================================================
  // 数字牌花色排列
  // =========================================================================
  void _drawNumberPattern(
    Canvas canvas,
    Size size,
    card_model.Card card,
    Color color,
  ) {
    final positions = _getNumberPatternPositions(card.rank);
    final symbolSize = size.width * 0.11;

    final symbolPainter = TextPainter(
      text: TextSpan(
        text: card.suitSymbol,
        style: TextStyle(
          color: color,
          fontSize: symbolSize,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    symbolPainter.layout();

    for (final pos in positions) {
      final x = size.width * pos.dx;
      final y = size.height * pos.dy;

      // 下半部分需要旋转180度
      if (pos.dy > 0.55) {
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(pi);
        symbolPainter.paint(
          canvas,
          Offset(-symbolPainter.width / 2, -symbolPainter.height / 2),
        );
        canvas.restore();
      } else {
        symbolPainter.paint(
          canvas,
          Offset(x - symbolPainter.width / 2, y - symbolPainter.height / 2),
        );
      }
    }
  }

  // 标准扑克牌花色图标排列位置
  List<Offset> _getNumberPatternPositions(int rank) {
    switch (rank) {
      case 2:
        return [
          const Offset(0.5, 0.25),
          const Offset(0.5, 0.75),
        ];
      case 3:
        return [
          const Offset(0.5, 0.25),
          const Offset(0.5, 0.5),
          const Offset(0.5, 0.75),
        ];
      case 4:
        return [
          const Offset(0.3, 0.25),
          const Offset(0.7, 0.25),
          const Offset(0.3, 0.75),
          const Offset(0.7, 0.75),
        ];
      case 5:
        return [
          const Offset(0.3, 0.25),
          const Offset(0.7, 0.25),
          const Offset(0.5, 0.5),
          const Offset(0.3, 0.75),
          const Offset(0.7, 0.75),
        ];
      case 6:
        return [
          const Offset(0.3, 0.25),
          const Offset(0.7, 0.25),
          const Offset(0.3, 0.5),
          const Offset(0.7, 0.5),
          const Offset(0.3, 0.75),
          const Offset(0.7, 0.75),
        ];
      case 7:
        return [
          const Offset(0.3, 0.2),
          const Offset(0.7, 0.2),
          const Offset(0.5, 0.35),
          const Offset(0.3, 0.5),
          const Offset(0.7, 0.5),
          const Offset(0.3, 0.8),
          const Offset(0.7, 0.8),
        ];
      case 8:
        return [
          const Offset(0.3, 0.2),
          const Offset(0.7, 0.2),
          const Offset(0.5, 0.35),
          const Offset(0.3, 0.5),
          const Offset(0.7, 0.5),
          const Offset(0.5, 0.65),
          const Offset(0.3, 0.8),
          const Offset(0.7, 0.8),
        ];
      case 9:
        return [
          const Offset(0.3, 0.2),
          const Offset(0.7, 0.2),
          const Offset(0.5, 0.3),
          const Offset(0.3, 0.45),
          const Offset(0.7, 0.45),
          const Offset(0.5, 0.55),
          const Offset(0.3, 0.7),
          const Offset(0.7, 0.7),
          const Offset(0.5, 0.8),
        ];
      case 10:
        return [
          const Offset(0.3, 0.18),
          const Offset(0.7, 0.18),
          const Offset(0.5, 0.28),
          const Offset(0.3, 0.42),
          const Offset(0.7, 0.42),
          const Offset(0.3, 0.58),
          const Offset(0.7, 0.58),
          const Offset(0.5, 0.72),
          const Offset(0.3, 0.82),
          const Offset(0.7, 0.82),
        ];
      default:
        return [const Offset(0.5, 0.5)];
    }
  }

  @override
  bool shouldRepaint(covariant CardPainter oldDelegate) {
    return oldDelegate.card != card ||
        oldDelegate.faceUp != faceUp ||
        oldDelegate.isSelected != isSelected;
  }
}

// =============================================================================
// 便捷 Widget 封装
// =============================================================================
class PlayingCardPainted extends StatelessWidget {
  final card_model.Card? card;
  final bool faceUp;
  final bool isSelected;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const PlayingCardPainted({
    super.key,
    this.card,
    this.faceUp = true,
    this.isSelected = false,
    this.width = 72,
    this.height = 100,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        transform: isSelected
            ? (Matrix4.translationValues(0, -16, 0)
              ..setEntry(3, 2, 0.001))
            : Matrix4.identity(),
        width: width,
        height: height,
        child: CustomPaint(
          painter: CardPainter(
            card: card,
            faceUp: faceUp,
            isSelected: isSelected,
          ),
          size: Size(width, height),
        ),
      ),
    );
  }
}

// =============================================================================
// 牌背 Widget（仅显示背面）
// =============================================================================
class CardBackWidget extends StatelessWidget {
  final double width;
  final double height;

  const CardBackWidget({
    super.key,
    this.width = 72,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: CardPainter(faceUp: false),
        size: Size(width, height),
      ),
    );
  }
}
