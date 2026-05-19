import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// 牌桌背景组件
/// 提供深绿色渐变背景（模拟麂皮质感）+ 中央区域高亮
class PokerTable extends StatelessWidget {
  final Widget? child;

  const PokerTable({
    super.key,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        // 深绿色径向渐变，模拟牌桌中央高亮
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.85,
          colors: [
            AppColors.tableCenter,
            AppColors.tableFelt,
            AppColors.tableGreen,
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 麂皮质感纹理层 - 使用网格图案模拟
          Opacity(
            opacity: 0.04,
            child: CustomPaint(
              painter: _FeltTexturePainter(),
              size: Size.infinite,
            ),
          ),

          // 中央高光椭圆
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.55,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.5,
                  colors: [
                    AppColors.tableGreenLight.withOpacity(0.15),
                    AppColors.tableGreenLight.withOpacity(0.0),
                  ],
                ),
                borderRadius: BorderRadius.circular(200),
              ),
            ),
          ),

          // 桌面边缘阴影
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.tableEdge.withOpacity(0.5),
                width: 12,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),

          // 子内容
          if (child != null) child!,
        ],
      ),
    );
  }
}

/// 麂皮纹理绘制器
class _FeltTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.5;

    // 绘制随机短线条模拟麂皮纹理
    final random = _SeededRandom(42);
    for (int i = 0; i < 2000; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final length = 3 + random.nextDouble() * 8;
      final angle = random.nextDouble() * 3.14159 * 2;

      canvas.drawLine(
        Offset(x, y),
        Offset(x + length * math.cos(angle), y + length * math.sin(angle)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 确定性随机数生成器（保证纹理一致）
class _SeededRandom {
  int _seed;
  _SeededRandom(this._seed);

  double nextDouble() {
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    return _seed / 0x7fffffff;
  }
}


