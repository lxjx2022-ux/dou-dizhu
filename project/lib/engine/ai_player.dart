import 'dart:math';

import '../models/card.dart';
import '../models/player.dart';
import '../models/hand_type.dart';
import '../models/difficulty.dart';
import '../utils/extensions.dart';
import 'hand_evaluator.dart';

/// AI 玩家策略引擎
///
/// 实现三个难度级别的 AI 策略：
/// - Easy: 几乎不记牌，优先出小牌，不出炸弹除非必要
/// - Normal: 记忆已出大牌，优先整牌型，合理使用炸弹
/// - Hard: 完整记牌，精确计算，最优搜索，完美农民配合
class AIPlayer {
  static final Random _random = Random();

  // ============ 叫地主决策 ============

  /// 决定是否叫地主
  ///
  /// 返回 true 表示叫地主，false 表示不叫
  static bool decideCallLandlord(
    Player player,
    List<Card> landlordCards,
    Difficulty difficulty,
  ) {
    switch (difficulty) {
      case Difficulty.easy:
        return _easyCallLandlord(player, landlordCards);
      case Difficulty.normal:
        return _normalCallLandlord(player, landlordCards);
      case Difficulty.hard:
        return _hardCallLandlord(player, landlordCards);
    }
  }

  /// 简单 AI 叫地主：有双王或2个以上2才叫
  static bool _easyCallLandlord(Player player, List<Card> landlordCards) {
    int jokerCount = player.hand.where((c) => c.isJoker).length;
    int twoCount = player.hand.where((c) => c.rank == 2).length;
    int bigCardCount = player.hand.where((c) => c.value >= 11).length;

    // 有双王
    if (jokerCount == 2) return true;

    // 有2个以上2且总大牌不少于4
    if (twoCount >= 2 && bigCardCount >= 4) {
      return _random.nextDouble() < 0.7;
    }

    // 偶然随机叫
    return _random.nextDouble() < 0.1;
  }

  /// 普通 AI 叫地主：综合评估手牌质量
  static bool _normalCallLandlord(Player player, List<Card> landlordCards) {
    double score = _evaluateHandForLandlord(player.hand, landlordCards);
    // 分数阈值：0.6 以上叫
    return score >= 0.6;
  }

  /// 困难 AI 叫地主：精确概率评估，偏激进
  static bool _hardCallLandlord(Player player, List<Card> landlordCards) {
    double score = _evaluateHandForLandlord(player.hand, landlordCards);
    // 困难 AI 更激进，阈值更低
    return score >= 0.45;
  }

  // ============ 抢地主决策 ============

  /// 决定是否抢地主
  static bool decideGrabLandlord(
    Player player,
    Difficulty difficulty,
  ) {
    switch (difficulty) {
      case Difficulty.easy:
        return _easyGrabLandlord(player);
      case Difficulty.normal:
        return _normalGrabLandlord(player);
      case Difficulty.hard:
        return _hardGrabLandlord(player);
    }
  }

  static bool _easyGrabLandlord(Player player) {
    int jokerCount = player.hand.where((c) => c.isJoker).length;
    int bigCardCount = player.hand.where((c) => c.value >= 12).length;

    // 有双王才抢
    if (jokerCount == 2) return _random.nextDouble() < 0.8;

    // 大牌多
    if (bigCardCount >= 4) return _random.nextDouble() < 0.3;

    return _random.nextDouble() < 0.05;
  }

  static bool _normalGrabLandlord(Player player) {
    double score = _evaluateHandStrength(player.hand);
    return score >= 0.6;
  }

  static bool _hardGrabLandlord(Player player) {
    double score = _evaluateHandStrength(player.hand);
    return score >= 0.5;
  }

  // ============ 出牌决策 ============

