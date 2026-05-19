import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// 毛玻璃面板组件
/// 半透明背景 + 模糊效果 + 白色半透明边框
class GlassmorphicPanel extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final double blurStrength;
  final Color backgroundColor;
  final Color borderColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BoxBorder? customBorder;
  final List<BoxShadow>? boxShadow;
  final Alignment? alignment;

  const GlassmorphicPanel({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 16.0,
    this.blurStrength = 15.0,
    this.backgroundColor = AppColors.glassBackground,
    this.borderColor = AppColors.glassBorder,
    this.padding = const EdgeInsets.all(AppDimensions.paddingMedium),
    this.margin,
    this.customBorder,
    this.boxShadow,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      alignment: alignment,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurStrength,
            sigmaY: blurStrength,
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: customBorder ?? Border.all(
                color: borderColor,
                width: 1.2,
              ),
              boxShadow: boxShadow ?? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  spreadRadius: -2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 简化版毛玻璃容器（无 ClipRRect，用于已有裁剪的上下文）
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blurStrength;
  final Color backgroundColor;
  final Color borderColor;
  final EdgeInsetsGeometry padding;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.blurStrength = 15.0,
    this.backgroundColor = AppColors.glassBackground,
    this.borderColor = AppColors.glassBorder,
    this.padding = const EdgeInsets.all(AppDimensions.paddingMedium),
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: blurStrength,
        sigmaY: blurStrength,
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor,
            width: 1.2,
          ),
        ),
        child: child,
      ),
    );
  }
}
