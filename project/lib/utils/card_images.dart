import '../models/card.dart';

/// 扑克牌素材路径映射工具
class CardImages {
  CardImages._();

  /// 获取牌面图片路径
  static String getCardImage(Suit suit, int rank) {
    if (suit == Suit.joker) {
      return rank == 15
          ? 'assets/cards/joker_red.png'
          : 'assets/cards/joker_black.png';
    }
    final suitName = suit.toString().split('.').last;
    final rankName = _getRankName(rank);
    return 'assets/cards/${rankName}_$suitName.png';
  }

  /// 获取牌面图片路径（从PlayingCard）
  static String getCardImageFromCard(PlayingCard card) {
    return getCardImage(card.suit, card.rank);
  }

  /// 牌背图片
  static String get backImage => 'assets/cards/back.png';

  /// 透明占位图
  static String get emptySlot => 'assets/cards/empty.png';

  static String _getRankName(int rank) {
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
}