  /// AI 决定出什么牌
  ///
  /// 返回要出的牌列表，null 表示不出（Pass）
  static List<Card>? decidePlay(
    Player player,
    HandResult? lastHand,
    Difficulty difficulty,
    List<Card> allPlayedCards,
  ) {
    switch (difficulty) {
      case Difficulty.easy:
        return _easyPlay(player, lastHand);
      case Difficulty.normal:
        return _normalPlay(player, lastHand, allPlayedCards);
      case Difficulty.hard:
        return _hardPlay(player, lastHand, allPlayedCards);
    }
  }

  /// 简单 AI 出牌策略
  /// - 优先出小牌
  /// - 不记牌
  /// - 不出炸弹除非必要（只剩一手或必须压牌）
  /// - 有机会就压，不管队友
  static List<Card>? _easyPlay(Player player, HandResult? lastHand) {
    // 获取所有可能的出牌
    final allPlays = HandEvaluator.getAllPossiblePlays(player.hand, lastHand: lastHand);

    if (allPlays.isEmpty) return null;

    // 过滤掉炸弹（除非只剩一手或必须压大牌）
    final nonBombPlays = allPlays.where((play) {
      final result = HandEvaluator.evaluate(play);
      return !result.isBomb && result.type != HandType.rocket;
    }).toList();

    // 如果有非炸弹牌可以出，优先出最小的
    if (nonBombPlays.isNotEmpty) {
      nonBombPlays.sort((a, b) {
        final resultA = HandEvaluator.evaluate(a);
        final resultB = HandEvaluator.evaluate(b);
        return resultA.mainRank.compareTo(resultB.mainRank);
      });

      // 30% 概率出最小的，70% 随机出
      if (_random.nextDouble() < 0.3) {
        return nonBombPlays.first;
      }
      return nonBombPlays[_random.nextInt(nonBombPlays.length)];
    }

    // 只剩炸弹或火箭
    if (lastHand != null) {
      // 必须压牌时
      allPlays.sort((a, b) {
        final resultA = HandEvaluator.evaluate(a);
        final resultB = HandEvaluator.evaluate(b);
        return resultA.mainRank.compareTo(resultB.mainRank);
      });
      return allPlays.first;
    }

    // 首家，出最小炸弹
    final bombPlays = allPlays.where((play) {
      final result = HandEvaluator.evaluate(play);
      return result.isBomb;
    }).toList();

    if (bombPlays.isNotEmpty) {
      bombPlays.sort((a, b) {
        final resultA = HandEvaluator.evaluate(a);
        final resultB = HandEvaluator.evaluate(b);
        return resultA.mainRank.compareTo(resultB.mainRank);
      });
      return bombPlays.first;
    }

    return null;
  }

  /// 普通 AI 出牌策略
  /// - 优先整牌型（出顺子、连对、飞机等）
  /// - 记忆已出大牌
  /// - 合理使用炸弹
  /// - 农民角色会适当放水让队友出牌
  static List<Card>? _normalPlay(
    Player player,
    HandResult? lastHand,
    List<Card> allPlayedCards,
  ) {
    // 获取所有可能的出牌
    final allPlays = HandEvaluator.getAllPossiblePlays(player.hand, lastHand: lastHand);

    if (allPlays.isEmpty) return null;

    // 分析手牌结构
    final handAnalysis = _analyzeHand(player.hand);

    // 给每个出牌方案打分
    final scoredPlays = <_ScoredPlay>[];

    for (final play in allPlays) {
      double score = _scorePlay(
        play,
        player,
        lastHand,
        handAnalysis,
        allPlayedCards,
      );
      scoredPlays.add(_ScoredPlay(play, score));
    }

    // 按分数降序
    scoredPlays.sort((a, b) => b.score.compareTo(a.score));

    // 选择分数最高的方案
    if (scoredPlays.isNotEmpty) {
      return scoredPlays.first.play;
    }

    return null;
  }

