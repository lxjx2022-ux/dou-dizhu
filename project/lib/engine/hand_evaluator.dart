import '../models/card.dart';
import '../models/hand_type.dart';
import '../utils/extensions.dart';

/// 牌型判断器
///
/// 负责判断一组牌是什么牌型、是否合法、能否压过对方牌型。
/// 支持标准斗地主牌型和癞子变牌。
class HandEvaluator {
  /// 判断一组牌是什么牌型
  /// 返回 HandResult，包含牌型类型、主牌点数、长度等信息
  static HandResult evaluate(List<Card> cards) {
    if (cards.isEmpty) {
      return const HandResult(
        type: HandType.invalid,
        mainRank: 0,
        length: 0,
        cards: [],
      );
    }

    final sortedCards = cards.clone()..sortByValue();

    // 1张牌
    if (sortedCards.length == 1) {
      return HandResult(
        type: HandType.single,
        mainRank: sortedCards.first.value,
        length: 1,
        cards: sortedCards,
      );
    }

    // 2张牌
    if (sortedCards.length == 2) {
      return _evaluateTwoCards(sortedCards);
    }

    // 3张牌
    if (sortedCards.length == 3) {
      return _evaluateThreeCards(sortedCards);
    }

    // 4张牌
    if (sortedCards.length == 4) {
      return _evaluateFourCards(sortedCards);
    }

    // 5张牌
    if (sortedCards.length == 5) {
      return _evaluateFiveCards(sortedCards);
    }

    // 6张及以上
    return _evaluateSixPlusCards(sortedCards);
  }

  /// 评估癞子牌型（将癞子牌视为其他牌来形成最佳牌型）
  static HandResult evaluateWithLaiZi(List<Card> cards, Card laiZiCard) {
    if (cards.isEmpty) {
      return const HandResult(
        type: HandType.invalid,
        mainRank: 0,
        length: 0,
        cards: [],
      );
    }

    // 标记癞子牌
    final markedCards = cards
        .map((c) => c.rank == laiZiCard.rank && c.suit == laiZiCard.suit
            ? c.copyWith(isLaiZi: true)
            : c)
        .toList();

    // 先尝试直接评估（癞子牌作为自身点数）
    final directResult = evaluate(markedCards);
    if (directResult.isValid && directResult.type != HandType.invalid) {
      return directResult;
    }

    // 获取癞子牌数量
    final laiZiCount = markedCards.where((c) => c.isLaiZi).length;
    if (laiZiCount == 0) {
      // 没有癞子牌，直接返回标准评估
      return evaluate(markedCards);
    }

    // 尝试将癞子牌变为其他牌力值来形成合法牌型
    final nonLaiZiCards = markedCards.where((c) => !c.isLaiZi).toList();

    // 对于少量癞子牌，尝试各种可能的变牌组合
    HandResult? bestResult;

    // 尝试将癞子牌变为与非癞子牌相同的牌力值（形成对子、三张、炸弹等）
    final valueCounts = nonLaiZiCards.valueCounts();
    final possibleValues = _getPossibleLaiZiValues(nonLaiZiCards, laiZiCount);

    for (final targetValue in possibleValues) {
      // 创建变牌后的组合
      final transformedCards = <Card>[];
      transformedCards.addAll(nonLaiZiCards);

      // 将癞子牌变为目标牌力值
      for (int i = 0; i < laiZiCount; i++) {
        // 找到需要配合的牌
        final neededCard = nonLaiZiCards.firstWhere(
          (c) => c.value == targetValue,
          orElse: () => Card(
            suit: Suit.joker,
            rank: _valueToRank(targetValue),
            isLaiZi: true,
          ),
        );
        transformedCards.add(neededCard.copyWith(isLaiZi: true));
      }

      final result = evaluate(transformedCards);
      if (result.isValid && result.type != HandType.invalid) {
        // 记录这是癞子牌型
        final laiZiResult = HandResult(
          type: result.type == HandType.bomb ? HandType.laiziBomb : result.type,
          mainRank: result.mainRank,
          length: result.length,
          cards: markedCards,
          isLaiZiHand: true,
        );

        // 选择主牌点数最大的结果
        if (bestResult == null || laiZiResult.mainRank > bestResult.mainRank) {
          bestResult = laiZiResult;
        }
      }
    }

    // 特殊处理：尝试形成炸弹
    if (bestResult == null && nonLaiZiCards.length >= 2) {
      final bombResult = _tryFormBombWithLaiZi(nonLaiZiCards, laiZiCount, markedCards);
      if (bombResult != null) {
        bestResult = bombResult;
      }
    }

    // 特殊处理：尝试形成顺子
    if (bestResult == null && nonLaiZiCards.length + laiZiCount >= 5) {
      final straightResult = _tryFormStraightWithLaiZi(nonLaiZiCards, laiZiCount, markedCards);
      if (straightResult != null) {
        bestResult = straightResult;
      }
    }

    // 特殊处理：尝试形成连对
    if (bestResult == null && nonLaiZiCards.length + laiZiCount >= 6) {
      final doubleStraightResult =
          _tryFormDoubleStraightWithLaiZi(nonLaiZiCards, laiZiCount, markedCards);
      if (doubleStraightResult != null) {
        bestResult = doubleStraightResult;
      }
    }

    return bestResult ??
        HandResult(
          type: HandType.invalid,
          mainRank: 0,
          length: cards.length,
          cards: markedCards,
          isLaiZiHand: laiZiCount > 0,
        );
  }

