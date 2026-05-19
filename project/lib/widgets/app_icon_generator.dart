import 'dart:math' show Random;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// =============================================================================
// 应用图标绘制器 - 生成精美的圆角矩形游戏图标
// =============================================================================
// 深绿麂皮底 + 金色扑克牌元素 + "斗地主"文字
//
// 使用方式：
// ```dart
// final iconBytes = await AppIconGenerator.generateIcon(size: 1024);
// ```

class AppIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rRect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(size.width * 0.2),
    );

    // 背景 - 深绿渐变（模拟麂皮质感）
    final bgGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF2E7D32),
        const Color(0xFF1B5E20),
        const Color(0xFF154A1A),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    final bgPaint = Paint()
      ..shader = bgGradient.createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rRect, bgPaint);

    // 添加麂皮噪点纹理效果（使用小圆点模拟）
    final noisePaint = Paint()
      ..color = const Color(0x0AFFFFFF)
      ..style = PaintingStyle.fill;
    final random = Random(42); // 固定种子保证一致性
    for (int i = 0; i < 200; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final r = 0.5 + random.nextDouble() * 1.5;
      canvas.drawCircle(Offset(x, y), r, noisePaint);
    }

    // 内边框（高光效果）
    final innerRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 2, size.width - 4, size.height - 4),
      Radius.circular(size.width * 0.18),
    );
    final borderPaint = Paint()
      ..color = const Color(0x30FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(innerRRect, borderPaint);

    // 中央扑克牌元素
    final cardWidth = size.width * 0.45;
    final cardHeight = cardWidth * 1.4;
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.42),
        width: cardWidth,
        height: cardHeight,
      ),
      Radius.circular(cardWidth * 0.08),
    );

    // 牌的阴影
    final shadowPaint = Paint()
      ..color = const Color(0x40000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final shadowRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2 + 2, size.height * 0.42 + 2),
        width: cardWidth,
        height: cardHeight,
      ),
      Radius.circular(cardWidth * 0.08),
    );
    canvas.drawRRect(shadowRect, shadowPaint);

    // 牌的白色背景
    final cardBgPaint = Paint()
      ..color = const Color(0xFFF5F5F5)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(cardRect, cardBgPaint);

    // 牌的边框
    final cardBorderPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawRRect(cardRect, cardBorderPaint);

    // 左上角 A
    final aPainter = TextPainter(
      text: const TextSpan(
        text: 'A',
        style: TextStyle(
          color: Color(0xFF212121),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    aPainter.layout();
    aPainter.paint(
      canvas,
      Offset(
        size.width / 2 - cardWidth / 2 + 6,
        size.height * 0.42 - cardHeight / 2 + 4,
      ),
    );

    // 左上角黑桃小
    final smallSpadePainter = TextPainter(
      text: const TextSpan(
        text: '\u2660', // ♠
        style: TextStyle(
          color: Color(0xFF212121),
          fontSize: 14,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    smallSpadePainter.layout();
    smallSpadePainter.paint(
      canvas,
      Offset(
        size.width / 2 - cardWidth / 2 + 8,
        size.height * 0.42 - cardHeight / 2 + 22,
      ),
    );

    // 中央大黑桃
    final bigSpadePainter = TextPainter(
      text: const TextSpan(
        text: '\u2660', // ♠
        style: TextStyle(
          color: Color(0xFF212121),
          fontSize: 48,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    bigSpadePainter.layout();
    bigSpadePainter.paint(
      canvas,
      Offset(
        (size.width - bigSpadePainter.width) / 2,
        size.height * 0.42 - bigSpadePainter.height / 2,
      ),
    );

    // 底部文字 "斗地主"
    final titlePainter = TextPainter(
      text: const TextSpan(
        text: '\u6597\u5730\u4e3b', // 斗地主
        style: TextStyle(
          color: Color(0xFFFFD700),
          fontSize: 20,
          fontWeight: FontWeight.w400,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    titlePainter.layout();
    titlePainter.paint(
      canvas,
      Offset(
        (size.width - titlePainter.width) / 2,
        size.height * 0.78,
      ),
    );

    // 文字下方的装饰线
    final linePaint = Paint()
      ..color = const Color(0x60FFD700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.88),
      Offset(size.width * 0.75, size.height * 0.88),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// 应用图标生成工具
// =============================================================================
class AppIconGenerator {
  AppIconGenerator._();

  /// 生成图标为 PNG 字节
  ///
  /// [size] 图标尺寸（默认1024，用于应用商店）
  /// 返回 PNG 编码的字节数据
  static Future<Uint8List> generateIcon({int size = 1024}) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final painter = AppIconPainter();

    painter.paint(canvas, Size(size.toDouble(), size.toDouble()));

    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('Failed to encode icon as PNG');
    }

    return byteData.buffer.asUint8List();
  }

  /// 生成图标 Widget（用于预览）
  static Widget iconWidget({double size = 200}) {
    return CustomPaint(
      painter: AppIconPainter(),
      size: Size(size, size),
    );
  }
}