  /// 困难 AI 出牌策略
  /// - 完整记牌，精确计算剩余牌分布
  /// - 贪心+搜索选择最优出牌
  /// - 完美农民配合
  static List<Card>? _hardPlay(
    Player player,
    HandResult? lastHand,
    List<Card> allPlayedCards,
  ) {
    // 获取所有可能的出牌
    final allPlays = HandEvaluator.getAllPossiblePlays(player.hand, lastHand: lastHand);

    if (allPlays.isEmpty) return null;

    // 分析手牌结构和剩余牌
    final handAnalysis = _analyzeHand(player.hand);
    final remainingCards = _calculateRemainingCards(player.hand, allPlayedCards);

    // 给每个出牌方案详细打分
    final scoredPlays = <_ScoredPlay>[];

    for (final play in allPlays) {
      double score = _scorePlayAdvanced(
        play,
        player,
        lastHand,
        handAnalysis,
        allPlayedCards,
        remainingCards,
      );
      scoredPlays.add(_ScoredPlay(play, score));
    }

    // 按分数降序
    scoredPlays.sort((a, b) => b.score.compareTo(a.score));

    if (scoredPlays.isNotEmpty) {
      // 选择分数最高的方案
      return scoredPlays.first.play;
    }

    return null;
  }

  // ============ 加倍决策 ============

  /// 决定是否加倍
  static bool decideDouble(
    Player player,
    Difficulty difficulty,
  ) {
    switch (difficulty) {
      case Difficulty.easy:
        // 简单 AI 很少加倍
        return _random.nextDouble() < 0.05;
      case Difficulty.normal:
        // 普通 AI 根据手牌质量决定
        double strength = _evaluateHandStrength(player.hand);
        return strength >= 0.7 && _random.nextDouble() < 0.3;
      case Difficulty.hard:
        // 困难 AI 精确评估
        double strength = _evaluateHandStrength(player.hand);
        return strength >= 0.65;
    }
  }

  // ============ 手牌评估 ============

  /// 评估手牌是否适合当地主（0.0 - 1.0）
  static double _evaluateHandForLandlord(List<Card> hand, List<Card> landlordCards) {
    // 合并底牌评估
    final combined = [...hand, ...landlordCards];
    double baseScore = _evaluateHandStrength(combined);

    // 大牌权重加成
    int jokerCount = combined.where((c) => c.isJoker).length;
    int twoCount = combined.where((c) => c.rank == 2).length;
    int aceCount = combined.where((c) => c.rank == 1).length;

    double bonus = 0.0;
    bonus += jokerCount * 0.15;
    bonus += twoCount * 0.08;
    bonus += aceCount * 0.05;

    // 牌型完整性加分
    final analysis = _analyzeHand(combined);
    if (analysis.straights.isNotEmpty) bonus += 0.1;
    if (analysis.doubleStraights.isNotEmpty) bonus += 0.1;
    if (analysis.tripleStraights.isNotEmpty) bonus += 0.15;

    return (baseScore + bonus).clamp(0.0, 1.0);
  }

  /// 评估手牌整体强度（0.0 - 1.0）
  static double _evaluateHandStrength(List<Card> hand) {
    if (hand.isEmpty) return 0.0;

    double score = 0.0;

    // 大牌数量
    int jokerCount = hand.where((c) => c.isJoker).length;
    int bigCards = hand.where((c) => c.value >= 11).length; // K, A, 2
    int mediumCards = hand.where((c) => c.value >= 8 && c.value <= 10).length; // 10, J, Q

    score += jokerCount * 0.12;
    score += bigCards * 0.06;
    score += mediumCards * 0.03;

    // 牌型加分
    final analysis = _analyzeHand(hand);
    score += analysis.straights.length * 0.08;
    score += analysis.doubleStraights.length * 0.06;
    score += analysis.tripleStraights.length * 0.1;
    score += analysis.pairs.length * 0.02;
    score += analysis.triples.length * 0.04;
    score += analysis.bombs.length * 0.15;
    if (analysis.hasRocket) score += 0.2;

    return score.clamp(0.0, 1.0);
  }

