class CategoryUtils {
  static bool matchesCategory(String itemCategory, String selected) {
    if (itemCategory.isEmpty) return false;
    final cat = itemCategory.toLowerCase();
    switch (selected) {
      case 'Shirts':
        return cat.contains('top') ||
            cat.contains('shirt') ||
            cat.contains('tee') ||
            cat.contains('blouse') ||
            cat.contains('sweater') ||
            cat.contains('hoodie');
      case 'Pants':
        return cat.contains('bottom') ||
            cat.contains('pant') ||
            cat.contains('jean') ||
            cat.contains('trouser') ||
            cat.contains('short') ||
            cat.contains('skirt');
      case 'Shoes':
        return cat.contains('shoe') ||
            cat.contains('footwear') ||
            cat.contains('sneaker') ||
            cat.contains('boot');
      case 'Jackets':
        return cat.contains('jacket') ||
            cat.contains('outerwear') ||
            cat.contains('coat') ||
            cat.contains('blazer');
      case 'Accessories':
        return cat.contains('accessor') ||
            cat.contains('hat') ||
            cat.contains('cap') ||
            cat.contains('bag') ||
            cat.contains('glass') ||
            cat.contains('watch') ||
            cat.contains('belt');
      default:
        return cat == selected.toLowerCase();
    }
  }
}
