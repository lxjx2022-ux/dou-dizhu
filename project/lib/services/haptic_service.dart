import 'package:vibration/vibration.dart';

/// 触感反馈服务
///
/// 使用 vibration 插件提供游戏中的触感反馈效果。
/// 采用单例模式，确保全局只有一个触感服务实例。
///
/// 反馈强度等级：
/// - light (10ms) - 轻微反馈，用于卡片选择等
/// - medium (20ms) - 中等反馈，用于出牌等
/// - heavy (30ms) - 强烈反馈，用于炸弹等
///
/// 特殊模式：
/// - bomb - 炸弹爆发震动模式（强-弱-强）
/// - win - 胜利震动模式（轻快节奏）
/// - error - 错误震动（长震动）
class HapticService {
  static final HapticService _instance = HapticService._internal();

  /// 获取 HapticService 单例实例
  factory HapticService() => _instance;

  HapticService._internal();

  /// 触感反馈开关状态
  bool _enabled = true;

  /// 设备是否支持震动
  bool _hasVibrator = false;

  /// 是否已经初始化
  bool _initialized = false;

  /// 初始化触感服务
  ///
  /// 检测设备是否支持震动功能。
  /// 必须在应用启动时调用一次。
  Future<void> init() async {
    if (_initialized) return;
    try {
      _hasVibrator = await Vibration.hasVibrator() ?? false;
    } catch (e) {
      // 如果检测失败，假设设备不支持震动
      _hasVibrator = false;
    }
    _initialized = true;
  }

  // ==================== 开关控制 =============    }
  }
}