  /// 判断是否可以出牌
  ///
  /// [cards]: 要出的牌
  /// [lastHand]: 上一家出的牌型（null 表示本轮第一家出牌或上家都Pass）
  ///
  /// 返回 true 表示可以出
  static bool isValidPlay(List<Card> cards, HandResult? lastHand) {
    if (cards.isEmpty) return false;

    final result = evaluate(cards);
    if (!result.isValid) return false;

    // 如果没有上家出牌，任何有效牌都可以出
    if (lastHand == null || lastHand.type == HandType.invalid) {
      return true;
    }

    // 使用 canBeat 判断
    return result.canBeat(lastHand);
  }

  /// 判断癞子模式下是否可以出牌
  static bool isValidPlayWithLaiZi(
    List<Card> cards,
    HandResult? lastHand,
    Card? laiZiCard,
  ) {
    if (cards.isEmpty) return false;

    final HandResult result;
    if (laiZiCard != null && cards.any((c) =>
        c.rank == laiZiCard.rank && c.suit == laiZiCard.suit)) {
      result = evaluateWithLaiZi(cards, laiZiCard);
    } else {
      result = evaluate(cards);
    }

    if (!result.isValid) return false;

    if (lastHand == null || lastHand.type == HandType.invalid) {
      return true;
    }

    return result.canBeat(lastHand);
  }

  // ============ 私有评估方法 ============

  /// 评估2张牌
  static HandResult _evaluateTwoCards(List<Card> cards) {
    // 火箭（大小王）
    if (cards[0].isSmallJoker && cards[1].isBigJoker) {
      return HandResult(
        type: HandType.rocket,
        mainRank: 15,
        length: 2,
        cards: cards,
      );
    }

    // 对子
    if (cards[0].value == cards[1].value) {
      return HandResult(
        type: HandType.pair,
        mainRank: cards[0].value,
        length: 1,
        cards: cards,
      );
    }

    return HandResult(
      type: HandType.invalid,
      mainRank: 0,
      length: 2,
      cards: cards,
    );
  }

