import 'dart:math';

import '../models/card.dart';
import '../models/player.dart';
import '../models/game_state.dart';
import '../models/hand_type.dart';
import '../models/difficulty.dart';
import '../utils/extensions.dart';
import 'hand_evaluator.dart';
import 'scoring_engine.dart';
import 'ai_player.dart';

/// 核心游戏引擎
///
/// 控制完整的斗地主游戏流程：
/// - 洗牌、发牌
/// - 叫地主、抢地主
/// - 出牌、Pass
/// - 游戏结束判定
/// - 计分
class PokerEngine {
  /// 随机数生成器
  final Random _random = Random();

  /// 游戏状态
  final GameState _state;

  /// 状态变更监听器
  final List<void Function()> _listeners = [];

  /// 游戏日志
  final List<String> _gameLog = [];

  // ============ 构造函数 ============

  PokerEngine({
    Difficulty difficulty = Difficulty.normal,
    bool isLaiZiMode = false,
  }) : _state = GameState.createNew(
          difficulty: difficulty,
          isLaiZiMode: isLaiZiMode,
        );

  /// 从已有状态创建引擎
  PokerEngine.fromState(GameState state) : _state = state;

  // ============ 属性访问 ============

  GameState get state => _state;
  List<String> get gameLog => List.unmodifiable(_gameLog);
  GamePhase get currentPhase => _state.phase;

  // ============ 监听器 ============

