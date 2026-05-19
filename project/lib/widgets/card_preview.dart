import 'package:flutter/material.dart';
import '../models/card.dart';
import '../utils/card_painter.dart';

// =============================================================================
// 扑克牌预览组件 - 用于开发调试时查看所有牌的绘制效果
// =============================================================================

class CardPreview extends StatelessWidget {
  const CardPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20),
      appBar: AppBar(
        title: const Text('扑克牌预览'),
        backgroundColor: const Color(0xFF154A1A),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 牌背预览
              _buildSectionTitle('牌背'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  const CardBackWidget(width: 72, height: 100),
                  const CardBackWidget(width: 40, height: 56),
                ],
              ),
              const SizedBox(height: 24),

              // 王牌预览
              _buildSectionTitle('王牌'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  PlayingCardPainted(
                    card: const Card(suit: Suit.joker, rank: 14),
                    width: 72,
                    height: 100,
                  ),
                  PlayingCardPainted(
                    card: const Card(suit: Suit.joker, rank: 15),
                    width: 72,
                    height: 100,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 黑桃预览
              _buildSectionTitle('黑桃'),
              _buildSuitCards(Suit.spade),
              const SizedBox(height: 24),

              // 红桃预览
              _buildSectionTitle('红桃'),
              _buildSuitCards(Suit.heart),
              const SizedBox(height: 24),

              // 梅花预览
              _buildSectionTitle('梅花'),
              _buildSuitCards(Suit.club),
              const SizedBox(height: 24),

              // 方块预览
              _buildSectionTitle('方块'),
              _buildSuitCards(Suit.diamond),
              const SizedBox(height: 24),

              // 选中状态预览
              _buildSectionTitle('选中状态'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  PlayingCardPainted(
                    card: const Card(suit: Suit.spade, rank: 1),
                    isSelected: true,
                    width: 72,
                    height: 100,
                  ),
                  PlayingCardPainted(
                    card: const Card(suit: Suit.heart, rank: 13),
                    isSelected: true,
                    width: 72,
                    height: 100,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSuitCards(Suit suit) {
    return Wrap(
      spacing: 4,
      runSpacing: 8,
      children: [
        for (int rank = 1; rank <= 13; rank++)
          PlayingCardPainted(
            card: Card(suit: suit, rank: rank),
            width: 60,
            height: 84,
          ),
      ],
    );
  }
}
