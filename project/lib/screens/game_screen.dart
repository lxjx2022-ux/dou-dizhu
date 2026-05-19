import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/extensions.dart';
import '../utils/card_images.dart';
import '../models/card.dart';
import '../models/game_state.dart';
import '../models/difficulty.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';
import '../widgets/poker_table.dart';
import '../widgets/glassmorphic_panel.dart';
import '../widgets/playing_card_widget.dart';
import '../widgets/game_button.dart';
import '../widgets/icon_button.dart';
import '../widgets/chip_display.dart';
import '../widgets/timer_bar.dart';
import '../widgets/bomb_effect.dart';
import '../widgets/confetti_effect.dart';
import 'pause_screen.dart';
import 'home_screen.dart';

/// 游戏主界面（横屏）
/// 核心游戏界面，包含玩家手牌、AI区域、中央游戏区、操作按钮
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  // 服务
  final StorageService _storage = StorageService();
  final AudioService _audio = AudioService();
  final HapticService _haptic = HapticService();

  // 游戏状态
  final GameState _gameState = GameState();

  // 选中的牌索引
  final Set<int> _selectedCardIndices = {};

  // UI 状态
  bool _isPaused = false;
  bool _showBombEffect = false;
  bool _showSpringEffect = false;
  bool _showConfetti = false;
  bool _isAiThinking = false;
  int _turnTimer = 20;

  // 动画控制器
  late AnimationController _aiPulseController;
  late AnimationController _timerController;

  // 演示数据
  late List<PlayingCard> _demoHand;
  late List<PlayingCard> _demoAi1Cards;
  late List<PlayingCard> _demoAi2Cards;
  late List<PlayingCard> _demoLandlordCards;
  late List<PlayingCard> _demoPlayedCards;
  int _demoAi1Count = 17;
  int _demoAi2Count = 17;

  @override
  void initState() {
    super.initState();
    _initGame();

    _aiPulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    _startTurnTimer();
  }

  void _initGame() {
    // 生成演示手牌
    final random = math.Random();
    final suits = [Suit.spade, Suit.heart, Suit.club, Suit.diamond];

    _demoHand = List.generate(17, (i) {
      return PlayingCard(
        suit: suits[random.nextInt(4)],
        rank: 1 + random.nextInt(13),
      );
    });
    _demoHand.sortForGame();

    _demoAi1Cards = List.generate(17, (i) {
      return PlayingCard(
        suit: suits[random.nextInt(4)],
        rank: 1 + random.nextInt(13),
      );
    });

    _demoAi2Cards = List.generate(17, (i) {
      return PlayingCard(
        suit: suits[random.nextInt(4)],
        rank: 1 + random.nextInt(13),
      );
    });

    _demoLandlordCards = List.generate(3, (i) {
      return PlayingCard(
        suit: Suit.joker,
        rank: 14 + i % 2,
      );
    });

    _demoPlayedCards = [
      const PlayingCard(suit: Suit.spade, rank: 5),
      const PlayingCard(suit: Suit.heart, rank: 6),
      const PlayingCard(suit: Suit.diamond, rank: 7),
    ];

    _gameState.phase = GamePhase.callingLandlord;
    _gameState.currentTurn = 0;
  }

  void _startTurnTimer() {
    _turnTimer = 20;
    _timerController.forward(from: 0);
  }

  @override
  void dispose() {
    _aiPulseController.dispose();
    _timerController.dispose();
    super.dispose();
  }

  void _toggleCardSelection(int index) {
    setState(() {
      if (_selectedCardIndices.contains(index)) {
        _selectedCardIndices.remove(index);
      } else {
        _selectedCardIndices.add(index);
      }
    });
    _haptic.selectionClick();
    _audio.playClick();
  }

  void _playSelectedCards() {
    if (_selectedCardIndices.isEmpty) return;

    _audio.playPlayCard();
    _haptic.mediumImpact();

    setState(() {
      // 从手牌中移除选中的牌
      final sortedIndices = _selectedCardIndices.toList()..sort((a, b) => b.compareTo(a));
      _demoPlayedCards = sortedIndices.map((i) => _demoHand[i]).toList();
      for (final i in sortedIndices) {
        _demoHand.removeAt(i);
      }
      _selectedCardIndices.clear();
      _isAiThinking = true;
    });

    _startTurnTimer();

    // 模拟AI思考
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isAiThinking = false;
        });
      }
    });
  }

  void _pass() {
    _audio.playPass();
    setState(() {
      _selectedCardIndices.clear();
      _isAiThinking = true;
    });
    _startTurnTimer();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isAiThinking = false);
      }
    });
  }

  void _callLandlord(bool call) {
    _audio.playClick();
    setState(() {
      _gameState.phase = GamePhase.playing;
      if (call) {
        _gameState.landlordIndex = 0;
        _gameState.playerRoles[0] = PlayerRole.landlord;
        _gameState.playerRoles[1] = PlayerRole.farmer;
        _gameState.playerRoles[2] = PlayerRole.farmer;
        // 获得底牌
        _demoHand.addAll(_demoLandlordCards);
        _demoHand.sortForGame();
        _demoLandlordCards.clear();
      }
    });
  }

  void _showPauseMenu() {
    _audio.playClick();
    setState(() => _isPaused = true);
  }

  void _resumeGame() {
    setState(() => _isPaused = false);
  }

  void _restartGame() {
    setState(() {
      _isPaused = false;
      _selectedCardIndices.clear();
      _showBombEffect = false;
      _showSpringEffect = false;
      _showConfetti = false;
      _isAiThinking = false;
    });
    _initGame();
    _startTurnTimer();
  }

  void _quitToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  void _triggerBomb() {
    setState(() => _showBombEffect = true);
  }

  void _triggerSpring() {
    setState(() => _showSpringEffect = true);
  }

  void _triggerConfetti() {
    setState(() => _showConfetti = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 牌桌背景
          const PokerTable(),

          // 游戏内容
          SafeArea(
            child: Column(
              children: [
                // 顶部栏
                _buildTopBar(),

                // AI1 区域
                _buildAi1Area(),

                // 中央游戏区
                Expanded(
                  child: _buildCenterArea(),
                ),

                // 操作按钮区
                _buildActionButtons(),

                // 玩家手牌区
                _buildPlayerHand(),
              ],
            ),
          ),

          // 炸弹特效
          if (_showBombEffect)
            BombEffect(
              onComplete: () => setState(() => _showBombEffect = false),
            ),

          // 春天特效
          if (_showSpringEffect)
            SpringEffect(
              onComplete: () => setState(() => _showSpringEffect = false),
            ),

          // 彩纸特效
          if (_showConfetti)
            ConfettiEffect(
              onComplete: () => setState(() => _showConfetti = false),
            ),

          // 暂停覆盖层
          if (_isPaused)
            PauseScreen(
              onResume: _resumeGame,
              onRestart: _restartGame,
              onQuit: _quitToHome,
            ),
        ],
      ),
    );
  }

  // ─── 顶部栏 ───
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: 4,
      ),
      child: Row(
        children: [
          // 返回按钮
          GameIconButton(
            icon: Icons.arrow_back,
            onPressed: _showPauseMenu,
            size: 36,
          ),
          const SizedBox(width: 8),
          // 设置按钮
          GameIconButton(
            icon: Icons.settings,
            onPressed: () {
              _audio.playClick();
              _showPauseMenu();
            },
            size: 36,
          ),
          const Spacer(),
          // 欢乐豆
          GlassmorphicPanel(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            borderRadius: 18,
            child: ChipDisplay(
              amount: _storage.getBalance(),
              fontSize: 15,
              iconSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  // ─── AI1 区域（左上） ───
  Widget _buildAi1Area() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4),
      child: Row(
        children: [
          // AI1 信息
          _buildAiInfo(
            name: 'AI - 东方',
            avatar: 'assets/images/avatar/ai_1.png',
            cardCount: _demoAi1Count,
            isThinking: _gameState.currentTurn == 1 && _isAiThinking,
          ),
        ],
      ),
    );
  }

  // ─── 中央区域 ───
  Widget _buildCenterArea() {
    return Stack(
      children: [
        // AI2 信息（右上）
        Positioned(
          top: 0,
          right: 16,
          child: _buildAiInfo(
            name: 'AI - 西方',
            avatar: 'assets/images/avatar/ai_2.png',
            cardCount: _demoAi2Count,
            isThinking: _gameState.currentTurn == 2 && _isAiThinking,
          ),
        ),

        // 中央内容
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 底牌区域
              if (_demoLandlordCards.isNotEmpty)
                _buildLandlordCards()
              else
                const SizedBox(height: 50),

              const SizedBox(height: 16),

              // 出牌展示区
              _buildPlayedCardsArea(),

              const SizedBox(height: 16),

              // 状态信息
              if (_isAiThinking)
                _buildThinkingIndicator(),
            ],
          ),
        ),
      ],
    );
  }

  // ─── AI 信息组件 ───
  Widget _buildAiInfo({
    required String name,
    required String avatar,
    required int cardCount,
    required bool isThinking,
  }) {
    return GlassmorphicPanel(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: 12,
      blurStrength: 10,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 头像
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade700,
              shape: BoxShape.circle,
              border: Border.all(
                color: isThinking
                    ? AppColors.primaryButton
                    : Colors.white.withOpacity(0.3),
                width: isThinking ? 2 : 1,
              ),
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white70,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontFamily: AppStrings.fontFamily,
                ),
              ),
              Text(
                '$cardCount 张',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontFamily: AppStrings.fontFamily,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          // 背面牌堆示意
          if (cardCount > 0)
            SizedBox(
              width: 30,
              height: 40,
              child: Stack(
                children: [
                  for (int i = 0; i < math.min(3, cardCount); i++)
                    Positioned(
                      left: i * 4.0,
                      child: Container(
                        width: 24,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A3A5C),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 0.8,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ─── 底牌区域 ───
  Widget _buildLandlordCards() {
    return GlassmorphicPanel(
      padding: const EdgeInsets.all(8),
      borderRadius: 10,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '底牌',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontFamily: AppStrings.fontFamily,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: _demoLandlordCards
                .map((card) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: PlayingCardWidget(
                        card: card,
                        width: 44,
                        height: 62,
                        faceUp: _gameState.phase != GamePhase.callingLandlord,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ─── 出牌展示区 ───
  Widget _buildPlayedCardsArea() {
    return GlassmorphicPanel(
      width: 280,
      height: 110,
      padding: const EdgeInsets.all(8),
      borderRadius: 12,
      backgroundColor: const Color(0x4D000000),
      child: _demoPlayedCards.isNotEmpty
          ? Center(
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: _demoPlayedCards
                    .map((card) => PlayingCardWidget(
                          card: card,
                          width: 50,
                          height: 70,
                          faceUp: true,
                        ))
                    .toList(),
              ),
            )
          : const Center(
              child: Text(
                '等待出牌...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontFamily: AppStrings.fontFamily,
                ),
              ),
            ),
    );
  }

  // ─── 思考中指示器 ───
  Widget _buildThinkingIndicator() {
    return AnimatedBuilder(
      animation: _aiPulseController,
      builder: (context, child) {
        return Opacity(
          opacity: 0.5 + _aiPulseController.value * 0.5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '思考中...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontFamily: AppStrings.fontFamily,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── 操作按钮区 ───
  Widget _buildActionButtons() {
    if (_gameState.phase == GamePhase.callingLandlord) {
      return _buildLandlordCallButtons();
    }

    if (_gameState.phase != GamePhase.playing) {
      return const SizedBox(height: 56);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 倒计时
          TimerBar(
            totalSeconds: 20,
            remainingSeconds: _turnTimer,
            width: 80,
          ),
          const SizedBox(width: 16),

          // 提示按钮
          GameSmallButton(
            text: AppStrings.hint,
            onPressed: () {
              _audio.playClick();
              _haptic.buttonPress();
            },
            type: GameButtonType.secondary,
          ),
          const SizedBox(width: 8),

          // 不要按钮
          GameSmallButton(
            text: AppStrings.pass,
            onPressed: _pass,
            type: GameButtonType.danger,
          ),
          const SizedBox(width: 8),

          // 出牌按钮
          GameSmallButton(
            text: AppStrings.playCards,
            onPressed: _selectedCardIndices.isNotEmpty ? _playSelectedCards : null,
            type: GameButtonType.primary,
          ),
        ],
      ),
    );
  }

  // ─── 叫地主按钮 ───
  Widget _buildLandlordCallButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GameSmallButton(
            text: AppStrings.dontCall,
            onPressed: () => _callLandlord(false),
            type: GameButtonType.danger,
          ),
          const SizedBox(width: 16),
          GameButton(
            text: AppStrings.callLandlord,
            onPressed: () => _callLandlord(true),
            type: GameButtonType.primary,
            width: 120,
            height: AppDimensions.smallButtonHeight,
          ),
        ],
      ),
    );
  }

  // ─── 玩家手牌区 ───
  Widget _buildPlayerHand() {
    if (_demoHand.isEmpty) {
      return const SizedBox(height: 80);
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final maxCardWidth = AppDimensions.cardWidth;
    final overlapSpacing = math.min(
      AppDimensions.cardSpacing,
      (screenWidth - 40 - maxCardWidth) / (_demoHand.length - 1),
    );
    final totalWidth = maxCardWidth + overlapSpacing * (_demoHand.length - 1);
    final startX = (screenWidth - totalWidth) / 2;

    return Container(
      height: AppDimensions.cardHeight + 30,
      padding: const EdgeInsets.only(bottom: 8),
      child: Stack(
        children: [
          for (int i = 0; i < _demoHand.length; i++)
            Positioned(
              left: startX + i * overlapSpacing,
              bottom: 0,
              child: GestureDetector(
                onTap: () => _toggleCardSelection(i),
                child: PlayingCardWidget(
                  card: _demoHand[i],
                  isSelected: _selectedCardIndices.contains(i),
                  faceUp: true,
                  onTap: () => _toggleCardSelection(i),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