  /// 评估3张牌
  static HandResult _evaluateThreeCards(List<Card> cards) {
    // 三张（3张同点数）
    if (cards[0].value == cards[1].value && cards[1].value == cards[2].value) {
      return HandResult(
        type: HandType.triple,
        mainRank: cards[0].value,
        length: 1,
        cards: cards,
      );
    }

    return HandResult(
      type: HandType.invalid,
      mainRank: 0,
      length: 3,
      cards: cards,
    );
  }

  /// 评估4张牌
  static HandResult _evaluateFourCards(List<Card> cards) {
    final valueCounts = cards.valueCounts();

    // 炸弹（4张同点数）
    if (valueCounts.length == 1) {
      return HandResult(
        type: HandType.bomb,
        mainRank: cards[0].value,
        length: 4,
        cards: cards,
      );
    }

    return HandResult(
      type: HandType.invalid,
      mainRank: 0,
      length: 4,
      cards: cards,
    );
  }

  /// 评估5张牌
  static HandResult _evaluateFiveCards(List<Card> cards) {
    final valueCounts = cards.valueCounts();

    // 三带一（3+1，最大数量为3）
    if (valueCounts.length == 2 && valueCounts.values.contains(3)) {
      final mainValue = valueCounts.entries.firstWhere((e) => e.value == 3).key;
      return HandResult(
        type: HandType.tripleWithSingle,
        mainRank: mainValue,
        length: 1,
        cards: cards,
      );
    }

    // 顺子（5张连续单张）
    if (_isStraight(cards)) {
      return HandResult(
        type: HandType.straight,
        mainRank: cards.first.value,
        length: 5,
        cards: cards,
      );
    }

    return HandResult(
      type: HandType.invalid,
      mainRank: 0,
      length: 5,
      cards: cards,
    );
  }

  /// 评估6张及以上牌
  static HandResult _evaluateSixPlusCards(List<Card> cards) {
    final valueCounts = cards.valueCounts();

    // 顺子
    if (_isStraight(cards)) {
      return HandResult(
        type: HandType.straight,
        mainRank: cards.first.value,
        length: cards.length,
        cards: cards,
      );
    }

    // 连对（至少3对）
    if (cards.length >= 6 && cards.length % 2 == 0) {
      final pairResult = _isDoubleStraight(cards);
      if (pairResult != null) {
        return HandResult(
          type: HandType.doubleStraight,
          mainRank: pairResult,
          length: cards.length ~/ 2,
          cards: cards,
        );
      }
    }

    // 飞机（至少2组连续三张）
    if (cards.length >= 6 && cards.length % 3 == 0) {
      final tripleResult = _isTripleStraight(cards);
      if (tripleResult != null) {
        return HandResult(
          type: HandType.tripleStraight,
          mainRank: tripleResult,
          length: cards.length ~/ 3,
          cards: cards,
        );
      }
    }

    // 三带二
    if (cards.length == 5 && valueCounts.values.toSet().containsAll({3, 2})) {
      final mainValue = valueCounts.entries.firstWhere((e) => e.value == 3).key;
      return HandResult(
        type: HandType.tripleWithPair,
        mainRank: mainValue,
        length: 1,
        cards: cards,
      );
    }

    // 飞机带单（每组三张 + 相同数量的单张）
    if (cards.length >= 8 && cards.length % 4 == 0) {
      final result = _isTripleStraightWithSingles(cards);
      if (result != null) {
        return HandResult(
          type: HandType.tripleStraightWithSingles,
          mainRank: result[0],
          length: result[1],
          cards: cards,
        );
      }
    }

    // 飞机带对（每组三张 + 相同数量的对子）
    if (cards.length >= 10 && cards.length % 5 == 0) {
      final result = _isTripleStraightWithPairs(cards);
      if (result != null) {
        return HandResult(
          type: HandType.tripleStraightWithPairs,
          mainRank: result[0],
          length: result[1],
          cards: cards,
        );
      }
    }

    // 四带二
    if (cards.length == 6) {
      final result = _isQuadWithTwoSingles(cards);
      if (result != null) {
        return HandResult(
          type: HandType.quadWithTwoSingles,
          mainRank: result,
          length: 1,
          cards: cards,
        );
      }
    }

    if (cards.length == 8) {
      final result = _isQuadWithTwoPairs(cards);
      if (result != null) {
        return HandResult(
          type: HandType.quadWithTwoPairs,
          mainRank: result,
          length: 1,
          cards: cards,
        );
      }
    }

    return HandResult(
      type: HandType.invalid,
      mainRank: 0,
      length: cards.length,
      cards: cards,
    );
  }

