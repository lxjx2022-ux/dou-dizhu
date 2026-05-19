import '../models/statistics.dart';
import '../models/achievement.dart';
import 'storage_service.dart';

/// 成就检测与解锁服务
///
/// 负责监听游戏事件、检测成就条件、解锁成就并持久化存储。
///
/// 成就类型：
/// - `wins` - 累计胜利次数
/// - `bombs` - 累计打出炸弹数
/// - `springs` - 累计春天次数
/// - `anti_springs` - 累计反春次数
/// - `balance` - 欢乐豆余额达到
/// - `max_streak` - 最高连胜数
/// - `landlord_wins` - 当地主获胜次数
/// - `farmer_wins` - 当农民获胜次数
///
/// 使用示例：
/// ```dart
/// final achievementService = AchievementService();
/// achievementService.checkGameEndAchievements(
///   won: true,
///   isLandlord: true,
///   isSpring: false,
///   isAntiSpring: false,
///   bombsPlayed: 1,
///   balance: 5200,
///   currentStreak: 3,
/// );
/// final newAchievements = await achievementService.getNewlyUnlocked();
/// ```
class AchievementService {
  /// 存储服务实例
  final StorageService _storage = StorageService();

  /// 最近一次解锁的成就ID列表
  final List<String> _newlyUnlockedIds = [];

  /// 检查游戏结束后的成就
  ///
  /// 此方法会：
  /// 1. 更新统计数据（局数、胜负、连胜等）
  /// 2. 更新成就进度
  /// 3. 检测并解锁满足条件的成就
  /// 4. 保存所有数据到本地存储
  ///
  /// 参数：
  /// - [won] 玩家是否获胜
  /// - [isLandlord] 玩家是否为地主
  /// - [isSpring] 是否触发春天
  /// - [isAntiSpring] 是否触发反春
  /// - [bombsPlayed] 本局打出的炸弹数量
  /// - [balance] 当前欢乐豆余额
  /// - [currentStreak] 当前连胜数
  Future<void> checkGameEndAchievements({
    required bool won,
    required bool isLandlord,
    required bool isSpring,
    required bool isAntiSpring,
    required int bombsPlayed,
    required int balance,
    required int currentStreak,
  }) async {
    // 清除上一次的解锁记录
    _newlyUnlockedIds.clear();

    // 获取当前统计数据
    final stats = _storage.getStatistics();

    // 更新基础统计
    stats.totalGames++;
    stats.lastPlayed = DateTime.now();

    if (won) {
      stats.wins++;
      stats.currentStreak = currentStreak;
      if (currentStreak > stats.maxStreak) {
        stats.maxStreak = currentStreak;
      }
      if (isLandlord) {
        stats.landlordWins++;
      } else {
        stats.farmerWins++;
      }
    } else {
      stats.losses++;
      stats.currentStreak = 0;
    }

    // 更新炸弹统计
    stats.bombsPlayed += bombsPlayed;

    // 更新春天/反春统计
    if (isSpring) {
      stats.springs++;
    }
    if (isAntiSpring) {
      stats.antiSprings++;
    }

    // 保存统计数据
    await _storage.saveStatistics(stats);

    // 检查成就
    await _checkAllAchievements(stats, balance, currentStreak);
  }

  /// 获取所有成就列表（带最新进度）
  ///
  /// 返回当前存储中的所有成就，包含最新的解锁状态。
  List<Achievement> getAllAchievements() {
    return _storage.getAchievements();
  }

  /// 获取指定ID的成就
  ///
  /// [id] 成就唯一标识
  /// 返回匹配的成就，如果不存在返回 null。
  Achievement? getAchievementById(String id) {
    final achievements = _storage.getAchievements();
    try {
      return achievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 获取已解锁的成就列表
  ///
  /// 返回所有 isUnlocked 为 true 的成就。
  List<Achievement> getUnlockedAchievements() {
    final achievements = _storage.getAchievements();
    return achievements.where((a) => a.isUnlocked).toList();
  }

  /// 获取未解锁的成就列表
  ///
  /// 返回所有 isUnlocked 为 false 的成就。
  List<Achievement> getLockedAchievements() {
    final achievements = _storage.getAchievements();
    return achievements.where((a) => !a.isUnlocked).toList();
  }

  /// 获取最近一次解锁的成就列表
  ///
  /// 用于游戏结束后显示成就解锁通知。
  /// 调用 [checkGameEndAchievements] 后会自动更新此列表。
  ///
  /// 返回本次游戏中新解锁的成就列表。
  Future<List<Achievement>> getNewlyUnlocked() async {
    if (_newlyUnlockedIds.isEmpty) return [];

    final achievements = _storage.getAchievements();
    return achievements
        .where((a) => _newlyUnlockedIds.contains(a.id))
        .toList();
  }

  /// 清除最近一次解锁记录
  ///
  /// 在显示完成就通知后调用，避免重复显示。
  void clearNewlyUnlocked() {
    _newlyUnlockedIds.clear();
  }

  /// 手动更新单个成就的进度
  ///
  /// [id] 成就ID
  /// [progress] 新的进度值
  ///
  /// 返回是否成功更新。
  Future<bool> updateProgress(String id, int progress) async {
    final achievements = _storage.getAchievements();
    final index = achievements.indexWhere((a) => a.id == id);
    if (index == -1) return false;

    final achievement = achievements[index];
    if (achievement.isUnlocked) return false;

    achievement.progress = progress;

    // 检查是否满足解锁条件
    if (progress >= achievement.requirement && !achievement.isUnlocked) {
      achievement.isUnlocked = true;
      achievement.unlockedAt = DateTime.now();
      _newlyUnlockedIds.add(achievement.id);
    }

    await _storage.saveAchievements(achievements);
    return true;
  }

  /// 重置所有成就
  ///
  /// 将所有成就重置为未解锁状态，进度归零。
  /// 此操作不可撤销。
  Future<void> resetAchievements() async {
    _newlyUnlockedIds.clear();
    final achievements = _storage.getAchievements();
    for (final achievement in achievements) {
      achievement.progress = 0;
      achievement.isUnlocked = false;
      achievement.unlockedAt = null;
    }
    await _storage.saveAchievements(achievements);
  }

  // ==================== 内部方法 =============  }
}
