/// 游戏难度枚举
enum Difficulty { easy, normal, hard }

/// 难度枚举扩展
extension DifficultyExtension on Difficulty {
  /// 显示名称
  String get displayName {
    switch (this) {
      case Difficulty.easy:
        return '简单';
      case Difficulty.normal:
        return '普通';
      case Difficulty.hard:
        return '困难';
    }
  }

  /// 英文标识（用于存储）
  String get storageKey {
    switch (this) {
      case Difficulty.easy:
        return 'easy';
      case Difficulty.normal:
        return 'normal';
      case Difficulty.hard:
        return 'hard';
    }
  }

  /// 从字符串解析难度
  static Difficulty fromString(String key) {
    switch (key) {
      case 'easy':
        return Difficulty.easy;
      case 'hard':
        return Difficulty.hard;
      case 'normal':
      default:
        return Difficulty.normal;
    }
  }
}
