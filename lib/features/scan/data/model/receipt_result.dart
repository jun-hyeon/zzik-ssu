class ReceiptResult {
  final String storeName;
  final String date; // YYYY-MM-DD
  final int totalAmount;
  final List<ReceiptItem> items;

  ReceiptResult({
    required this.storeName,
    required this.date,
    required this.totalAmount,
    required this.items,
  });

  factory ReceiptResult.fromJson(Map<String, dynamic> json) {
    return ReceiptResult(
      storeName: json['storeName'] ?? '상호 미상',
      date: json['date'] ?? '',
      totalAmount: json['totalAmount'] ?? 0,
      items:
          (json['items'] as List?)
              ?.map((e) => ReceiptItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ReceiptItem {
  final String name; // 상품명
  final int unitPrice; // 단가 (또는 금액)
  final int quantity; // 수량

  ReceiptItem({
    required this.name,
    required this.unitPrice,
    required this.quantity,
  });

  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
      name: json['name'] ?? '',
      unitPrice: json['price'] ?? 0,
      quantity: json['qty'] ?? 1,
    );
  }
}
