import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// 倒计时条组件
/// 从满到空的进度条，颜色从绿变黄变红
class TimerBar extends StatelessWidget {
  final int totalSeconds;
  final int remainingSeconds;
  final double height;
  final double? width;

  const TimerBar({
    super.key,
    this.totalSeconds = 20,
    required this.remainingSeconds,
    this.height = 6.0,
    this.width,
  });

  /// 根据剩余时间比例计算颜色
  Color _getColor(double ratio) {
    if (ratio > 0.6) {
      return AppColors.success; // 绿色
    } else if (ratio > 0.3) {
      return AppColors.warning; // 黄色
    } else {
      return AppColors.error; // 红色
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratio = (remainingSeconds / totalSeconds).clamp(0.0, 1.0);
    final barColor = _getColor(ratio);

    return Container(
      width: width ?? 120,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Stack(
        children: [
          // 进度填充
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            width: (width ?? 120) * ratio,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  barColor.withOpacity(0.7),
                  barColor,
                ],
              ),
              borderRadius: BorderRadius.circular(height / 2),
              boxShadow: ratio > 0
                  ? [
                      BoxShadow(
                        color: barColor.withOpacity(0.4),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// 带数字显示的倒计时器
class CountdownTimer extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final VoidCallback? onTimeout;

  const CountdownTimer({
    super.key,
    required this.remainingSeconds,
    this.totalSeconds = 20,
    this.onTimeout,
  });

  Color _getTextColor(double ratio) {
    if (ratio > 0.6) return AppColors.success;
    if (ratio > 0.3) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final ratio = (remainingSeconds / totalSeconds).clamp(0.0, 1.0);
    final textColor = _getTextColor(ratio);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 数字
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            color: textColor,
            fontSize: remainingSeconds <= 5 ? 22 : 18,
            fontWeight: remainingSeconds <= 5 ? FontWeight.bold : FontWeight.w500,
            fontFamily: AppStrings.fontFamily,
          ),
          child: Text('$remainingSeconds'),
        ),
        const SizedBox(height: 4),
        // 进度条
        TimerBar(
          totalSeconds: totalSeconds,
          remainingSeconds: remainingSeconds,
          width: 80,
          height: 4,
        ),
      ],
    );
  }
}
