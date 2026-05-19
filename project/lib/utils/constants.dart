import 'package:flutter/material.dart';

// =============================================================================
// 颜色系统
// =============================================================================
class AppColors {
  AppColors._();

  // 牌桌
  static const Color tableGreen = Color(0xFF1B5E20);
  static const Color tableGreenLight = Color(0xFF2E7D32);
  static const Color tableEdge = Color(0xFF3E2723);
  static const Color tableFelt = Color(0xFF154A1A);
  static const Color tableCenter = Color(0xFF0D3B10);

  // UI元素 - 毛玻璃
  static const Color glassBackground = Color(0xB3FFFFFF);
  static const Color glassBorder = Color(0x4DFFFFFF);
  static const Color glassHighlight = Color(0x26FFFFFF);

  // 按钮
  static const Color primaryButton = Color(0xFFFFD700);
  static const Color primaryButtonPressed = Color(0xFFFFC107);
  static const Color secondaryButton = Color(0xFF607D8B);
  static const Color dangerButton = Color(0xFFE53935);
  static const Color successButton = Color(0xFF4CAF50);

  // 文字
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF);
  static const Color textDark = Color(0xFF212121);
  static const Color textGold = Color(0xFFFFD700);

  // 状态
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // 扑克牌花色
  static const Color spadeColor = Color(0xFF212121);
  static const Color heartColor = Color(0xFFD32F2F);
  static const Color clubColor = Color(0xFF212121);
  static const Color diamondColor = Color(0xFFD32F2F);
}

// =============================================================================
// 尺寸系统
// =============================================================================
class AppDimensions {
  AppDimensions._();

  // 扑克牌
  static const double cardWidth = 72.0;
  static const double cardHeight = 100.0;
  static const double cardCornerRadius = 6.0;
  static const double cardBorderWidth = 0.8;
  static const double cardSpacing = 28.0;
  static const double cardSpacingSelected = 16.0;
  static const double cardLiftOffset = 16.0;

  // AI手牌（背面显示）
  static const double aiCardWidth = 40.0;
  static const double aiCardHeight = 56.0;
  static const double aiCardSpacing = 10.0;

  // 出牌区
  static const double playedCardWidth = 60.0;
  static const double playedCardHeight = 84.0;
  static const double playedCardSpacing = 16.0;

  // 按钮
  static const double buttonHeight = 48.0;
  static const double buttonRadius = 24.0;
  static const double smallButtonHeight = 36.0;
  static const double smallButtonRadius = 18.0;

  // 动画时长
  static const Duration dealCardDelay = Duration(milliseconds: 80);
  static const Duration dealAnimationDuration = Duration(milliseconds: 400);
  static const Duration playAnimationDuration = Duration(milliseconds: 300);
  static const Duration selectAnimationDuration = Duration(milliseconds: 150);
  static const Duration bombAnimationDuration = Duration(milliseconds: 1200);
  static const Duration springAnimationDuration = Duration(milliseconds: 1500);
  static const Duration uiTransitionDuration = Duration(milliseconds: 250);
  static const Duration buttonPressDuration = Duration(milliseconds: 100);
  static const Duration confettiDuration = Duration(milliseconds: 3000);
  static const Duration toastDuration = Duration(milliseconds: 2000);

  // 间距
  static const double paddingXS = 4.0;
  static const double paddingSmall = 8.0;
 static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXL = 32.0;

  // 圆角
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
}

// =============================================================================
// 字符串常量
// =============================================================================
class AppStrings {
  AppStrings._();

  static const String appName = '斗地主';
  static const String fontFamily = 'NotoSansSC';

  // 主菜单
  static const String startGame = '开始游戏';
  static const String continueGame = '继续游戏';
  static const String settings = '设置';
  static const String statistics = '战绩';
  static const String achievements = '成就';
  static const String howToPlay = '玩法说明';
  static const String exit = '退出';

  // 游戏内
  static const String callLandlord = '叫地主';
  static const String dontCall = '不叫';
  static const String grabLandlord = '抢地主';
  static const String dontGrab = '不抢';
  static const String playCards = '出牌';
  static const String hint = '提示';
  static const String pass = '不要';
  static const String double = '加倍';
  static const String superDouble = '超级加倍';
  static const String dontDouble = '不加倍';

  // 游戏状态
  static const String dealing = '发牌中...';
  static const String calling = '叫地主中...';
  static const String yourTurn = '请出牌';
  static const String aiThinking = '思考中...';
  static const String gameOver = '游戏结束';

  // 结算
  static const String youWin = '你赢了！';
  static const String youLose = '你输了';
  static const String spring = '春天！';
  static const String antiSpring = '反春！';

