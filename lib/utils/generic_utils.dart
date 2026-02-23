/// TODO(18): 조건에 맞는 첫 번째 요소 반환 (없으면 null)
T? findFirst<T>(List<T> items, bool Function(T item) condition) {
  // TODO: 구현
  for (var item in items) {
    // 만약 컨디션에 들어있는 아이템이 참일 경우
    if (condition(item)) {
      return item;
    }
  }
  return null;
}

/// TODO(19): selector로 값 변환 후 총합 계산
int sumBy<T>(List<T> items, int Function(T item) selector) {
  // TODO: 구현
  int total = 0;
  for (var item in items) {
    total += selector(item);
  }
  return total;
}
