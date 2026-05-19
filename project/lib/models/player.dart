import 'card.dart';

/// 玩家角色
enum PlayerRole { landlord, farmer }

/// 玩家类型
enum PlayerType { human, ai }

/// 玩家模型
class Player {
  /// 玩家名称
  final String name;

  /// 玩家类型（人类/AI）
  final PlayerType type;

  /// 玩家角色（地主/农民），游戏开始前为null
  PlayerRole? role;

  /// 手牌列表
  List<Card> hand;

  /// 是否已叫地主
  bool hasCalledLandlord;

  /// 是否已抢地主
  bool hasGrabbedLandlord;

  /// 是否已加倍
  bool hasDoubled;

  /// 是否超级加倍
  bool hasSuperDoubled;

  /// 玩家索引 (0=玩家, 1=AI1, 2=AI2)
  final int index;

  Player({
    required this.name,
    required this.type,
    required this.index,
    this.role,
    List<Card>? hand,
    this.hasCalledLandlord = false,
    this.hasGrabbedLandlord = false,
    this.hasDoubled = false,
    this.hasSuperDoubled = false,
  }) : hand = hand ?? [];

  /// 当前手牌数量
  int get cardCount => hand.length;

  /// 是否为地主
  bool get isLandlord => role == PlayerRole.landlord;

  /// 是否为农民
  bool get isFarmer => role == PlayerRole.farmer;

  /// 是否为人类玩家
  bool get isHuman => type == PlayerType.human;

  /// 是否为AI
  bool get isAI => type == PlayerType.ai;

  /// 手牌按牌力值升序排序（小牌在前，大牌在后）
  void sortHand() {
    hand.sort((a, b) {
      // 先按牌力值排序
      int valueCompare = a.value.compareTo(b.value);
      if (valueCompare != 0) return valueCompare;
      // 牌力值相同则按花色排序
      return a.suit.index.compareTo(b.suit.index);
    });
  }

  /// 添加手牌
  void addCard(Card card) {
    hand.add(card);
  }

  /// 添加多张手牌
  void addCards(List<Card> cards) {
    hand.addAll(cards);
  }

  /// 移除手牌
  bool removeCard(Card card) {
    final index = hand.indexWhere((c) =>
        c.suit == card.suit &&
        c.rank == card.rank &&
        c.isLaiZi == card.isLaiZi);
    if (index >= 0) {
      hand.removeAt(index);
      return true;
    }
    return false;
  }

  /// 移除一组手牌
  bool removeCards(List<Card> cards) {
    for (final card in cards) {
      if (!removeCard(card)) return false;
    }
    return true;
  }

  /// 检查是否拥有指定卡牌（考虑癞子匹配）
  bool hasCard(Card target) {
    return hand.any((c) =>
        c.suit == target.suit &&
        c.rank == target.rank &&
        c.isLaiZi == target.isLaiZi);
  }

  /// 获取手牌的统计信息
  Map<String, dynamic> get stats => {
        'name': name,
        'cardCount': cardCount,
        'role': role?.name,
        'isLandlord': isLandlord,
      };

  /// 重置玩家状态（用于新一局）
  void reset() {
    role = null;
    hand.clear();
    hasCalledLandlord = false;
    hasGrabbedLandlord = false;
    hasDoubled = false;
    hasSuperDoubled = false;
  }

  @override
  String toString() {
    return 'Player{name: $name, type: $type, role: $role, cards: $cardCount}';
  }
}
