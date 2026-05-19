/// 成就数据模型
class Achievement {
  /// 成就唯一标识
  final String id;

  /// 成就名称
  final String name;

  /// 成就描述
  final String description;

  /// 图标名称（对应 Flutter 图标或资源名称）
  final String iconName;

  /// 成就类型（用于分类显示）
  final String type;

  /// 达成条件数值（如：需要赢10局）
  final int requirement;

  /// 当前进度
  int progress;

  /// 是否已解锁
  bool isUnlocked;

  /// 解锁时间
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.type,
    required this.requirement,
    this.progress = 0,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  /// 进度百分比 (0.0 - 1.0)
  double get progressPercent {
    if (requirement <= 0) return isUnlocked ? 1.0 : 0.0;
    double pct = progress / requirement;
    return pct.clamp(0.0, 1.0);
  }

  /// 进度显示文本，如 "3/10"
  String get progressText => '$progress/$requirement';

  /// 更新进度并检查是否解锁
  /// 返回 true 表示本次更新触发了解锁
  bool updateProgress(int newProgress) {
    if (isUnlocked) return false;
    progress = newProgress.clamp(0, requirement);
    if (progress >= requirement) {
      isUnlocked = true;
      unlockedAt = DateTime.now();
      return true;
    }
    return false;
  }

  /// 增加进度
  /// 返回 true 表示本次增加触发了解锁
  bool incrementProgress([int amount = 1]) {
    return updateProgress(progress + amount);
  }

  /// 序列化为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconName': iconName,
      'type': type,
      'requirement': requirement,
      'progress': progress,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  /// 从 JSON 反序列化
  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconName: json['iconName'] as String,
      type: json['type'] as String,
      requirement: json['requirement'] as int,
      progress: json['progress'] as int? ?? 0,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
    );
  }

  /// 创建预设成就列表的工厂方法
  static List<Achievement> createDefaultAchievements() {
    return [
      Achievement(
        id: 'first_win',
        name: '初出茅庐',
        description: '获得第一场胜利',
        iconName: 'emoji_events',
        type: 'milestone',
        requirement: 1,
      ),
      Achievement(
        id: 'win_10',
        name: '小有所成',
        description: '累计获胜10局',
        iconName: 'military_tech',
        type: 'milestone',
        requirement: 10,
      ),
      Achievement(
        id: 'win_100',
        name: '斗地主高手',
        description: '累计获胜100局',
        iconName: 'workspace_premium',
        type: 'milestone',
        requirement: 100,
      ),
      Achievement(
        id: 'bomb_10',
        name: '炸弹大师',
        description: '累计打出10个炸弹',
        iconName: 'local_fire_department',
        type: 'skill',
        requirement: 10,
      ),
      Achievement(
        id: 'spring_5',
        name: '春天制造者',
        description: '累计打出5次春天',
        iconName: 'wb_sunny',
        type: 'skill',
        requirement: 5,
      ),
      Achievement(
        id: 'anti_spring_3',
        name: '逆袭者',
        description: '累计打出3次反春',
        iconName: 'call_made',
        type: 'skill',
        requirement: 3,
      ),
      Achievement(
        id: 'rich_100k',
        name: '家财万贯',
        description: '欢乐豆达到10万',
        iconName: 'account_balance',
        type: 'wealth',
        requirement: 100000,
      ),
      Achievement(
        id: 'streak_5',
        name: '连胜将军',
        description: '连胜5局',
        iconName: 'whatshot',
        type: 'skill',
        requirement: 5,
      ),
      Achievement(
        id: 'landlord_win_20',
        name: '地主之王',
        description: '当地主获胜20次',
        iconName: 'castle',
        type: 'role',
        requirement: 20,
      ),
      Achievement(
        id: 'farmer_win_50',
        name: '农民起义军',
        description: '当农民获胜50次',
        iconName: 'agriculture',
        type: 'role',
        requirement: 50,
      ),
    ];
  }

  @override
  String toString() {
    return 'Achievement{id: $id, name: $name, progress: $progress/$requirement, unlocked: $isUnlocked}';
  }
}
