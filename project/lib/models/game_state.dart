import 'card.dart';
import 'player.dart';
import 'hand_type.dart';
import 'difficulty.dart';

/// 游戏阶段枚举
enum GamePhase {
  dealing, // 发牌中
  callingLandlord, // 叫地主阶段
  playing, // 出牌阶段
  roundEnd, // 回合结束
  gameOver, // 游戏结束
}

/// 完整游戏状态模型
class GameState {
  /// 牌堆（剩余未发的牌）
  List<Card> deck;

  /// 三名玩家
  List<Player> players;

  /// 底牌（3张）
  List<Card> landlordCards;

  /// 最后出的牌
  List<Card>? lastPlayedCards;

  /// 最后出牌者索引 (0=玩家, 1=AI1, 2=AI2)
  int? lastPlayedBy;

  /// 最后出牌牌型结果
  HandResult? lastHand;

  /// 地主索引，-1 表示未定
  int landlordIndex;

  /// 当前回合玩家索引
  int currentTurn;

  /// 当前游戏阶段
  GamePhase phase;

  /// 当前倍率
  int multiplier;

  /// 基础分
  int baseScore;

  /// 当前难度
  Difficulty difficulty;

  /// 是否为癞子模式
  bool isLaiZiMode;

  /// 当前癞子牌（癞子模式下有效）
  Card? laiZiCard;

  /// 是否为春天
  bool isSpring;

  /// 连续跳过次数
  int passCount;

  /// 叫地主轮次
  int callRound;

  /// 总炸弹数（本局）
  int bombCount;

  /// 地主是否已出过牌（用于判断春天）
  bool landlordHasPlayed;

  /// 所有已出过的牌（用于记牌）
  List<Card> allPlayedCards;

  /// 当前回合出牌记录
  Map<int, List<Card>> roundPlays;

  /// 春天/反春标记
  /// 0 = 无, 1 = 春天, 2 = 反春
  int springType;

  /// 游戏是否已开始
  bool get isStarted => phase != GamePhase.dealing;

  /// 游戏是否已结束
  bool get isEnded => phase == GamePhase.gameOver;

  /// 当前活动玩家
  Player get currentPlayer => players[currentTurn];

  /// 地主玩家
  Player? get landlord =>
      landlordIndex >= 0 ? players[landlordIndex] : null;

  /// 农民玩家列表
  List<Player> get farmers =>
      players.where((p) => p.role == PlayerRole.farmer).toList();

  GameState({
    List<Card>? deck,
    List<Player>? players,
    List<Card>? landlordCards,
    this.lastPlayedCards,
    this.lastPlayedBy,
    this.lastHand,
    this.landlordIndex = -1,
    this.currentTurn = 0,
    this.phase = GamePhase.dealing,
    this.multiplier = 1,
    this.baseScore = 1,
    this.difficulty = Difficulty.normal,
    this.isLaiZiMode = false,
    this.laiZiCard,
    this.isSpring = false,
    this.passCount = 0,
    this.callRound = 0,
    this.bombCount = 0,
    this.landlordHasPlayed = false,
    List<Card>? allPlayedCards,
    Map<int, List<Card>>? roundPlays,
    this.springType = 0,
  })  : deck = deck ?? [],
        players = players ?? [],
        landlordCards = landlordCards ?? [],
        allPlayedCards = allPlayedCards ?? [],
        roundPlays = roundPlays ?? {0: [], 1: [], 2: []};

  /// 初始化新游戏状态
  factory GameState.createNew({
    required Difficulty difficulty,
    required bool isLaiZiMode,
  }) {
    return GameState(
      difficulty: difficulty,
      isLaiZiMode: isLaiZiMode,
      phase: GamePhase.dealing,
    );
  }

  /// 重置游戏状态（用于新一局）
  void resetForNewRound() {
    deck.clear();
    landlordCards.clear();
    lastPlayedCards = null;
    lastPlayedBy = null;
    lastHand = null;
    landlordIndex = -1;
    currentTurn = 0;
    phase = GamePhase.dealing;
    multiplier = 1;
    passCount = 0;
    callRound = 0;
    bombCount = 0;
    isSpring = false;
    landlordHasPlayed = false;
    laiZiCard = null;
    springType = 0;
    allPlayedCards.clear();
    roundPlays = {0: [], 1: [], 2: []};
    for (final player in players) {
      player.reset();
    }
  }

  /// 设置玩家列表
  void setPlayers(List<Player> newPlayers) {
    players.clear();
    players.addAll(newPlayers);
  }

  /// 记录出牌
  void recordPlay(int playerIndex, List<Card> cards) {
    roundPlays[playerIndex] = List.from(cards);
    allPlayedCards.addAll(cards);
    lastPlayedCards = List.from(cards);
    lastPlayedBy = playerIndex;

    // 如果地主出了牌，标记
    if (playerIndex == landlordIndex) {
      landlordHasPlayed = true;
    }
  }

  /// 记录跳过
  void recordPass() {
    passCount++;
  }

  /// 轮到下一个玩家
  void nextTurn() {
    currentTurn = (currentTurn + 1) % 3;
  }

  /// 检查是否是当前玩家的回合
  bool isPlayerTurn(int playerIndex) => currentTurn == playerIndex;

  /// 获取玩家当前手牌数
  int getPlayerCardCount(int playerIndex) {
    if (playerIndex < 0 || playerIndex >= players.length) return 0;
    return players[playerIndex].cardCount;
  }

  /// 获取当前倍率的描述
  String get multiplierDescription {
    List<String> parts = [];
    if (multiplier >= 2) parts.add('x$multiplier');
    if (isSpring) parts.add('春天');
    return parts.isEmpty ? 'x1' : parts.join(' ');
  }

  /// 序列化为JSON（用于存档）
  Map<String, dynamic> toJson() {
    return {
      'landlordIndex': landlordIndex,
      'currentTurn': currentTurn,
      'phase': phase.name,
      'multiplier': multiplier,
      'baseScore': baseScore,
      'difficulty': difficulty.storageKey,
      'isLaiZiMode': isLaiZiMode,
      'isSpring': isSpring,
      'passCount': passCount,
      'callRound': callRound,
      'bombCount': bombCount,
      'springType': springType,
    };
  }

  @override
  String toString() {
    return 'GameState{phase: ${phase.name}, turn: $currentTurn, '
        'landlord: $landlordIndex, multiplier: $multiplier}';
  }
}