  void addListener(void Function() listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  void _log(String message) {
    _gameLog.add(message);
  }

  // ============ 游戏初始化 ============

  /// 初始化玩家
  void initializePlayers(String playerName) {
    _state.players = [
      Player(name: playerName, type: PlayerType.human, index: 0),
      Player(name: 'AI-1', type: PlayerType.ai, index: 1),
      Player(name: 'AI-2', type: PlayerType.ai, index: 2),
    ];
  }

  // ============ 洗牌与发牌 ============

  /// 创建一副完整的54张牌
  List<Card> _createFullDeck() {
    final deck = <Card>[];

    // 52张标准牌
    for (final suit in [Suit.spade, Suit.heart, Suit.club, Suit.diamond]) {
      for (int rank = 1; rank <= 13; rank++) {
        deck.add(Card(suit: suit, rank: rank));
      }
    }

    // 2张王牌
    deck.add(Card(suit: Suit.joker, rank: 14)); // 小王
    deck.add(Card(suit: Suit.joker, rank: 15)); // 大王

    return deck;
  }

  /// Fisher-Yates 洗牌算法并发牌
  void shuffleAndDeal() {
    // 创建新牌组
    _state.deck = _createFullDeck();

    // Fisher-Yates 洗牌
    for (int i = _state.deck.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final temp = _state.deck[i];
      _state.deck[i] = _state.deck[j];
      _state.deck[j] = temp;
    }

    // 确保玩家列表已初始化
    if (_state.players.length != 3) {
      initializePlayers('玩家');
    }

    // 重置玩家手牌
    for (final player in _state.players) {
      player.hand.clear();
    }

    // 发牌：每人17张
    int cardIndex = 0;
    for (int round = 0; round < 17; round++) {
      for (int playerIdx = 0; playerIdx < 3; playerIdx++) {
        _state.players[playerIdx].addCard(_state.deck[cardIndex]);
        cardIndex++;
      }
    }

    // 每人手牌排序
    for (final player in _state.players) {
      player.sortHand();
    }

    // 留3张底牌
    _state.landlordCards = _state.deck.sublist(cardIndex, cardIndex + 3);

    // 记录日志
    _log('发牌完成，每人17张，留3张底牌');

    // 进入叫地主阶段
    _state.phase = GamePhase.callingLandlord;
    _state.currentTurn = 0; // 从玩家开始

    // 如果是癞子模式，确定癞子牌
    if (_state.isLaiZiMode) {
      determineLaiZi();
    }

    _notifyListeners();
  }

  /// 确定癞子牌
  /// 翻开牌堆第一张（底牌之前的最后一张发出的牌的背面/或发牌后翻开）
  void determineLaiZi() {
    if (_state.deck.isEmpty) return;

    // 随机选择一张作为癞子牌模板（按规则是翻开第一张牌）
    // 癞子牌是翻开的牌点数相同的所有4张牌
    final revealedCard = _state.deck[_random.nextInt(51)];
    _state.laiZiCard = Card(
      suit: revealedCard.suit,
      rank: revealedCard.rank,
    );

    // 标记手牌中的癞子牌
    for (final player in _state.players) {
      for (int i = 0; i < player.hand.length; i++) {
        if (player.hand[i].rank == _state.laiZiCard!.rank) {
          player.hand[i] = player.hand[i].copyWith(isLaiZi: true);
        }
      }
    }

    // 标记底牌中的癞子牌
    for (int i = 0; i < _state.landlordCards.length; i++) {
      if (_state.landlordCards[i].rank == _state.laiZiCard!.rank) {
        _state.landlordCards[i] = _state.landlordCards[i].copyWith(isLaiZi: true);
      }
    }

    _log('癞子牌确定: ${_state.laiZiCard!.displayName}');
  }

  // ============ 叫地主流程 ============

  /// 玩家叫地主
  ///
  /// 返回是否成功
  bool callLandlord(int playerIndex, bool call) {
    if (_state.phase != GamePhase.callingLandlord) return false;
    if (playerIndex < 0 || playerIndex >= 3) return false;
    if (_state.players[playerIndex].hasCalledLandlord) return false;

    _state.players[playerIndex].hasCalledLandlord = true;

    if (call) {
      _state.landlordIndex = playerIndex;
      _log('${_state.players[playerIndex].name} 叫了地主');
    } else {
      _log('${_state.players[playerIndex].name} 不叫');
    }

    // 检查叫地主阶段是否结束
    if (_checkCallPhaseEnd()) {
      _finalizeLandlord();
    } else {
      _state.nextTurn();
    }

    _notifyListeners();
    return true;
  }

  /// 玩家抢地主
  ///
  /// 返回是否成功
  bool grabLandlord(int playerIndex, bool grab) {
    if (_state.phase != GamePhase.callingLandlord) return false;
    if (playerIndex < 0 || playerIndex >= 3) return false;
    if (_state.players[playerIndex].hasGrabbedLandlord) return false;
    if (_state.landlordIndex < 0) return false; // 还没人叫，不能抢

    _state.players[playerIndex].hasGrabbedLandlord = true;

    if (grab) {
      _state.landlordIndex = playerIndex;
      _state.multiplier *= 2; // 抢地主倍率 x2
      _log('${_state.players[playerIndex].name} 抢了地主');
    } else {
      _log('${_state.players[playerIndex].name} 不抢');
    }

    if (_checkGrabPhaseEnd()) {
      _finalizeLandlord();
    } else {
      _state.nextTurn();
    }

    _notifyListeners();
    return true;
  }

  /// 检查叫地主阶段是否结束
  ///
  /// 条件：
  /// 1. 三个人都已经叫过（或不叫）
  /// 2. 有人叫了地主
  bool _checkCallPhaseEnd() {
    final allCalled = _state.players.every((p) => p.hasCalledLandlord);
    if (!allCalled) return false;

    // 如果有人叫了地主，叫地主阶段结束，进入抢地主
    if (_state.landlordIndex >= 0) {
      return false; // 进入抢地主阶段
    }

    // 都没叫，重新发牌
    return true; // 需要重新发牌
  }

  /// 检查抢地主阶段是否结束
  bool _checkGrabPhaseEnd() {
    final allResponded = _state.players.every((p) => p.hasGrabbedLandlord);
    return allResponded;
  }

  /// 最终确定地主
  void _finalizeLandlord() {
    // 如果没人叫地主，重新发牌
    if (_state.landlordIndex < 0) {
      _log('无人叫地主，重新发牌');
      _state.resetForNewRound();
      shuffleAndDeal();
      return;
    }

    // 设置地主角色
    final landlord = _state.players[_state.landlordIndex];
    landlord.role = PlayerRole.landlord;

    // 其他设为农民
    for (final player in _state.players) {
      if (player.index != _state.landlordIndex) {
        player.role = PlayerRole.farmer;
      }
    }

    // 地主获得底牌
    landlord.addCards(_state.landlordCards);
    landlord.sortHand();

    _log('${landlord.name} 成为地主，获得底牌');

    // 进入出牌阶段
    _state.phase = GamePhase.playing;
    _state.currentTurn = _state.landlordIndex; // 地主先出
    _state.passCount = 0;
    _state.lastPlayedCards = null;
    _state.lastPlayedBy = null;
    _state.lastHand = null;
    _state.roundPlays = {0: [], 1: [], 2: []};

    _notifyListeners();
  }

  // ============ AI 自动决策 ============

  /// AI 执行叫地主决策
  void aiCallLandlord(int playerIndex) {
    if (_state.phase != GamePhase.callingLandlord) return;
    if (playerIndex < 0 || playerIndex >= 3) return;

    final player = _state.players[playerIndex];
    if (player.hasCalledLandlord) return;

    final shouldCall = AIPlayer.decideCallLandlord(
      player,
      _state.landlordCards,
      _state.difficulty,
    );

    callLandlord(playerIndex, shouldCall);
  }

  /// AI 执行抢地主决策
  void aiGrabLandlord(int playerIndex) {
    if (_state.phase != GamePhase.callingLandlord) return;
    if (playerIndex < 0 || playerIndex >= 3) return;
    if (_state.landlordIndex < 0) return;

    final player = _state.players[playerIndex];
    if (player.hasGrabbedLandlord) return;

    // 如果已经是地主了，可以选择不抢
    if (player.index == _state.landlordIndex) {
      grabLandlord(playerIndex, false);
      return;
    }

    final shouldGrab = AIPlayer.decideGrabLandlord(
      player,
      _state.difficulty,
    );

    grabLandlord(playerIndex, shouldGrab);
  }

  /// AI 执行出牌决策
  List<Card>? aiPlayCards(int playerIndex) {
    if (_state.phase != GamePhase.playing) return null;
    if (playerIndex < 0 || playerIndex >= 3) return null;
    if (_state.currentTurn != playerIndex) return null;

    final player = _state.players[playerIndex];
    if (player.hand.isEmpty) return null;

    final play = AIPlayer.decidePlay(
      player,
      _state.lastHand,
      _state.difficulty,
      _state.allPlayedCards,
    );

    if (play != null) {
      return playCards(playerIndex, play);
    } else {
      pass(playerIndex);
      return null;
    }
  }

  // ============ 出牌流程 ============

  /// 玩家出牌
  ///
  /// 返回出牌牌型结果，null 表示出牌失败
  List<Card>? playCards(int playerIndex, List<Card> cards) {
    if (_state.phase != GamePhase.playing) return null;
    if (playerIndex < 0 || playerIndex >= 3) return null;
    if (_state.currentTurn != playerIndex) return null;
    if (cards.isEmpty) return null;

    final player = _state.players[playerIndex];

    // 检查玩家是否拥有这些牌
    for (final card in cards) {
      if (!player.hasCard(card)) {
        _log('${player.name} 尝试出未拥有的牌: $card');
        return null;
      }
    }

    // 评估牌型
    HandResult result;
    if (_state.isLaiZiMode && _state.laiZiCard != null) {
      result = HandEvaluator.evaluateWithLaiZi(cards, _state.laiZiCard!);
    } else {
      result = HandEvaluator.evaluate(cards);
    }

    // 检查牌型是否合法
    if (!result.isValid) {
      _log('${player.name} 出了非法牌型');
      return null;
    }

    // 检查是否能压过上一家
    if (_state.lastHand != null && !result.canBeat(_state.lastHand!)) {
      _log('${player.name} 的牌不能压过上家');
      return null;
    }

    // 移除手牌
    player.removeCards(cards);

    // 更新游戏状态
    _state.recordPlay(playerIndex, cards);
    _state.lastHand = result;
    _state.passCount = 0;

    // 检查是否为炸弹或火箭，增加倍率
    if (result.type == HandType.bomb || result.type == HandType.rocket) {
      _state.bombCount++;
      _state.multiplier *= 2;
      _log('${player.name} 出了炸弹！当前倍率: ${_state.multiplier}');
    } else if (result.type == HandType.laiziBomb) {
      _state.bombCount++;
      _state.multiplier *= 2;
      _log('${player.name} 出了癞子炸弹！当前倍率: ${_state.multiplier}');
    }

    _log('${player.name} 出了 ${result.type.name}: ${cards.map((c) => c.toString()).join(' ')}');

    // 检查游戏是否结束
    if (player.hand.isEmpty) {
      _handleGameEnd(playerIndex);
      return cards;
    }

    // 轮到下一位
    _state.nextTurn();
    _notifyListeners();
    return cards;
  }

  /// 玩家 Pass（不要）
  void pass(int playerIndex) {
    if (_state.phase != GamePhase.playing) return;
    if (playerIndex < 0 || playerIndex >= 3) return;
    if (_state.currentTurn != playerIndex) return;

    // 首家不能 Pass
    if (_state.lastHand == null || _state.lastPlayedBy == null) {
      return;
    }

    // 不能连续三个 Pass
    if (_state.passCount >= 2) {
      return;
    }

    _state.recordPass();
    _log('${_state.players[playerIndex].name} 不要');

    if (_state.passCount >= 2) {
      // 连续两人 Pass，回到出牌权给最后出牌者
      _state.lastHand = null;
      _state.currentTurn = _state.lastPlayedBy ?? _state.landlordIndex;
      _state.passCount = 0;
      _log('两轮不要，${_state.players[_state.currentTurn].name} 获得出牌权');
    } else {
      _state.nextTurn();
    }

    _notifyListeners();
  }

  // ============ 游戏结束 ============

  /// 处理游戏结束
  void _handleGameEnd(int winnerIndex) {
    _state.phase = GamePhase.roundEnd;

    final winner = _state.players[winnerIndex];
    final landlordWon = winner.isLandlord;

    _log('${winner.name} 出完所有手牌！');

    // 判断春天/反春
    _state.springType = ScoringEngine.determineSpringType(
      _state.landlordIndex,
      landlordWon,
      _state.roundPlays,
    );

    if (_state.springType == 1) {
      _state.isSpring = true;
      _state.multiplier *= 2;
      _log('春天！倍率翻倍');
    } else if (_state.springType == 2) {
      _state.isSpring = true;
      _state.multiplier *= 2;
      _log('反春！倍率翻倍');
    }

    // 计算得分
    final scores = ScoringEngine.calculateScoreDistribution(
      _state.baseScore,
      _state.multiplier,
      _state.landlordIndex,
      landlordWon,
    );

    // 应用得分
    for (int i = 0; i < 3; i++) {
      final score = scores[i] ?? 0;
      _log('${_state.players[i].name} 得分: $score');
    }

    _state.phase = GamePhase.gameOver;
    _notifyListeners();
  }

  /// 检查游戏是否结束
  bool checkGameEnd() {
    for (final player in _state.players) {
      if (player.hand.isEmpty) {
        return true;
      }
    }
    return false;
  }

  /// 检查是否为春天
  bool checkSpring() {
    return _state.springType == 1;
  }

  /// 检查是否为反春
  bool checkAntiSpring() {
    return _state.springType == 2;
  }

  // ============ 计分 ============

  /// 计算玩家得分变化
  /// 返回 Map<玩家索引, 得分变化>
  Map<int, int> calculateScoreChanges() {
    if (_state.phase != GamePhase.gameOver && _state.phase != GamePhase.roundEnd) {
      return {};
    }

    // 确定获胜方
    bool landlordWon = false;
    for (final player in _state.players) {
      if (player.hand.isEmpty) {
        landlordWon = player.isLandlord;
        break;
      }
    }

    return ScoringEngine.calculateScoreDistribution(
      _state.baseScore,
      _state.multiplier,
      _state.landlordIndex,
      landlordWon,
    );
  }

  /// 计算玩家是否获胜
  bool didPlayerWin(int playerIndex) {
    final scoreChanges = calculateScoreChanges();
    return (scoreChanges[playerIndex] ?? 0) > 0;
  }

  // ============ 重新开始 ============

  /// 重新开始新一局
  void startNewRound() {
    // 保存当前设置
    final difficulty = _state.difficulty;
    final isLaiZiMode = _state.isLaiZiMode;

    // 重置状态
    _state.resetForNewRound();
    _state.difficulty = difficulty;
    _state.isLaiZiMode = isLaiZiMode;

    _gameLog.clear();
    _log('开始新一局');

    // 重新发牌
    shuffleAndDeal();
  }

  /// 完全重置游戏
  void resetGame() {
    _state.resetForNewRound();
    _gameLog.clear();
    _notifyListeners();
  }

  // ============ 提示功能 ============

  /// 获取当前玩家出牌的提示
  List<Card>? getHint() {
    final player = _state.currentPlayer;
    if (!player.isHuman) return null;

    return HandEvaluator.getHint(
      player.hand,
      lastHand: _state.lastHand,
    );
  }

  /// 获取当前玩家所有合法的出牌
  List<List<Card>> getAllValidPlays() {
    final player = _state.currentPlayer;
    return HandEvaluator.getAllPossiblePlays(
      player.hand,
      lastHand: _state.lastHand,
    );
  }

  // ============ 快捷操作方法 ============

  /// 快速执行 AI 当前回合
  /// 返回是否执行了操作
  bool executeAITurn() {
    if (_state.phase != GamePhase.playing) return false;

    final currentPlayer = _state.currentPlayer;
    if (currentPlayer.isHuman) return false;

    aiPlayCards(currentPlayer.index);
    return true;
  }

  /// 检查当前是否是 AI 回合
  bool get isAITurn => _state.currentPlayer.isAI;

  /// 获取获胜者索引
  int? getWinnerIndex() {
    if (_state.phase != GamePhase.gameOver && _state.phase != GamePhase.roundEnd) {
      return null;
    }
    for (int i = 0; i < 3; i++) {
      if (_state.players[i].hand.isEmpty) {
        return i;
      }
    }
    return null;
  }

  /// 获取当前玩家的角色描述
  String getRoleDescription(int playerIndex) {
    if (playerIndex < 0 || playerIndex >= 3) return '未知';
    final player = _state.players[playerIndex];
    if (player.isLandlord) return '地主';
    if (player.isFarmer) return '农民';
    return '待定';
  }

  // ============ 统计信息 ============

  /// 获取当前对局的统计信息
  Map<String, dynamic> getGameStats() {
    return {
      'phase': _state.phase.name,
      'currentTurn': _state.currentTurn,
      'landlordIndex': _state.landlordIndex,
      'multiplier': _state.multiplier,
      'baseScore': _state.baseScore,
      'bombCount': _state.bombCount,
      'isSpring': _state.isSpring,
      'springType': _state.springType,
      'passCount': _state.passCount,
      'difficulty': _state.difficulty.name,
      'isLaiZiMode': _state.isLaiZiMode,
      'laiZiCard': _state.laiZiCard?.displayName,
      'playerCards': {
        for (final p in _state.players)
          p.name: p.cardCount,
      },
    };
  }
}