  // ============ 牌型判断辅助方法 ============

  /// 判断是否为顺子（5+张连续单张，不含2和王）
  static bool _isStraight(List<Card> cards) {
    if (cards.length < 5) return false;

    final values = cards.map((c) => c.value).toList()..sort();

    // 顺子不能包含2和王（牌力值13及以上）
    if (values.any((v) => v >= 13)) return false;

    // 检查是否连续
    for (int i = 1; i < values.length; i++) {
      if (values[i] != values[i - 1] + 1) return false;
    }

    return true;
  }

  /// 判断是否为连对（3+对连续对子，不含2和王）
  /// 返回最小对子的牌力值，null 表示不是连对
  static int? _isDoubleStraight(List<Card> cards) {
    if (cards.length < 6 || cards.length % 2 != 0) return null;

    final pairCount = cards.length ~/ 2;
    final valueCounts = cards.valueCounts();

    // 每个牌力值必须恰好出现2次
    if (valueCounts.length != pairCount) return null;
    if (!valueCounts.values.every((count) => count == 2)) return null;

    // 不能包含2和王
    final values = valueCounts.keys.toList()..sort();
    if (values.any((v) => v >= 13)) return null;

    // 必须连续
    for (int i = 1; i < values.length; i++) {
      if (values[i] != values[i - 1] + 1) return null;
    }

    return values.first;
  }

  /// 判断是否为飞机（2+组连续三张，不含2和王）
  /// 返回最小三张组的牌力值，null 表示不是飞机
  static int? _isTripleStraight(List<Card> cards) {
    if (cards.length < 6 || cards.length % 3 != 0) return null;

    final tripleCount = cards.length ~/ 3;
    final valueCounts = cards.valueCounts();

    // 每个牌力值必须恰好出现3次
    if (valueCounts.length != tripleCount) return null;
    if (!valueCounts.values.every((count) => count == 3)) return null;

    // 不能包含2和王
    final values = valueCounts.keys.toList()..sort();
    if (values.any((v) => v >= 13)) return null;

    // 必须连续
    for (int i = 1; i < values.length; i++) {
      if (values[i] != values[i - 1] + 1) return null;
    }

    return values.first;
  }

  /// 判断是否为飞机带单
  /// 返回 [最小三张组牌力值, 组数]，null 表示不是
  static List<int>? _isTripleStraightWithSingles(List<Card> cards) {
    final valueCounts = cards.valueCounts();
    final tripleValues = <int>[];

    // 找出所有三张
    for (final entry in valueCounts.entries) {
      if (entry.value == 3) {
        tripleValues.add(entry.key);
      }
    }

    if (tripleValues.length < 2) return null;

    tripleValues.sort();

    // 检查连续的三张组
    final straightLength = tripleValues.length;

    // 不能包含2和王
    if (tripleValues.any((v) => v >= 13)) return null;

    // 必须连续
    for (int i = 1; i < tripleValues.length; i++) {
      if (tripleValues[i] != tripleValues[i - 1] + 1) return null;
    }

    // 带牌数量必须等于三张组数
    final singleCount = valueCounts.values.where((c) => c == 1).length;
    final pairCount = valueCounts.values.where((c) => c == 2).length;
    // 带牌可以是单张或对子拆开，但总数必须正确
    final kickerCount = singleCount + pairCount * 2;
    if (kickerCount != straightLength) return null;

    // 总牌数验证
    if (cards.length != straightLength * 4) return null;

    return [tripleValues.first, straightLength];
  }

