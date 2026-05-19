import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import '../models/card.dart' as card_model;
import 'card_painter.dart';

// =============================================================================
// 扑克牌图片导出工具
// =============================================================================
// 将 Flutter CustomPainter 绘制的扑克牌导出为 PNG 图片文件
//
// 使用方式（仅在开发调试时使用）：
// ```dart
// await CardImageExporter.exportAllCards(outputDir: '/path/to/output');
// ```

class CardImageExporter {
  CardImageExporter._();

  static const int _exportWidth = 288; // 4x 渲染尺寸 (72 * 4)
  static const int _exportHeight = 400; // 4x 渲染尺寸 (100 * 4)

  /// 导出单张牌为 PNG
  static Future<Uint8List> exportCard(card_model.Card card) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final painter = CardPainter(card: card, faceUp: true);

    painter.paint(
      canvas,
      const Size(_exportWidth.toDouble(), _exportHeight.toDouble()),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(_exportWidth, _exportHeight);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('Failed to encode card as PNG: ${card.displayName}${card.suitSymbol}');
    }

    return byteData.buffer.asUint8List();
  }

  /// 导出牌背为 PNG
  static Future<Uint8List> exportCardBack() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final painter = CardPainter(faceUp: false);

    painter.paint(
      canvas,
      const Size(_exportWidth.toDouble(), _exportHeight.toDouble()),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(_exportWidth, _exportHeight);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('Failed to encode card back as PNG');
    }

    return byteData.buffer.asUint8List();
  }

  /// 导出所有 54 张牌 + 牌背
  static Future<Map<String, String>> exportAllCards({
    required String outputDir,
  }) async {
    final results = <String, String>{};

    // 确保输出目录存在
    final dir = Directory(outputDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    // 导出牌背
    final backBytes = await exportCardBack();
    final backPath = '$outputDir/back.png';
    File(backPath).writeAsBytesSync(backBytes);
    results['back'] = backPath;

    // 导出大小王
    final smallJoker = const card_model.Card(
      suit: card_model.Suit.joker,
      rank: 14,
    );
    final smallJokerBytes = await exportCard(smallJoker);
    final smallJokerPath = '$outputDir/joker_black.png';
    File(smallJokerPath).writeAsBytesSync(smallJokerBytes);
    results['joker_black'] = smallJokerPath;

    final bigJoker = const card_model.Card(
      suit: card_model.Suit.joker,
      rank: 15,
    );
    final bigJokerBytes = await exportCard(bigJoker);
    final bigJokerPath = '$outputDir/joker_red.png';
    File(bigJokerPath).writeAsBytesSync(bigJokerBytes);
    results['joker_red'] = bigJokerPath;

    // 导出52张标准牌
    for (final suit in [
      card_model.Suit.spade,
      card_model.Suit.heart,
      card_model.Suit.club,
      card_model.Suit.diamond,
    ]) {
      for (int rank = 1; rank <= 13; rank++) {
        final card = card_model.Card(suit: suit, rank: rank);
        final bytes = await exportCard(card);
        final fileName = '${card.displayName}_${card.suitFileName}.png';
        final filePath = '$outputDir/$fileName';
        File(filePath).writeAsBytesSync(bytes);
        results[fileName] = filePath;
      }
    }

    return results;
  }

  /// 导出到应用文档目录的 assets/cards/ 下
  static Future<Map<String, String>> exportToAppDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cardsDir = '${appDir.path}/assets/cards';
    return exportAllCards(outputDir: cardsDir);
  }

  /// 获取导出尺寸信息
  static Map<String, int> get exportDimensions => {
        'width': _exportWidth,
        'height': _exportHeight,
        'scale': 4, // 相对于显示尺寸 (72x100) 的缩放比例
      };
}
