import '../models/card.dart';

/// 扑克牌相关的 Dart 扩展方法集合

/// List<Card> 扩展
extension CardListExtensions on List<Card> {
  /// 按牌力值升序排序
  void sortByValue() {
    sort((a, b) {
      int valueCompare = a.value.compareTo(b.value);
      if (valueCompare != 0) return valueCompare;
      return a.suit.index.compareTo(b.suit.index);
    });
  }

  /// 按牌力值降序排序
  void sortByValueDesc() {
    sort((a, b) {
      int valueCompare = b.value.compareTo(a.value);
      if (valueCompare != 0) return valueCompare;
      return b.suit.index.compareTo(a.suit.index);
    });
  }

  /// 获取指定牌力值的所有牌
  List<Card> getByValue(int value) {
    return where((card) => card.value == value).toList();
  }

  /// 获取指定点数的所有牌（忽略癞子标记）
  List<Card> getByRank(int rank) {
    return where((card) => card.rank == rank).toList();
  }

  /// 获取指定花色的所有牌
  List<Card> getBySuit(Suit suit) {
    return where((card) => card.suit == suit).toList();
  }

  /// 获取所有癞子牌
  List<Card> get laiZiCards => where((card) => card.isLaiZi).toList();

  /// 获取所有非癞子牌
  List<Card> get nonLaiZiCards => where((card) => !card.isLaiZi).toList();

  /// 是否有癞子牌
  bool get hasLaiZi => any((card) => card.isLaiZi);

  /// 获取最大牌力值
  int get maxValue => isEmpty ? 0 : map((c) => c.value).reduce((a, b) => a > b ? a : b);

  /// 获取最小牌力值
  int get minValue => isEmpty ? 0 : map((c) => c.value).reduce((a, b) => a < b ? a : b);

  /// 按牌力值分组的映射
  Map<int, List<Card>> groupByValue() {
    final map = <int, List<Card>>{};
    for (final card in this) {
      map.putIfAbsent(card.value, () => []).add(card);
    }
    return map;
  }

  /// 按点数分组的映射
  Map<int, List<Card>> groupByRank() {
    final map = <int, List<Card>>{};
    for (final card in this) {
      map.putIfAbsent(card.rank, () => []).add(card);
    }
    return map;
  }

  /// 获取牌力值出现次数统计
  Map<int, int> valueCounts() {
    final counts = <int, int>{};
    for (final card in this) {
      counts[card.value] = (counts[card.value] ?? 0) + 1;
    }
    return counts;
  }

  /// 获取指定数量（几张相同）的牌的牌力值列表
  /// 例如 count=2 返回所有有对子的牌力值
  List<int> valuesWithCount(int count) {
    final counts = valueCounts();
    return counts.entries
        .where((e) => e.value >= count)
        .map((e) => e.key)
        .toList();
  }

  /// 复制列表
  List<Card> clone() => List.from(this);

  /// 移除一张指定牌力值的牌，返回移除的牌
  Card? removeFirstByValue(int value) {
    final index = indexWhere((card) => card.value == value);
    if (index >= 0) {
      return removeAt(index);
    }
    return null;
  }

  /// 移除一张指定点数的牌
  Card? removeFirstByRank(int rank) {
    final index = indexWhere((card) => card.rank == rank);
    if (index >= 0) {
      return removeAt(index);
    }
    return null;
  }

  /// 查找比指定牌力值大的、数量足够的牌力值
  /// 用于找可以压过的牌
  List<int> findHigherValues(int minValue, int requiredCount) {
    final counts = valueCounts();
    return counts.entries
        .where((e) => e.key > minValue && e.value >= requiredCount)
        .map((e) => e.key)
        .toList();
  }

  /// 打印调试信息
  String toDebugString() => map((c) => c.toString()).join(' ');

  /// 转换为简洁字符串
  String toShortString() {
    if (isEmpty) return '';
    sortByValue();
    return map((c) => '${c.suitSymbol}${c.displayName}').join(' ');
  }
}

/// 整数列表扩展（用于牌力值操作）
extension IntListExtensions on List<int> {
  /// 检查是否构成连续序列
  /// minLength: 最小连续长度要求
  /// 返回连续序列的长度（从起始值开始），0 表示不连续
  int get consecutiveLength {
    if (isEmpty) return 0;
    final sorted = toList()..sort();
    int consecutive = 1;
    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i] == sorted[i - 1] + 1) {
        consecutive++;
      } else if (sorted[i] != sorted[i - 1]) {
        break;
      }
    }
    return consecutive;
  }

  /// 找到最长的连续子序列
  /// 返回 [起始值, 长度] 的列表
  List<List<int>> findConsecutiveSequences(int minLength) {
    if (isEmpty) return [];
    final sorted = toSet().toList()..sort();
    final result = <List<int>>[];

    int start = sorted.first;
    int count = 1;

    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i] == sorted[i - 1] + 1) {
        count++;
      } else {
        if (count >= minLength) {
          result.add([start, count]);
        }
        start = sorted[i];
        count = 1;
      }
    }

    // 处理最后一个序列
    if (count >= minLength) {
      result.add([start, count]);
    }

    return result;
  }

  /// 移除指定值的一个实例
  bool removeOne(int value) {
    final index = indexOf(value);
    if (index >= 0) {
      removeAt(index);
      return true;
    }
    return false;
  }
}

/// Map 扩展
extension MapExtensions<K, V> on Map<K, V> {
  /// 按键排序并返回新 Map
  Map<K, V> sortedByKey(int Function(K a, K b) compare) {
    final entries = this.entries.toList()..sort((a, b) => compare(a.key, b.key));
    return Map.fromEntries(entries);
  }

  /// 按值排序并返回新 Map
  Map<K, V> sortedByValue(int Function(V a, V b) compare) {
    final entries = this.entries.toList()..sort((a, b) => compare(a.value, b.value));
    return Map.fromEntries(entries);
  }
}