  /// 判断是否为飞机带对
  /// 返回 [最小三张组牌力值, 组数]，null 表示不是
  static List<int>? _isTripleStraightWithPairs(List<Card> cards) {
    final valueCounts = cards.valueCounts();
    final tripleValues = <int>[];

    // 找出所有三张
    for (final entry in valueCounts.entries) {
      if (entry.value == 3) {
        tripleValues.add(entry.key);
      }
    }

    if (tripleValues.length < 2) return null;

    tripleValues.sort();

    // 不能包含2和王
    if (tripleValues.any((v) => v >= 13)) return null;

    // 必须连续
    for (int i = 1; i < tripleValues.length; i++) {
      if (tripleValues[i] != tripleValues[i - 1] + 1) return null;
    }

    // 带牌必须是对子
    final kickerPairs = valueCounts.values.where((c) => c == 2).length;
    if (kickerPairs != tripleValues.length) return null;

    // 总牌数验证
    if (cards.length != tripleValues.length * 5) return null;

    return [tripleValues.first, tripleValues.length];
  }

  /// 判断是否为四带二
  /// 返回四张的牌力值，null 表示不是
  static int? _isQuadWithTwoSingles(List<Card> cards) {
    final valueCounts = cards.valueCounts();

    // 找一个四张
    int? quadValue;
    int singleCount = 0;
    for (final entry in valueCounts.entries) {
      if (entry.value == 4) {
        quadValue = entry.key;
      } else if (entry.value == 1) {
        singleCount += entry.value;
      } else if (entry.value == 2) {
        // 两张不同的单牌也可以是2+2
        singleCount += entry.value;
      }
    }

    if (quadValue == null) return null;
    if (cards.length != 6) return null;

    return quadValue;
  }

  /// 判断是否为四带两对
  /// 返回四张的牌力值，null 表示不是
  static int? _isQuadWithTwoPairs(List<Card> cards) {
    final valueCounts = cards.valueCounts();

    int? quadValue;
    int pairCount = 0;
    for (final entry in valueCounts.entries) {
      if (entry.value == 4) {
        quadValue = entry.key;
      } else if (entry.value == 2) {
        pairCount++;
      }
    }

    if (quadValue == null) return null;
    if (pairCount != 2) return null;
    if (cards.length != 8) return null;

    return quadValue;
  }

  // ============ 癞子辅助方法 ============

  /// 获取癞子牌可能变成的牌力值列表
  static List<int> _getPossibleLaiZiValues(List<Card> nonLaiZiCards, int laiZiCount) {
    final values = nonLaiZiCards.map((c) => c.value).toSet().toList();
    // 也考虑形成新的牌力值（如顺子中的空缺）
    for (int v = 1; v <= 12; v++) {
      if (!values.contains(v)) {
        values.add(v);
      }
    }
    values.sort();
    return values;
  }

  /// 尝试用癞子牌形成炸弹
  static HandResult? _tryFormBombWithLaiZi(
    List<Card> nonLaiZiCards,
    int laiZiCount,
    List<Card> originalCards,
  ) {
    if (nonLaiZiCards.length + laiZiCount < 4) return null;

    final valueCounts = nonLaiZiCards.valueCounts();

    // 找一个已有最多张的牌力值
    int bestValue = 0;
    int bestCount = 0;
    for (final entry in valueCounts.entries) {
      if (entry.value > bestCount) {
        bestCount = entry.value;
        bestValue = entry.key;
      }
    }

    if (bestCount + laiZiCount >= 4) {
      return HandResult(
        type: HandType.laiziBomb,
        mainRank: bestValue,
        length: 4,
        cards: originalCards,
        isLaiZiHand: true,
      );
    }

    return null;
  }