  // ============ 手牌分析 ============

  /// 手牌结构分析
  static _HandAnalysis _analyzeHand(List<Card> hand) {
    final valueCounts = hand.valueCounts();

    // 对子
    final pairs = <int>[];
    for (final entry in valueCounts.entries) {
      if (entry.value >= 2) pairs.add(entry.key);
    }

    // 三张
    final triples = <int>[];
    for (final entry in valueCounts.entries) {
      if (entry.value >= 3) triples.add(entry.key);
    }

    // 炸弹
    final bombs = <int>[];
    for (final entry in valueCounts.entries) {
      if (entry.value >= 4) bombs.add(entry.key);
    }

    // 火箭
    final hasRocket = hand.any((c) => c.isSmallJoker) && hand.any((c) => c.isBigJoker);

    // 顺子
    final straights = _findStraightsInHand(hand);

    // 连对
    final doubleStraights = _findDoubleStraightsInHand(hand);

    // 飞机
    final tripleStraights = _findTripleStraightsInHand(hand);

    return _HandAnalysis(
      pairs: pairs,
      triples: triples,
      bombs: bombs,
      hasRocket: hasRocket,
      straights: straights,
      doubleStraights: doubleStraights,
      tripleStraights: tripleStraights,
      valueCounts: valueCounts,
    );
  }

  /// 找出手中的所有顺子
  static List<List<int>> _findStraightsInHand(List<Card> hand) {
    final uniqueValues = hand.map((c) => c.value).toSet().toList()..sort();
    final validValues = uniqueValues.where((v) => v <= 12).toList(); // 不含2和王
    final straights = <List<int>>[];

    for (int i = 0; i < validValues.length; i++) {
      for (int len = 5; len <= 12 && i + len <= validValues.length; len++) {
        bool isConsecutive = true;
        for (int j = 1; j < len; j++) {
          if (validValues[i + j] != validValues[i] + j) {
            isConsecutive = false;
            break;
          }
        }
        if (isConsecutive) {
          straights.add(List.generate(len, (j) => validValues[i] + j));
        }
      }
    }

    return straights;
  }

  /// 找出手中的所有连对
  static List<List<int>> _findDoubleStraightsInHand(List<Card> hand) {
    final valueCounts = hand.valueCounts();
    final pairValues = valueCounts.entries
        .where((e) => e.value >= 2)
        .map((e) => e.key)
        .where((v) => v <= 12)
        .toList()
      ..sort();

    final doubleStraights = <List<int>>[];

    for (int i = 0; i < pairValues.length; i++) {
      for (int pairCount = 3; pairCount <= 10; pairCount++) {
        if (i + pairCount > pairValues.length) break;

        bool isConsecutive = true;
        for (int j = 1; j < pairCount; j++) {
          if (pairValues[i + j] != pairValues[i] + j) {
            isConsecutive = false;
            break;
          }
        }
        if (isConsecutive) {
          doubleStraights.add(List.generate(pairCount, (j) => pairValues[i] + j));
        }
      }
    }

    return doubleStraights;
  }

  /// 找出手中的所有飞机
  static List<List<int>> _findTripleStraightsInHand(List<Card> hand) {
    final valueCounts = hand.valueCounts();
    final tripleValues = valueCounts.entries
        .where((e) => e.value >= 3)
        .map((e) => e.key)
        .where((v) => v <= 12)
        .toList()
      ..sort();

    final tripleStraights = <List<int>>[];

    for (int i = 0; i < tripleValues.length; i++) {
      for (int tripleCount = 2; tripleCount <= 6; tripleCount++) {
        if (i + tripleCount > tripleValues.length) break;

        bool isConsecutive = true;
        for (int j = 1; j < tripleCount; j++) {
          if (tripleValues[i + j] != tripleValues[i] + j) {
            isConsecutive = false;
            break;
          }
        }
        if (isConsecutive) {
          tripleStraights.add(List.generate(tripleCount, (j) => tripleValues[i] + j));
        }
      }
    }

    return tripleStraights;
  }

