import 'package:flutter/material.dart';
import '../models/card.dart';
import '../utils/constants.dart';
import 'playing_card_widget.dart';

/// 发牌/出牌飞入动画组件
/// 支持发牌（从中央飞向各玩家位置）和出牌（从手牌区飞向中央）

/// 动画类型枚举
enum CardAnimationType {
  deal,   // 发牌：从中央飞向玩家
  play,   // 出牌：从玩家飞向中央
}

/// 动画目标位置
enum AnimationTarget {
  center,   // 中央
  player,   // 玩家（底部）
  ai1,      // AI1（左上）
  ai2,      // AI2（右上）
}

/// 单张牌的飞入动画
class CardFlyInAnimation extends StatefulWidget {
  final PlayingCard card;
  final CardAnimationType type;
  final AnimationTarget from;
  final AnimationTarget to;
  final Duration delay;
  final VoidCallback? onComplete;
  final double cardWidth;
  final double cardHeight;
  final bool faceUp;

  const CardFlyInAnimation({
    super.key,
    required this.card,
    required this.type,
    required this.from,
    required this.to,
    this.delay = Duration.zero,
    this.onComplete,
    this.cardWidth = AppDimensions.cardWidth,
    this.cardHeight = AppDimensions.cardHeight,
    this.faceUp = true,
  });

  @override
  State<CardFlyInAnimation> createState() => _CardFlyInAnimationState();
}

class _CardFlyInAnimationState extends State<CardFlyInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.type == CardAnimationType.deal
          ? AppDimensions.dealAnimationDuration
          : AppDimensions.playAnimationDuration,
      vsync: this,
    );

    final curve = widget.type == CardAnimationType.deal
        ? AppCurves.dealCard
        : AppCurves.playCard;

    _positionAnimation = CurvedAnimation(
      parent: _controller,
      curve: curve,
    );

    _rotationAnimation = Tween<double>(
      begin: widget.type == CardAnimationType.deal ? -0.5 : 0,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.6, end: 1.1),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.1, end: 1.0),
        weight: 40,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward().then((_) {
          widget.onComplete?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _getTargetOffset(AnimationTarget target, Size size) {
    switch (target) {
      case AnimationTarget.center:
        return Offset(
          (size.width - widget.cardWidth) / 2,
          (size.height - widget.cardHeight) / 2,
        );
      case AnimationTarget.player:
        return Offset(
          (size.width - widget.cardWidth) / 2,
          size.height - widget.cardHeight - 20,
        );
      case AnimationTarget.ai1:
        return Offset(
          60,
          80,
        );
      case AnimationTarget.ai2:
        return Offset(
          size.width - widget.cardWidth - 60,
          80,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final size = MediaQuery.of(context).size;
        final fromOffset = _getTargetOffset(widget.from, size);
        final toOffset = _getTargetOffset(widget.to, size);

        final currentOffset = Offset.lerp(
          fromOffset,
          toOffset,
          _positionAnimation.value,
        )!;

        return Positioned(
          left: currentOffset.dx,
          top: currentOffset.dy,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: PlayingCardWidget(
                  card: widget.card,
                  width: widget.cardWidth,
                  height: widget.cardHeight,
                  faceUp: widget.faceUp,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 发牌动画容器
/// 管理多张牌的发牌动画序列
class DealAnimation extends StatefulWidget {
  final List<PlayingCard> cards;
  final AnimationTarget target;
  final VoidCallback? onComplete;
  final VoidCallback? onCardDealt;

  const DealAnimation({
    super.key,
    required this.cards,
    required this.target,
    this.onComplete,
    this.onCardDealt,
  });

  @override
  State<DealAnimation> createState() => _DealAnimationState();
}

class _DealAnimationState extends State<DealAnimation> {
  late List<bool> _cardCompleted;
  int _completedCount = 0;

  @override
  void initState() {
    super.initState();
    _cardCompleted = List.filled(widget.cards.length, false);
  }

  void _onCardComplete(int index) {
    if (!_cardCompleted[index]) {
      _cardCompleted[index] = true;
      _completedCount++;
      widget.onCardDealt?.call();

      if (_completedCount >= widget.cards.length) {
        widget.onComplete?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (int i = 0; i < widget.cards.length; i++)
          CardFlyInAnimation(
            card: widget.cards[i],
            type: CardAnimationType.deal,
            from: AnimationTarget.center,
            to: widget.target,
            delay: Duration(milliseconds: i * 80),
            faceUp: widget.target == AnimationTarget.player,
            onComplete: () => _onCardComplete(i),
          ),
      ],
    );
  }
}

/// 出牌动画容器
class PlayCardsAnimation extends StatefulWidget {
  final List<PlayingCard> cards;
  final AnimationTarget from;
  final VoidCallback? onComplete;

  const PlayCardsAnimation({
    super.key,
    required this.cards,
    required this.from,
    this.onComplete,
  });

  @override
  State<PlayCardsAnimation> createState() => _PlayCardsAnimationState();
}

class _PlayCardsAnimationState extends State<PlayCardsAnimation> {
  int _completedCount = 0;

  void _onCardComplete() {
    _completedCount++;
    if (_completedCount >= widget.cards.length) {
      widget.onComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardSpacing = 16.0;
    final totalWidth = widget.cards.length * AppDimensions.playedCardWidth +
        (widget.cards.length - 1) * cardSpacing;
    final startX = (screenWidth - totalWidth) / 2;

    return Stack(
      children: [
        for (int i = 0; i < widget.cards.length; i++)
          _SinglePlayAnimation(
            card: widget.cards[i],
            from: widget.from,
            targetX: startX + i * (AppDimensions.playedCardWidth + cardSpacing),
            delay: Duration(milliseconds: i * 50),
            onComplete: _onCardComplete,
          ),
      ],
    );
  }
}

class _SinglePlayAnimation extends StatefulWidget {
  final PlayingCard card;
  final AnimationTarget from;
  final double targetX;
  final Duration delay;
  final VoidCallback? onComplete;

  const _SinglePlayAnimation({
    required this.card,
    required this.from,
    required this.targetX,
    this.delay = Duration.zero,
    this.onComplete,
  });

  @override
  State<_SinglePlayAnimation> createState() => _SinglePlayAnimationState();
}

class _SinglePlayAnimationState extends State<_SinglePlayAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDimensions.playAnimationDuration,
      vsync: this,
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;

    final fromOffset = _getStartOffset(widget.from, size);
    final targetOffset = Offset(
      widget.targetX,
      (size.height - AppDimensions.playedCardHeight) / 2 - 20,
    );

    _positionAnimation = Tween<Offset>(
      begin: fromOffset,
      end: targetOffset,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppCurves.playCard,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));
  }

  Offset _getStartOffset(AnimationTarget target, Size size) {
    switch (target) {
      case AnimationTarget.center:
        return Offset(
          (size.width - AppDimensions.playedCardWidth) / 2,
          (size.height - AppDimensions.playedCardHeight) / 2,
        );
      case AnimationTarget.player:
        return Offset(
          size.width / 2 - AppDimensions.playedCardWidth / 2,
          size.height - 160,
        );
      case AnimationTarget.ai1:
        return const Offset(80, 100);
      case AnimationTarget.ai2:
        return Offset(
          size.width - AppDimensions.playedCardWidth - 80,
          100,
        );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx,
          top: _positionAnimation.value.dy,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: PlayingCardWidget(
              card: widget.card,
              width: AppDimensions.playedCardWidth,
              height: AppDimensions.playedCardHeight,
              faceUp: true,
            ),
          ),
        );
      },
    );
  }
}