  /// 尝试用癞子牌形成顺子
  static HandResult? _tryFormStraightWithLaiZi(
    List<Card> nonLaiZiCards,
    int laiZiCount,
    List<Card> originalCards,
  ) {
    if (nonLaiZiCards.length + laiZiCount < 5) return null;

    final values = nonLaiZiCards.map((c) => c.value).toSet().toList()..sort();

    // 尝试以每个非癞子牌为起点构建顺子
    for (final startValue in values) {
      if (startValue >= 13) continue; // 2和王不能加入顺子

      int needed = 0;
      final straightLength = nonLaiZiCards.length + laiZiCount;
      // 限制顺子最大长度
      final maxLen = straightLength.clamp(5, 12);

      for (int i = 0; i < maxLen; i++) {
        final targetValue = startValue + i;
        if (targetValue >= 13) {
          needed += maxLen - i;
          break;
        }
        if (!values.contains(targetValue)) {
          needed++;
        }
      }

      if (needed <= laiZiCount) {
        return HandResult(
          type: HandType.straight,
          mainRank: startValue,
          length: maxLen,
          cards: originalCards,
          isLaiZiHand: true,
        );
      }
    }

    return null;
  }

  /// 尝试用癞子牌形成连对
  static HandResult? _tryFormDoubleStraightWithLaiZi(
    List<Card> nonLaiZiCards,
    int laiZiCount,
    List<Card> originalCards,
  ) {
    if (nonLaiZiCards.length + laiZiCount < 6) return null;

    final valueCounts = nonLaiZiCards.valueCounts();
    final values = valueCounts.keys.toList()..sort();

    // 尝试从每个可能的起点构建连对
    for (int startIdx = 0; startIdx < values.length; startIdx++) {
      final startValue = values[startIdx];
      if (startValue >= 13) continue;

      int needed = 0;
      int pairCount = 0;

      for (int v = startValue; v < 13 && pairCount < 10; v++) {
        final count = valueCounts[v] ?? 0;
        if (count >= 2) {
          pairCount++;
        } else {
          final needForPair = 2 - count;
          if (needed + needForPair <= laiZiCount) {
            needed += needForPair;
            pairCount++;
          } else {
            break;
          }
        }
      }

      if (pairCount >= 3 && needed <= laiZiCount) {
        return HandResult(
          type: HandType.doubleStraight,
          mainRank: startValue,
          length: pairCount,
          cards: originalCards,
          isLaiZiHand: true,
        );
      }
    }

    return null;
  }

  /// 牌力值转换为点数（用于癞子变牌）
  static int _valueToRank(int value) {
    if (value == 12) return 1; // A
    if (value == 13) return 2; // 2
    return value + 2; // 1->3, 2->4, ..., 11->K
  }

  // ============ 公共工具方法 ============