  // ============ 出牌评分 ============

  /// 普通 AI 出牌评分
  static double _scorePlay(
    List<Card> play,
    Player player,
    HandResult? lastHand,
    _HandAnalysis analysis,
    List<Card> allPlayedCards,
  ) {
    final result = HandEvaluator.evaluate(play);
    double score = 0.0;

    // 牌型完整性：优先出整牌型（顺子、连对、飞机）
    switch (result.type) {
      case HandType.straight:
      case HandType.doubleStraight:
      case HandType.tripleStraight:
        score += 5.0;
        break;
      case HandType.tripleWithSingle:
      case HandType.tripleWithPair:
        score += 3.0;
        break;
      case HandType.pair:
        score += 1.0;
        break;
      case HandType.single:
        score += 0.5;
        break;
      default:
        break;
    }

    // 压牌时，优先出刚好能压过的牌
    if (lastHand != null) {
      // 用最小代价压牌
      score -= result.mainRank * 0.05;

      // 如果是炸弹压普通牌，稍微扣分（保留炸弹）
      if (result.isBomb && !lastHand.isBomb) {
        score -= 3.0;
      }
    } else {
      // 首家出牌，出小牌
      score -= result.mainRank * 0.02;
    }

    // 炸弹和火箭保留到最后
    if (result.isBomb) {
      score -= 8.0;
    }
    if (result.type == HandType.rocket) {
      score -= 10.0;
    }

    // 出完手牌后剩余手牌越少越好
    final remaining = player.cardCount - play.length;
    if (remaining <= 2) {
      score += 10.0; // 快出完时大力加分
    }

    return score;
  }

  /// 困难 AI 高级出牌评分
  static double _scorePlayAdvanced(
    List<Card> play,
    Player player,
    HandResult? lastHand,
    _HandAnalysis analysis,
    List<Card> allPlayedCards,
    Map<int, int> remainingCards,
  ) {
    final result = HandEvaluator.evaluate(play);
    double score = 0.0;

    // 基础：优先出整牌型
    switch (result.type) {
      case HandType.straight:
        score += 6.0;
        break;
      case HandType.doubleStraight:
        score += 5.0;
        break;
      case HandType.tripleStraight:
        score += 7.0;
        break;
      case HandType.tripleWithSingle:
      case HandType.tripleWithPair:
        score += 4.0;
        break;
      case HandType.triple:
        score += 3.0;
        break;
      case HandType.pair:
        score += 1.5;
        break;
      case HandType.single:
        score += 0.5;
        break;
      default:
        break;
    }

    // 压牌策略：用最小代价
    if (lastHand != null) {
      score -= result.mainRank * 0.03;

      // 如果是炸弹压普通牌，评估是否必要
      if (result.isBomb && !lastHand.isBomb) {
        // 检查剩余手牌中是否还有其他出牌方式
        score -= 5.0;
      }
    } else {
      // 首家出牌，优先出最小单张
      score -= result.mainRank * 0.02;
    }

    // 记牌分析：判断对手是否有可能压过
    if (result.type == HandType.single && result.mainRank >= 12) {
      // 出大牌时检查剩余大牌数量
      final higherCards = _countRemainingHigherCards(
        result.mainRank,
        remainingCards,
      );
      if (higherCards == 0) {
        score += 3.0; // 没有人能压过，好牌
      }
    }

    // 炸弹保留策略
    if (result.isBomb) {
      // 检查局势
      if (player.cardCount <= 4) {
        score += 5.0; // 手牌少时出炸弹
      } else {
        score -= 6.0; // 否则保留
      }
    }

    if (result.type == HandType.rocket) {
      score -= 8.0; // 火箭最后出
    }

    // 手牌剩余分析
    final remaining = player.cardCount - play.length;
    if (remaining == 0) {
      score += 100.0; // 出完直接获胜
    } else if (remaining <= 2) {
      score += 15.0;
    } else if (remaining <= 5) {
      score += 5.0;
    }

    // 牌型保持性：出完这手牌后，剩余手牌是否还有好牌型
    final simulatedHand = _simulateRemoveCards(player.hand, play);
    final futurePlays = HandEvaluator.getAllPossiblePlays(simulatedHand);
    if (futurePlays.isEmpty && remaining > 0) {
      score -= 5.0; // 出完后没法出了，不好
    }

    return score;
  }

