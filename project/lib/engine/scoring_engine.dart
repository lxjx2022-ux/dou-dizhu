import '../models/player.dart';

/// 计分引擎
///
/// 负责计算斗地主游戏的倍率和最终得分。
/// 遵循标准斗地主计分规则。
class ScoringEngine {
  /// 初始倍率
  static const int initialMultiplier = 1;

  /// 叫地主倍率加成
  static const int callMultiplier = 1;

  /// 抢地主倍率加成（每次x2）
  static const int grabMultiplier = 2;

  /// 加倍倍率
  static const int doubleMultiplier = 2;

  /// 超级加倍倍率
  static const int superDoubleMultiplier = 4;

  /// 炸弹倍率加成
  static const int bombMultiplier = 2;

  /// 春天/反春倍率加成
  static const int springMultiplier = 2;

  /// 计算总倍率
  ///
  /// 参数:
  /// - [called]: 是否叫了地主
  /// - [grabbed]: 是否抢了地主
  /// - [doubled]: 是否加倍
  /// - [superDoubled]: 是否超级加倍
  /// - [bombCount]: 本局炸弹数量
  /// - [spring]: 是否有春天/反春
  static int calculateMultiplier({
    bool called = false,
    bool grabbed = false,
    bool doubled = false,
    bool superDoubled = false,
    int bombCount = 0,
    bool spring = false,
  }) {
    int multiplier = initialMultiplier;

    // 叫了地主
    if (called) {
      multiplier *= callMultiplier;
    }

    // 抢了地主 x2
    if (grabbed) {
      multiplier *= grabMultiplier;
    }

    // 加倍
    if (superDoubled) {
      multiplier *= superDoubleMultiplier;
    } else if (doubled) {
      multiplier *= doubleMultiplier;
    }

    // 每个炸弹 x2
    for (int i = 0; i < bombCount; i++) {
      multiplier *= bombMultiplier;
    }

    // 春天/反春 x2
    if (spring) {
      multiplier *= springMultiplier;
    }

    return multiplier;
  }

  /// 从 GameState 的状态计算倍率
  static int calculateMultiplierFromGame({
    required bool landlordCalled,
    required int grabCount,
    required List<bool> doubled,
    required List<bool> superDoubled,
    required int bombCount,
    required bool hasSpring,
  }) {
    int multiplier = initialMultiplier;

    // 叫地主倍率 x1（基础）
    if (landlordCalled) {
      // 叫地主保持基础倍率
    }

    // 每次抢地主 x2
    for (int i = 0; i < grabCount; i++) {
      multiplier *= grabMultiplier;
    }

    // 加倍
    for (int i = 0; i < 3; i++) {
      if (superDoubled.length > i && superDoubled[i]) {
        multiplier *= superDoubleMultiplier;
      } else if (doubled.length > i && doubled[i]) {
        multiplier *= doubleMultiplier;
      }
    }

    // 炸弹
    for (int i = 0; i < bombCount; i++) {
      multiplier *= bombMultiplier;
    }

    // 春天
    if (hasSpring) {
      multiplier *= springMultiplier;
    }

    return multiplier;
  }

  /// 计算本局得分分配
  ///
  /// 返回 Map<玩家索引, 得分变化>（正数为赢，负数为输）
  ///
  /// 规则:
  /// - 地主胜: 地主获得 2 × 底分 × 倍率，两个农民各扣除 底分 × 倍率
  /// - 农民胜: 两个农民各获得 底分 × 倍率，地主扣除 2 × 底分 × 倍率
  static Map<int, int> calculateScoreDistribution(
    int baseScore,
    int multiplier,
    int landlordIndex,
    bool landlordWon,
  ) {
    final scoreMap = <int, int>{};

    // 计算单份分数
    final singleScore = baseScore * multiplier;

    if (landlordWon) {
      // 地主获胜
      for (int i = 0; i < 3; i++) {
        if (i == landlordIndex) {
          // 地主赢双倍
          scoreMap[i] = 2 * singleScore;
        } else {
          // 农民输单份
          scoreMap[i] = -singleScore;
        }
      }
    } else {
      // 农民获胜
      for (int i = 0; i < 3; i++) {
        if (i == landlordIndex) {
          // 地主输双倍
          scoreMap[i] = -2 * singleScore;
        } else {
          // 农民赢单份
          scoreMap[i] = singleScore;
        }
      }
    }

    return scoreMap;
  }

