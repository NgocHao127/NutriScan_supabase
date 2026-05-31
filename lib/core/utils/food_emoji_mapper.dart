import 'dart:ui';

class FoodEmojiMapper {
  // Map cố định — lookup O(1)
  static const Map<String, String> _emojiMap = {
    // Cơm & xôi
    'cơm': '🍚',
    'xôi': '🍙',
    'cháo': '🥣',
    // Mì & bún
    'phở': '🍜',
    'bún': '🍜',
    'mì': '🍝',
    'miến': '🍜',
    'hủ tiếu': '🍜',
    // Bánh — cụ thể trước
    'bánh mì': '🥖',
    'bánh bao': '🥟',
    'bánh cuốn': '🫔',
    'bánh xèo': '🥞',
    'bánh chưng': '🎍',
    'bánh tét': '🎍',
    'bánh canh': '🍲',
    'bánh': '🧆',
    // Thịt
    'thịt heo': '🥩',
    'thịt lợn': '🥩',
    'thịt bò': '🥩',
    'thịt gà': '🍗',
    'thịt vịt': '🦆',
    'sườn': '🍖',
    'chả': '🌯',
    'nem': '🌯',
    'thịt': '🍖',
    // Hải sản
    'cá': '🐟',
    'tôm': '🦐',
    'cua': '🦀',
    'mực': '🦑',
    'hàu': '🦪',
    'nghêu': '🦪',
    'sò': '🦪',
    // Trứng & đậu
    'trứng': '🥚',
    'đậu phụ': '🟨',
    'đậu hũ': '🟨',
    // Rau & củ
    'rau muống': '🥬',
    'cải': '🥦',
    'cà rốt': '🥕',
    'cà chua': '🍅',
    'khoai lang': '🍠',
    'khoai tây': '🥔',
    'bắp': '🌽',
    'ngô': '🌽',
    'dưa leo': '🥒',
    'dưa chuột': '🥒',
    'ớt': '🌶️',
    'hành': '🧅',
    'tỏi': '🧄',
    'nấm': '🍄',
    'rau': '🥬',
    // Canh & lẩu
    'canh': '🍲',
    'lẩu': '🫕',
    'súp': '🥣',
    // Cách chế biến
    'chiên': '🍳',
    'rán': '🍳',
    'nướng': '🔥',
    'xào': '🥘',
    // Trái cây
    'chuối': '🍌',
    'táo': '🍎',
    'cam': '🍊',
    'xoài': '🥭',
    'dứa': '🍍',
    'thơm': '🍍',
    'dưa hấu': '🍉',
    'nho': '🍇',
    'dâu': '🍓',
    'bơ': '🥑',
    // Đồ uống
    'cà phê': '☕',
    'trà': '🍵',
    'sinh tố': '🥤',
    'nước mía': '🧃',
    'bia': '🍺',
    'sữa': '🥛',
    'nước': '💧',
    // Đồ ngọt
    'chè': '🍮',
    'kem': '🍦',
    // Đồ ăn nhanh
    'pizza': '🍕',
    'burger': '🍔',
    'hamburger': '🍔',
    'hotdog': '🌭',
    'sandwich': '🥪',
    'salad': '🥗',
  };

  static const Map<String, String> _categoryMap = {
    'cơm': 'Tinh bột',
    'xôi': 'Tinh bột',
    'bún': 'Tinh bột',
    'phở': 'Tinh bột',
    'mì': 'Tinh bột',
    'bánh mì': 'Tinh bột',
    'khoai': 'Tinh bột',
    'bánh': 'Tinh bột',
    'thịt': 'Đạm',
    'cá': 'Đạm',
    'tôm': 'Đạm',
    'trứng': 'Đạm',
    'đậu phụ': 'Đạm',
    'đậu hũ': 'Đạm',
    'rau': 'Vitamin',
    'cải': 'Vitamin',
    'cà rốt': 'Vitamin',
    'cà chua': 'Vitamin',
    'trái cây': 'Vitamin',
    'dưa': 'Vitamin',
    'sữa': 'Canxi',
    'phô mai': 'Canxi',
    'dầu': 'Chất béo',
    'mỡ': 'Chất béo',
    'bơ': 'Chất béo',
  };

  static const Map<String, int> _categoryColorMap = {
    'Tinh bột': 0xFFE67E22,
    'Đạm': 0xFFE74C3C,
    'Vitamin': 0xFF27AE60,
    'Canxi': 0xFF2980B9,
    'Chất béo': 0xFFF39C12,
    'Khác': 0xFF4C9A15,
  };

  /// Tra cứu emoji — key dài/cụ thể match trước
  static String getEmoji(String foodName) {
    final name = foodName.toLowerCase().trim();
    // Sắp xếp key theo độ dài giảm dần để key dài match trước
    final sortedKeys = _emojiMap.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final key in sortedKeys) {
      if (name.contains(key)) return _emojiMap[key]!;
    }
    return '🍽️';
  }

  static String getCategory(String foodName) {
    final name = foodName.toLowerCase().trim();
    final sortedKeys = _categoryMap.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final key in sortedKeys) {
      if (name.contains(key)) return _categoryMap[key]!;
    }
    return 'Khác';
  }

  static Color getCategoryColor(String foodName) {
    final category = getCategory(foodName);
    final hex = _categoryColorMap[category] ?? _categoryColorMap['Khác']!;
    return Color(hex);
  }
}