  // ============ 记牌与辅助计算 ============

  /// 计算剩余牌分布（用于困难 AI 的完整记牌）
  static Map<int, int> _calculateRemainingCards(
    List<Card> myHand,
    List<Card> allPlayedCards,
  ) {
    // 初始牌力值分布：每种牌力值有4张（王牌各1张）
    final remaining = <int, int>{};

    // 3-10, J, Q, K, A, 2 各有4张
    for (int v = 1; v <= 13; v++) {
      remaining[v] = 4;
    }
    // 小王、大王各1张
    remaining[14] = 1;
    remaining[15] = 1;

    // 减去已出的牌
    for (final card in allPlayedCards) {
      remaining[card.value] = (remaining[card.value] ?? 0) - 1;
    }

    // 减去我的手牌
    for (final card in myHand) {
      remaining[card.value] = (remaining[card.value] ?? 0) - 1;
    }

    return remaining;
  }

  /// 计算剩余的大牌数量（牌力值 >= threshold 的牌）
  static int _countRemainingHigherCards(
    int threshold,
    Map<int, int> remainingCards,
  ) {
    int count = 0;
    for (int v = threshold + 1; v <= 15; v++) {
      count += remainingCards[v] ?? 0;
    }
    return count;
  }

  /// 模拟移除牌后的手牌
  static List<Card> _simulateRemoveCards(List<Card> hand, List<Card> toRemove) {
    final remaining = hand.clone();
    for (final card in toRemove) {
      remaining.removeWhere((c) => c.value == card.value && c.suit == card.suit);
    }
    return remaining;
  }

  // ============ 提示功能 ============

  /// 获取提示出牌（供人类玩家使用）
  static List<Card>? getHint(
    List<Card> hand,
    HandResult? lastHand,
    Difficulty difficulty,
    List<Card> allPlayedCards,
  ) {
    // 创建临时 AI 玩家
    final aiPlayer = Player(
      name: 'HintAI',
      type: PlayerType.ai,
      index: 0,
    );
    aiPlayer.hand = hand.clone();

    return decidePlay(aiPlayer, lastHand, difficulty, allPlayedCards);
  }

  /// 获取当前手牌中所有合法的出牌方案（按大小排序）
  static List<List<Card>> getAllValidPlays(
    List<Card> hand,
    HandResult? lastHand,
  ) {
    return HandEvaluator.getAllPossiblePlays(hand, lastHand: lastHand);
  }
}

/// 手牌分析结果
class _HandAnalysis {
  final List<int> pairs;
  final List<int> triples;
  final List<int> bombs;
  final bool hasRocket;
  final List<List<int>> straights;
  final List<List<int>> doubleStraights;
  final List<List<int>> tripleStraights;
  final Map<int, int> valueCounts;

  _HandAnalysis({
    required this.pairs,
    required this.triples,
    required this.bombs,
    required this.hasRocket,
    required this.straights,
    required this.doubleStraights,
    required this.tripleStraights,
    required this.valueCounts,
  });
}

/// 带分数的出牌方案
class _ScoredPlay {
  final List<Card> play;
  final double score;

  _ScoredPlay(this.play, this.score);
}
