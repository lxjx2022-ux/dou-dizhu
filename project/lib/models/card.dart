import 'package:flutter/foundation.dart';

/// 花色枚举
/// - spade: 黑桃 ♠
/// - heart: 红桃 ♥
/// - club: 梅花 ♣
/// - diamond: 方块 ♦
/// - joker: 王牌（用于小王和大王）
enum Suit { spade, heart, club, diamond, joker }

/// 扑克牌模型
///
/// 牌力值(value)映射规则：
/// 3=1, 4=2, 5=3, 6=4, 7=5, 8=6, 9=7, 10=8,
/// J=9, Q=10, K=11, A=12, 2=13, 小王=14, 大王=15
class Card {
  /// 花色
  final Suit suit;

  /// 点数：1-13 对应 A-K，14=小王，15=大王
  final int rank;

  /// 是否为癞子牌（可变牌）
  final bool isLaiZi;

  const Card({
    required this.suit,
    required this.rank,
    this.isLaiZi = false,
  });

  /// 斗地主牌力值，用于排序和比较
  /// 3=1, 4=2, ..., 10=8, J=9, Q=10, K=11, A=12, 2=13, 小王=14, 大王=15
  int get value {
    if (rank >= 1 && rank <= 13) {
      // A=1 视为 14 的牌力（比K大），2=13 是最大的常规牌
      // 但在斗地主中：3最小，然后是4,5...Q,K,A,2，小王，大王
      // 所以映射为：3->1, 4->2, ..., 10->8, J->9, Q->10, K->11, A->12, 2->13
      if (rank == 1) return 12; // A
      if (rank == 2) return 13; // 2
      return rank - 2; // 3->1, 4->2, ..., 10->8, J->9, Q->10, K->11
    }
    if (rank == 14) return 14; // 小王
    if (rank == 15) return 15; // 大王
    return 0;
  }

  /// 显示名称
  String get displayName {
    if (rank == 14) return '小王';
    if (rank == 15) return '大王';
    switch (rank) {
      case 1:
        return 'A';
      case 11:
        return 'J';
      case 12:
        return 'Q';
      case 13:
        return 'K';
      default:
        return rank.toString();
    }
  }

  /// 花色符号
  String get suitSymbol {
    switch (suit) {
      case Suit.spade:
        return '♠';
      case Suit.heart:
        return '♥';
      case Suit.club:
        return '♣';
      case Suit.diamond:
        return '♦';
      case Suit.joker:
        return '🃏';
    }
  }

  /// 是否为红色牌（红桃、方块为红色）
  bool get isRed => suit == Suit.heart || suit == Suit.diamond || (suit == Suit.joker && rank == 15);

  /// 是否为黑色牌
  bool get isBlack => suit == Suit.spade || suit == Suit.club || (suit == Suit.joker && rank == 14);

  /// 是否为王牌
  bool get isJoker => rank == 14 || rank == 15;

  /// 是否为小王
  bool get isSmallJoker => rank == 14;

  /// 是否为大王
  bool get isBigJoker => rank == 15;

  /// 素材路径
  String get imagePath {
    if (rank == 14) return 'assets/cards/joker_black.png';
    if (rank == 15) return 'assets/cards/joker_red.png';
    return 'assets/cards/${rank}_${suit.name}.png';
  }

  /// 牌背素材路径
  static const String backImagePath = 'assets/cards/back.png';

  /// 复制并修改癞子状态
  Card copyWith({bool? isLaiZi}) {
    return Card(
      suit: suit,
      rank: rank,
      isLaiZi: isLaiZi ?? this.isLaiZi,
    );
  }

  @override
  String toString() {
    if (isJoker) return '${displayName}${isLaiZi ? "(癞)" : ""}';
    return '$suitSymbol$displayName${isLaiZi ? "(癞)" : ""}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Card &&
        other.suit == suit &&
        other.rank == rank &&
        other.isLaiZi == isLaiZi;
  }

  @override
  int get hashCode => Object.hash(suit, rank, isLaiZi);
}
