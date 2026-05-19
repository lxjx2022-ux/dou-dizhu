import 'package:flutter/material.dart';

// =============================================================================
// 默认头像组件 - 当没有图片资源时使用 Flutter 绘制
// =============================================================================

class PlaceholderAvatar extends StatelessWidget {
  final String name;
  final double size;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const PlaceholderAvatar({
    super.key,
    required this.name,
    this.size = 48,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? _generateColor(name);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              bgColor,
              Color.lerp(bgColor, Colors.black, 0.2) ?? bgColor,
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0] : '?',
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.4,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ),
    );
  }

  /// 根据名字生成一致的颜色
  Color _generateColor(String name) {
    if (name.isEmpty) return Colors.blue;

    // 预定义的颜色集
    final colors = [
      const Color(0xFF2196F3), // 蓝
      const Color(0xFF4CAF50), // 绿
      const Color(0xFFFF9800), // 橙
      const Color(0xFF9C27B0), // 紫
      const Color(0xFF00BCD4), // 青
      const Color(0xFFE91E63), // 粉红
      const Color(0xFF795548), // 棕
      const Color(0xFF607D8B), // 蓝灰
    ];

    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }

    return colors[hash.abs() % colors.length];
  }
}

// =============================================================================
// AI 头像组件
// =============================================================================

class AIAvatar extends StatelessWidget {
  final int aiIndex; // 1 或 2
  final double size;
  final VoidCallback? onTap;

  const AIAvatar({
    super.key,
    required this.aiIndex,
    this.size = 48,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final names = ['', 'AI-1', 'AI-2'];
    final colors = [
      Colors.blue,
      const Color(0xFFFF6B6B), // AI-1 珊瑚红
      const Color(0xFF4ECDC4), // AI-2 青绿
    ];

    return PlaceholderAvatar(
      name: names[aiIndex],
      size: size,
      backgroundColor: colors[aiIndex],
      onTap: onTap,
    );
  }
}

// =============================================================================
// 玩家头像组件（优先使用图片，没有则使用占位）
// =============================================================================

class PlayerAvatar extends StatelessWidget {
  final String? imagePath;
  final String name;
  final double size;
  final bool isCurrentPlayer;
  final VoidCallback? onTap;

  const PlayerAvatar({
    super.key,
    this.imagePath,
    required this.name,
    this.size = 48,
    this.isCurrentPlayer = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatar;

    if (imagePath != null && imagePath!.isNotEmpty) {
      // 使用图片头像
      avatar = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage(imagePath!),
            fit: BoxFit.cover,
          ),
          border: Border.all(
            color: isCurrentPlayer
                ? const Color(0xFFFFD700)
                : Colors.white.withOpacity(0.3),
            width: isCurrentPlayer ? 3 : 2,
          ),
        ),
      );
    } else {
      // 使用占位头像
      avatar = PlaceholderAvatar(
        name: name,
        size: size,
      );
    }

    if (isCurrentPlayer) {
      // 当前回合玩家添加发光效果
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: avatar,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: avatar,
    );
  }
}
