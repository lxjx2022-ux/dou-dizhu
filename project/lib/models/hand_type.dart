import 'card.dart';

/// 牌型枚举
enum HandType {
  single, // 单张
  pair, // 对子
  triple, // 三张
  tripleWithSingle, // 三带一
  tripleWithPair, // 三带二
  straight, // 顺子 (5+连续单张)
  doubleStraight, // 连对 (3+连续对子)
  tripleStraight, // 飞机 (2+连续三张)
  tripleStraightWithSingles, // 飞机带单
  tripleStraightWithPairs, // 飞机带对
  bomb, // 炸弹 (4张同点数)
  rocket, // 火箭 (大小王)
  quadWithTwoSingles, // 四带二
  quadWithTwoPairs, // 四带两对
  laiziBomb, // 软炸弹（含癞子的炸弹）
  invalid, // 非法牌型
}

/// 牌型结果
class HandResult {
  /// 牌型类型
  final HandType type;

  /// 主牌点数（牌力值），用于比较大小
  /// 对于顺子/连对/飞机，表示最小牌的牌力值
  final int mainRank;

  /// 长度（顺子的长度、连对的对数、飞机的三张组数）
  final int length;

  /// 参与构成牌型的卡牌（已排序）
  final List<Card> cards;

  /// 是否为癞子变牌手牌
  final bool isLaiZiHand;

  const HandResult({
    required this.type,
    required this.mainRank,
    required this.length,
    required this.cards,
    this.isLaiZiHand = false,
  });

  /// 是否为炸弹类牌型
  bool get isBomb => type == HandType.bomb || type == HandType.laiziBomb;

  /// 是否为火箭
  bool get isRocket => type == HandType.rocket;

  /// 是否为有效牌型
  bool get isValid => type != HandType.invalid;

  /// 能否压过对方牌型
  ///
  /// 规则：
  /// 1. 火箭最大，可以压任何牌
  /// 2. 炸弹可以压任何非炸弹/非火箭牌型
  /// 3. 炸弹之间比较主牌点数
  /// 4. 同类型牌型比较主牌点数（长度必须相同）
  bool canBeat(HandResult? other) {
    if (other == null || other.type == HandType.invalid) {
      // 对方没有出牌或非法，任何有效牌都可以出
      return isValid;
    }

    // 火箭最大
    if (isRocket) return true;
    if (other.isRocket) return false;

    // 炸弹可以压非炸弹
    if (isBomb && !other.isBomb) return true;
    if (!isBomb && other.isBomb) return false;

    // 炸弹之间比较
    if (isBomb && other.isBomb) {
      return mainRank > other.mainRank;
    }

    // 同类型比较：类型必须相同，长度必须相同，比较主牌点数
    if (type != other.type) return false;
    if (length != other.length) return false;

    return mainRank > other.mainRank;
  }

  @override
  String toString() {
    return 'HandResult{type: $type, mainRank: $mainRank, length: $length, cards: $cards, isLaiZi: $isLaiZiHand}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HandResult &&
        other.type == type &&
        other.mainRank == mainRank &&
        other.length == length;
  }

  @override
  int get hashCode => Object.hash(type, mainRank, length);
}