  /// 计算本局得分分配（简化版，从玩家列表）
  static Map<int, int> calculateScores({
    required int baseScore,
    required int multiplier,
    required int landlordIndex,
    required bool landlordWon,
  }) {
    return calculateScoreDistribution(
      baseScore,
      multiplier,
      landlordIndex,
      landlordWon,
    );
  }

  /// 判断是否为春天
  ///
  /// 春天: 地主出完所有牌，且农民一张牌都没有出过
  static bool isSpring(
    int landlordIndex,
    Map<int, List<Card>> roundPlays,
  ) {
    // 农民索引
    final farmerIndices = [0, 1, 2]..remove(landlordIndex);

    // 检查两个农民是否都没有出过牌
    for (final idx in farmerIndices) {
      if (roundPlays[idx]?.isNotEmpty ?? false) {
        return false;
      }
    }

    return true;
  }

  /// 判断是否为反春
  ///
  /// 反春: 任一农民出完所有牌，且地主只出过一手牌
  static bool isAntiSpring(
    int landlordIndex,
    Map<int, List<Card>> roundPlays,
  ) {
    // 地主出牌次数
    final landlordPlayCount = roundPlays[landlordIndex]?.length ?? 0;

    // 地主只出过一手牌
    if (landlordPlayCount > 1) return false;

    // 农民索引
    final farmerIndices = [0, 1, 2]..remove(landlordIndex);

    // 任一农民有出牌记录（即赢家的那一方）
    for (final idx in farmerIndices) {
      if (roundPlays[idx]?.isNotEmpty ?? false) {
        return true;
      }
    }

    return false;
  }

  /// 确定春天类型
  /// 返回: 0=无, 1=春天, 2=反春
  static int determineSpringType(
    int landlordIndex,
    bool landlordWon,
    Map<int, List<Card>> roundPlays,
  ) {
    if (landlordWon) {
      if (isSpring(landlordIndex, roundPlays)) {
        return 1; // 春天
      }
    } else {
      if (isAntiSpring(landlordIndex, roundPlays)) {
        return 2; // 反春
      }
    }
    return 0; // 无
  }

  /// 获取春天类型的显示名称
  static String getSpringTypeName(int springType) {
    switch (springType) {
      case 1:
        return '春天';
      case 2:
        return '反春';
      default:
        return '';
    }
  }

  /// 计算本局经验值奖励
  /// - 胜利: 基础 10 点
  /// - 春天/反春: 额外 5 点
  /// - 使用炸弹: 每个 2 点
  static int calculateExperienceReward({
    required bool won,
    required int springType,
    required int bombCount,
  }) {
    int exp = 0;

    if (won) {
      exp += 10;
    } else {
      exp += 5;
    }

    if (springType > 0) {
      exp += 5;
    }

    exp += bombCount * 2;

    return exp;
  }

  /// 获取倍率计算过程的描述（用于展示）
  static String getMultiplierBreakdown({
    required bool called,
    required int grabCount,
    required int bombCount,
    required bool hasSpring,
  }) {
    final parts = <String>[];

    parts.add('基础 x1');

    if (called) {
      parts.add('叫地主 x1');
    }

    for (int i = 0; i < grabCount; i++) {
      parts.add('抢地主 x2');
    }

    for (int i = 0; i < bombCount; i++) {
      parts.add('炸弹 x2');
    }

    if (hasSpring) {
      parts.add('春天/反春 x2');
    }

    return parts.join(' + ');
  }
}
