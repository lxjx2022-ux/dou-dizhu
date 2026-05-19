/// 统计数据模型
/// 记录玩家的整体游戏统计数据
class Statistics {
  /// 总局数
  int totalGames;

  /// 胜利次数
  int wins;

  /// 失败次数
  int losses;

  /// 当地主获胜次数
  int landlordWins;

  /// 当农民获胜次数
  int farmerWins;

  /// 打出的炸弹数
  int bombsPlayed;

  /// 春天次数
  int springs;

  /// 反春次数
  int antiSprings;

  /// 最高连胜
  int maxStreak;

  /// 当前连胜
  int currentStreak;

  /// 总赢取欢乐豆
  int totalEarnings;

  /// 总输掉欢乐豆
  int totalLosses;

  /// 最高欢乐豆余额
  int maxBalance;

  /// 首次游戏时间
  DateTime? firstPlayed;

  /// 最后游戏时间
  DateTime? lastPlayed;

  Statistics({
    this.totalGames = 0,
    this.wins = 0,
    this.losses = 0,
    this.landlordWins = 0,
    this.farmerWins = 0,
    this.bombsPlayed = 0,
    this.springs = 0,
    this.antiSprings = 0,
    this.maxStreak = 0,
    this.currentStreak = 0,
    this.totalEarnings = 0,
    this.totalLosses = 0,
    this.maxBalance = 0,
    this.firstPlayed,
    this.lastPlayed,
  });

  /// 胜率百分比 (0-100)
  double get winRatePercent {
    if (totalGames == 0) return 0.0;
    return (wins / totalGames * 100);
  }

  /// 胜率显示文本
  String get winRateText {
    if (totalGames == 0) return '0%';
    return '${(wins / totalGames * 100).toStringAsFixed(1)}%';
  }

  /// 地主胜率
  double get landlordWinRate {
    final landlordGames = totalGames > 0 ? (totalGames / 3).round() : 0;
    if (landlordGames == 0) return 0.0;
    return landlordWins / landlordGames;
  }

  /// 农民胜率
  double get farmerWinRate {
    final farmerGames = totalGames > 0 ? (totalGames * 2 / 3).round() : 0;
    if (farmerGames == 0) return 0.0;
    return farmerWins / farmerGames;
  }

  /// 净盈亏
  int get netEarnings => totalEarnings - totalLosses;

  /// 更新统计数据（每局结束后调用）
  void recordGame({
    required bool won,
    required bool wasLandlord,
    required int scoreChange,
    required int bombsInGame,
    required bool wasSpring,
    required bool wasAntiSpring,
    required int currentBalance,
  }) {
    totalGames++;
    lastPlayed = DateTime.now();
    if (firstPlayed == null) {
      firstPlayed = lastPlayed;
    }

    if (won) {
      wins++;
      currentStreak++;
      if (currentStreak > maxStreak) {
        maxStreak = currentStreak;
      }
      if (wasLandlord) {
        landlordWins++;
      } else {
        farmerWins++;
      }
      totalEarnings += scoreChange;
    } else {
      losses++;
      currentStreak = 0;
      totalLosses += scoreChange.abs();
    }

    bombsPlayed += bombsInGame;

    if (wasSpring) {
      springs++;
    }
    if (wasAntiSpring) {
      antiSprings++;
    }

    if (currentBalance > maxBalance) {
      maxBalance = currentBalance;
    }
  }

  /// 重置统计（谨慎使用）
  void reset() {
    totalGames = 0;
    wins = 0;
    losses = 0;
    landlordWins = 0;
    farmerWins = 0;
    bombsPlayed = 0;
    springs = 0;
    antiSprings = 0;
    maxStreak = 0;
    currentStreak = 0;
    totalEarnings = 0;
    totalLosses = 0;
    maxBalance = 0;
    firstPlayed = null;
    lastPlayed = null;
  }

  /// 序列化为 JSON
  Map<String, dynamic> toJson() {
    return {
      'totalGames': totalGames,
      'wins': wins,
      'losses': losses,
      'landlordWins': landlordWins,
      'farmerWins': farmerWins,
      'bombsPlayed': bombsPlayed,
      'springs': springs,
      'antiSprings': antiSprings,
      'maxStreak': maxStreak,
      'currentStreak': currentStreak,
      'totalEarnings': totalEarnings,
      'totalLosses': totalLosses,
      'maxBalance': maxBalance,
      'firstPlayed': firstPlayed?.toIso8601String(),
      'lastPlayed': lastPlayed?.toIso8601String(),
    };
  }

  /// 从 JSON 反序列化
  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      totalGames: json['totalGames'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      landlordWins: json['landlordWins'] as int? ?? 0,
      farmerWins: json['farmerWins'] as int? ?? 0,
      bombsPlayed: json['bombsPlayed'] as int? ?? 0,
      springs: json['springs'] as int? ?? 0,
      antiSprings: json['antiSprings'] as int? ?? 0,
      maxStreak: json['maxStreak'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      totalEarnings: json['totalEarnings'] as int? ?? 0,
      totalLosses: json['totalLosses'] as int? ?? 0,
      maxBalance: json['maxBalance'] as int? ?? 0,
      firstPlayed: json['firstPlayed'] != null
          ? DateTime.parse(json['firstPlayed'] as String)
          : null,
      lastPlayed: json['lastPlayed'] != null
          ? DateTime.parse(json['lastPlayed'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'Statistics{games: $totalGames, wins: $wins, losses: $losses, streak: $currentStreak}';
  }
}
