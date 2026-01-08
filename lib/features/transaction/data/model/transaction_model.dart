import 'package:isar/isar.dart';

part 'transaction_model.g.dart';

@collection
class Transaction {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String title; // 상호명 (예: 스타벅스)

  late int totalAmount; // 총 지출액

  @Index()
  late DateTime date; // 거래 일시

  @Index()
  late String category; // 카테고리 (식비, 교통 등)

  String? imagePath; // 영수증 이미지 경로 (Local Path)
  String? memo; // 메모

  List<TransactionItem>? items; // 1:N 관계 (Embedded)

  late DateTime createdAt; // 데이터 생성일
}

@embedded
class TransactionItem {
  late String name; // 품목명
  late int unitPrice; // 품목 단가
  int quantity = 1; // 수량
}