  /// 获取手牌中所有可能的出牌组合
  /// 用于 AI 决策和提示功能
  static List<List<Card>> getAllPossiblePlays(
    List<Card> hand, {
    HandResult? lastHand,
    Card? laiZiCard,
  }) {
    final plays = <List<Card>>[];

    // 单张
    for (final card in hand) {
      final play = [card];
      if (_isValidPlayInternal(play, lastHand, laiZiCard)) {
        plays.add(play);
      }
    }

    // 对子
    final pairs = _findPairs(hand);
    for (final pair in pairs) {
      if (_isValidPlayInternal(pair, lastHand, laiZiCard)) {
        plays.add(pair);
      }
    }

    // 三张
    final triples = _findTriples(hand);
    for (final triple in triples) {
      if (_isValidPlayInternal(triple, lastHand, laiZiCard)) {
        plays.add(triple);
      }
    }

    // 三带一、三带二
    for (final triple in triples) {
      final tripleValue = triple.first.value;
      // 三带一
      for (final kicker in hand) {
        if (kicker.value != tripleValue) {
          final play = [...triple, kicker];
          if (_isValidPlayInternal(play, lastHand, laiZiCard)) {
            plays.add(play);
          }
        }
      }
      // 三带二
      for (final pair in pairs) {
        if (pair.first.value != tripleValue) {
          final play = [...triple, ...pair];
          if (_isValidPlayInternal(play, lastHand, laiZiCard)) {
            plays.add(play);
          }
        }
      }
    }

    // 顺子
    final straights = _findStraights(hand);
    for (final straight in straights) {
      if (_isValidPlayInternal(straight, lastHand, laiZiCard)) {
        plays.add(straight);
      }
    }

    // 连对
    final doubleStraights = _findDoubleStraights(hand);
    for (final ds in doubleStraights) {
      if (_isValidPlayInternal(ds, lastHand, laiZiCard)) {
        plays.add(ds);
      }
    }

    // 飞机
    final tripleStraights = _findTripleStraights(hand);
    for (final ts in tripleStraights) {
      if (_isValidPlayInternal(ts, lastHand, laiZiCard)) {
        plays.add(ts);
      }
    }

    // 炸弹
    final bombs = _findBombs(hand);
    for (final bomb in bombs) {
      if (_isValidPlayInternal(bomb, lastHand, laiZiCard)) {
        plays.add(bomb);
      }
    }

    // 火箭
    if (_hasRocket(hand)) {
      final rocket = hand
          .where((c) => c.isJoker)
          .toList()
        ..sortByValue();
      if (rocket.length == 2) {
        if (_isValidPlayInternal(rocket, lastHand, laiZiCard)) {
          plays.add(rocket);
        }
      }
    }

    // 去重
    final uniquePlays = <List<Card>>[];
    final seen = <String>{};
    for (final play in plays) {
      final key = play.map((c) => '${c.suit.index}-${c.rank}').join(',');
      if (!seen.contains(key)) {
        seen.add(key);
        uniquePlays.add(play);
      }
    }

    return uniquePlays;
  }

  /// 获取提示出牌（找出一组可以压过对方的牌）
  static List<Card>? getHint(
    List<Card> hand, {
    HandResult? lastHand,
    Card? laiZiCard,
  }) {
    if (lastHand == null) {
      // 首家出牌，出最小单张
      if (hand.isNotEmpty) {
        final sorted = hand.clone()..sortByValue();
        return [sorted.first];
      }
      return null;
    }

    final allPlays = getAllPossiblePlays(hand, lastHand: lastHand, laiZiCard: laiZiCard);
    if (allPlays.isEmpty) return null;

    // 优先出最小能压过的牌
    allPlays.sort((a, b) {
      final resultA = evaluate(a);
      final resultB = evaluate(b);
      return resultA.mainRank.compareTo(resultB.mainRank);
    });

    return allPlays.first;
  }

  // ============ 内部辅助方法 ============

  static bool _isValidPlayInternal(
    List<Card> cards,
    HandResult? lastHand,
    Card? laiZiCard,
  ) {
    if (laiZiCard != null) {
      return isValidPlayWithLaiZi(cards, lastHand, laiZiCard);
    }
    return isValidPlay(cards, lastHand);
  }

  static List<List<Card>> _findPairs(List<Card> hand) {
    final pairs = <List<Card>>[];
    final valueCounts = hand.valueCounts();
    for (final entry in valueCounts.entries) {
      if (entry.value >= 2) {
        final cards = hand.where((c) => c.value == entry.key).take(2).toList();
        if (cards.length == 2) pairs.add(cards);
      }
    }
    return pairs;
  }

  static List<List<Card>> _findTriples(List<Card> hand) {
    final triples = <List<Card>>[];
    final valueCounts = hand.valueCounts();
    for (final entry in valueCounts.entries) {
      if (entry.value >= 3) {
        final cards = hand.where((c) => c.value == entry.key).take(3).toList();
        if (cards.length == 3) triples.add(cards);
      }
    }
    return triples;
  }