  // 设置
  static const String difficulty = '难度';
  static const String easy = '简单';
  static const String normal = '普通';
  static const String hard = '困难';
  static const String laiziMode = '癞子模式';
  static const String soundEffects = '音效';
  static const String backgroundMusic = '背景音乐';
  static const String hapticFeedback = '震动反馈';

  // 提示
  static const String selectCardsFirst = '请先选择要出的牌';
  static const String invalidHand = '无效的牌型';
  static const String cannotBeat = '打不过上家';
  static const String mustPlay = '必须出牌（你是首家）';
  static const String notEnoughBalance = '欢乐豆不足';

  // 玩法说明
  static const String rulesTitle = '游戏规则';
  static const String rulesContent = '''
斗地主是一种三人扑克游戏。

游戏流程：
1. 每人发17张牌，留3张底牌
2. 玩家抢地主，抢到者获得底牌成为地主
3. 地主独自对抗两个农民，先出完牌的一方获胜

牌型大小：
火箭（双王）> 炸弹 > 一般牌型

倍率规则：
- 抢地主、加倍会增加倍率
- 炸弹、春天会使倍率翻倍

春天：地主出完所有牌，农民一张未出
反春：农民出完牌，地主只出过第一手
''';
}

// =============================================================================
// 动画曲线
// =============================================================================
class AppCurves {
  AppCurves._();

  static const Curve dealCard = Curves.easeOutBack;
  static const Curve playCard = Curves.easeOutCubic;
  static const Curve selectCard = Curves.easeOut;
  static const Curve buttonPress = Curves.easeInOut;
  static const Curve uiTransition = Curves.fastOutSlowIn;
  static const Curve spring = Curves.elasticOut;
  static const Curve bomb = Curves.easeOutExpo;
}

// =============================================================================
// 游戏常量
// =============================================================================
class GameConstants {
  GameConstants._();

  // 初始欢乐豆
  static const int initialBalance = 5000;
  static const int baseScore = 1;

  // 倍率
  static const int callLandlordMultiplier = 2;
  static const int grabLandlordMultiplier = 2;
  static const int doubleMultiplier = 2;
  static const int superDoubleMultiplier = 4;
  static const int bombMultiplier = 2;
  static const int springMultiplier = 2;

  // AI 延迟
  static const int aiMinDelayMs = 800;
  static const int aiMaxDelayMs = 2000;
  static const int aiHardMaxDelayMs = 3000;

  // 出牌倒计时（秒）
  static const int turnTimeoutSeconds = 20;

  // 癞子模式
  static const int laiziCount = 1;
}

// =============================================================================
// 成就配置
// =============================================================================
class AchievementConfig {
  AchievementConfig._();

  static const List<Map<String, dynamic>> all = [
    {
      'id': 'first_win',
      'name': '初出茅庐',
      'description': '获得第一场胜利',
      'icon': 'military_tech',
      'requirement': 1,
      'type': 'wins',
    },
    {
      'id': 'win_10',
      'name': '小有所成',
      'description': '累计获胜10局',
      'icon': 'emoji_events',
      'requirement': 10,
      'type': 'wins',
    },
    {
      'id': 'win_100',
      'name': '斗地主高手',
      'description': '累计获胜100局',
      'icon': 'workspace_premium',
      'requirement': 100,
      'type': 'wins',
    },
    {
      'id': 'bomb_10',
      'name': '炸弹大师',
      'description': '累计打出10个炸弹',
      'icon': 'local_fire_department',
      'requirement': 10,
      'type': 'bombs',
    },
    {
      'id': 'spring_5',
      'name': '春天制造者',
      'description': '累计打出5次春天',
      'icon': 'wb_sunny',
      'requirement': 5,
      'type': 'springs',
    },
    {
      'id': 'anti_spring_3',
      'name': '逆袭者',
      'description': '累计打出3次反春',
      'icon': 'auto_awesome',
      'requirement': 3,
      'type': 'anti_springs',
    },
    {
      'id': 'rich_100k',
      'name': '家财万贯',
      'description': '欢乐豆达到10万',
      'icon': 'account_balance',
      'requirement': 100000,
      'type': 'balance',
    },
    {
      'id': 'streak_5',
      'name': '连胜将军',
      'description': '连胜5局',
      'icon': 'local_police',
      'requirement': 5,
      'type': 'max_streak',
    },
    {
      'id': 'landlord_win_20',
      'name': '地主之王',
      'description': '当地主获胜20次',
      'icon': 'castle',
      'requirement': 20,
      'type': 'landlord_wins',
    },
    {
      'id': 'farmer_win_50',
      'name': '农民起义军',
      'description': '当农民获胜50次',
      'icon': 'groups',
      'requirement': 50,
      'type': 'farmer_wins',
    },
  ];
}
