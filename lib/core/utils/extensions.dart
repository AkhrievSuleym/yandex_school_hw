extension IterableX<T> on Iterable<T> {
  /// Возвращает первый элемент, который удовлетворяет [test], или null, если ни один элемент не найден.
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
