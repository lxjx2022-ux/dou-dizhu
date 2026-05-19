import 'package:audioplayers/audioplayers.dart';

/// 音效服务
///
/// 使用 audioplayers 插件管理游戏中的所有音效和背景音乐。
/// 采用单例模式，确保全局只有一个音频实例。
///
/// 音频资源路径: assets/audio/
/// - deal.mp3 - 发牌音效
/// - play_card.mp3 - 出牌音效
/// - bomb.mp3 - 炸弹音效
/// - spring.mp3 - 春天/反春音效
/// - win.mp3 - 胜利音效
/// - lose.mp3 - 失败音效
/// - click.mp3 - 按钮点击音效
/// - pass.mp3 - 不要/跳过音效
/// - bgm.mp3 - 背景音乐（循环播放）
class AudioService {
  static final AudioService _instance = AudioService._internal();

  /// 获取 AudioService 单例实例
  factory AudioService() => _instance;

  AudioService._internal();

  /// 背景音乐播放器
  final AudioPlayer _bgmPlayer = AudioPlayer();

  /// 音效播放器（主播放器）
  final AudioPlayer _sfxPlayer = AudioPlayer();

  /// 音效播放器池，用于处理重叠音效
  final Map<String, AudioPlayer> _pool = {};

  /// 音效开关状态
  bool _soundEnabled = true;

  /// 背景音乐开关状态
  bool _bgmEnabled = true;

  /// 音频资源的基础路径
  static const String _audioPath = 'audio';

  /// 是否已经初始化
  bool _initialized = false;

  /// 初始化音频服务
  ///
  /// 设置背景音乐的循环模式。
  /// 必须在应用启动时调用一次。
  Future<void> init() async {
    if (_initialized) return;
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    _initialized = true;
  }

  // ==================== 开关控制 =============    }
  }

  /// 停止背景音乐
  Future<void> stopBgm() async {
    try {
      await _bgmPlayer.stop();
    } catch (e) {
      // 静默处理错误
    }
  }

  // ==================== 资源释放 =============  }
}
