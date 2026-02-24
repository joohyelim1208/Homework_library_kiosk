import 'dart:math';
import '../enums/enums.dart';

class PolicyService {
  /// TODO(15): 등급별 대여 가능 권수 반환. enum은 스위치문과 잘 맞는다!
  /// guest: 2, standard: 4, premium: 6
  int borrowLimitForTier(MemberTier memberTier) {
    // TODO: 구현
    switch (memberTier) {
      case MemberTier.guest:
        return 2;
      case MemberTier.standard:
        return 4;
      case MemberTier.premium:
        return 6;
      // default: 필요없음. 정확하게 필요한 기능들만 들어간 것이라 굳이 다른 예외적인 부분이 필요없음
    }
  }

  /// TODO(16): 등급별 할인율 반환
  /// guest: 0.0, standard: 0.05, premium: 0.10
  double discountRateForTier(MemberTier memberTier) {
    // TODO: 구현
    switch (memberTier) {
      case MemberTier.guest:
        return 0.0;
      case MemberTier.standard:
        return 0.05;
      case MemberTier.premium:
        return 0.10;
    }
  }

  /// TODO(17): 최종 대여료 계산
  /// - originalTotalFee에 할인율 적용
  /// - 할인 적용 후 금액이 20,000원 이상이면 추가 1,000원 할인
  /// - 최종 금액이 0원 미만이면 0으로 보정
  int calculateFinalRentalFee({
    required int originalTotalFee,
    required MemberTier memberTier,
  }) {
    // TODO: 구현
    var discountRate = discountRateForTier(memberTier);
    int discountTotal = (originalTotalFee * discountRate).toInt();
    int total = originalTotalFee - discountTotal;

    if (total >= 20000) {
      // max: 둘 중 큰 것만 반환한다.
      return max(total - 1000, 0);
    } else {
      return total;
    }
  }
}
