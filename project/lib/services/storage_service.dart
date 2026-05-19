import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/statistics.dart';
import '../models/achievement.dart';

/// 本地存储服务
///
/// 使用 SharedPreferences 进行所有游戏数据的本地持久化。
/// 采用单例模式，确保全局只有一个存储实例。
///
/// 使用到的 SharedPreferences Key:
/// - `dou_dizhu_balance` - 欢乐豆余额 (int, 默认 5000)
/// - `dou_dizhu_difficulty` - 难度设置 (String, 默认 'normal')
/// - `dou_dizhu_laizi_enabled` - 癞子开关 (bool, 默认 false)
/// - `dou_dizhu_sound_enabled` - 音效开关 (bool, 默认 true)
/// - `dou_dizhu_bgm_enabled` - BGM开关 (bool, 默认 true)
/// - `dou_dizhu_haptic_enabled` - 震动开关 (bool, 默认 true)
/// - `dou_dizhu_statistics` - 统计数据 (JSON String)
/// - `dou_dizhu_achievements` - 成就数据 (JSON String)
/// - `dou_dizhu_first_play` - 是否首次游玩 (bool, 默认 true)
class StorageService {
  static final StorageService _instance = StorageService._internal();

  /// 获取 StorageService 单例实例
  factory StorageService() => _instance;

  StorageService._internal();

  SharedPreferences? _prefs;

  /// 是否已经初始化
  bool get isInitialized => _prefs != null;

  /// 初始化存储服务
  ///
  /// 必须在应用启动时调用，完成 SharedPreferences 的初始化。
  /// 可以安全地多次调用，后续调用不会重复初始化。
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ==================== 欢乐豆余额 =============      return Statistics();
    }
  }

  /// 保存游戏统计数据
  Future<void> saveStatistics(Statistics stats) async {
    final json = jsonEncode(stats.toJson());
    await _prefs?.setString('dou_dizhu_statistics', json);
  }

  // ==================== 成就数据 =============      return _createDefaultAchievements();
    }
  }

  /// 保存成就列表
  Future<void> saveAchievements(List<Achievement> achievements) async {
    final list = achievements.map((a) => a.toJson()).toList();
    final json = jsonEncode(list);
    await _prefs?.setString('dou_dizhu_achievements', json);
  }

  // ==================== 首次游玩标记 =============    ];
  }
}