  static List<List<Card>> _findBombs(List<Card> hand) {
    final bombs = <List<Card>>[];
    final valueCounts = hand.valueCounts();
    for (final entry in valueCounts.entries) {
      if (entry.value >= 4) {
        final cards = hand.where((c) => c.value == entry.key).take(4).toList();
        if (cards.length == 4) bombs.add(cards);
      }
    }
    return bombs;
  }

  static List<List<Card>> _findStraights(List<Card> hand) {
    final straights = <List<Card>>[];
    final uniqueValues = hand.map((c) => c.value).toSet().toList()..sort();

    // 顺子不能包含2和王（牌力值13+）
    final validValues = uniqueValues.where((v) => v <= 12).toList();

    // 枚举所有可能的顺子
    for (int start = 0; start < validValues.length; start++) {
      for (int len = 5; len <= 12; len++) {
        final startValue = validValues[start];
        final endValue = startValue + len - 1;
        if (endValue > 12) break;

        // 检查是否有连续 len 张牌
        bool isValid = true;
        final straightCards = <Card>[];
        for (int v = startValue; v <= endValue; v++) {
          final card = hand.firstWhere(
            (c) => c.value == v,
            orElse: () => Card(suit: Suit.joker, rank: 0),
          );
          if (card.rank == 0) {
            isValid = false;
            break;
          }
          straightCards.add(card);
        }

        if (isValid && straightCards.length >= 5) {
          straights.add(straightCards);
        }
      }
    }

    return straights;
  }

  static List<List<Card>> _findDoubleStraights(List<Card> hand) {
    final doubleStraights = <List<Card>>[];
    final valueCounts = hand.valueCounts();
    final valuesWithPairs = valueCounts.entries
        .where((e) => e.value >= 2)
        .map((e) => e.key)
        .where((v) => v <= 12)
        .toList()
      ..sort();

    // 枚举所有连对
    for (int i = 0; i < valuesWithPairs.length; i++) {
      for (int pairCount = 3; pairCount <= 10; pairCount++) {
        final startValue = valuesWithPairs[i];
        final endValue = startValue + pairCount - 1;
        if (endValue > 12) break;

        bool isValid = true;
        final dsCards = <Card>[];
        for (int v = startValue; v <= endValue; v++) {
          final count = valueCounts[v] ?? 0;
          if (count < 2) {
            isValid = false;
            break;
          }
          dsCards.addAll(hand.where((c) => c.value == v).take(2));
        }

        if (isValid && dsCards.length >= 6) {
          doubleStraights.add(dsCards);
        }
      }
    }

    return doubleStraights;
  }

  static List<List<Card>> _findTripleStraights(List<Card> hand) {
    final tripleStraights = <List<Card>>[];
    final valueCounts = hand.valueCounts();
    final valuesWithTriples = valueCounts.entries
        .where((e) => e.value >= 3)
        .map((e) => e.key)
        .where((v) => v <= 12)
        .toList()
      ..sort();

    for (int i = 0; i < valuesWithTriples.length; i++) {
      for (int tripleCount = 2; tripleCount <= 6; tripleCount++) {
        final startValue = valuesWithTriples[i];
        final endValue = startValue + tripleCount - 1;
        if (endValue > 12) break;

        bool isValid = true;
        final tsCards = <Card>[];
        for (int v = startValue; v <= endValue; v++) {
          final count = valueCounts[v] ?? 0;
          if (count < 3) {
            isValid = false;
            break;
          }
          tsCards.addAll(hand.where((c) => c.value == v).take(3));
        }

        if (isValid && tsCards.length >= 6) {
          tripleStraights.add(tsCards);
        }
      }
    }

    return tripleStraights;
  }

  static bool _hasRocket(List<Card> hand) {
    return hand.any((c) => c.isSmallJoker) && hand.any((c) => c.isBigJoker);
  }
}
