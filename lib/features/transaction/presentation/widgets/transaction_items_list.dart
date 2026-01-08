import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zzik_ssu/features/scan/data/model/receipt_result.dart';
import 'package:zzik_ssu/features/transaction/presentation/add_transaction_view_model.dart';

class TransactionItemsList extends StatelessWidget {
  final List<ReceiptItem> items;
  final AddTransactionViewModel viewModel;

  const TransactionItemsList({
    super.key,
    required this.items,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '상세 품목',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                if (items.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[100]!),
                    ),
                    child: Text(
                      '${items.length}개',
                      style: TextStyle(color: Colors.green[700], fontSize: 12),
                    ),
                  ),
                IconButton(
                  onPressed: () => _showAddItemDialog(context, viewModel),
                  icon: const Icon(Icons.add_circle_outline),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = items[index];
            return Dismissible(
              key: ValueKey('${item.name}_$index'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.delete_outline, color: Colors.red[700]),
              ),
              onDismissed: (_) => viewModel.removeItem(index),
              child: Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  title: Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    '${NumberFormat('#,###').format(item.unitPrice)}원 × ${item.quantity}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${NumberFormat('#,###').format(item.quantity * item.unitPrice)}원',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  onTap: () =>
                      _showEditItemDialog(context, viewModel, index, item),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showAddItemDialog(
    BuildContext context,
    AddTransactionViewModel viewModel,
  ) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final qtyController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('품목 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '상품명'),
              autofocus: true,
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '단가'),
            ),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '수량'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final newName = nameController.text.trim();
              final newPrice = int.tryParse(priceController.text) ?? 0;
              final newQty = int.tryParse(qtyController.text) ?? 1;

              if (newName.isEmpty) return;

              viewModel.addItem(
                ReceiptItem(
                  name: newName,
                  unitPrice: newPrice,
                  quantity: newQty,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(
    BuildContext context,
    AddTransactionViewModel viewModel,
    int index,
    ReceiptItem item,
  ) {
    final nameController = TextEditingController(text: item.name);
    final priceController = TextEditingController(
      text: item.unitPrice.toString(),
    );
    final qtyController = TextEditingController(text: item.quantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('품목 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '상품명'),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '단가'),
            ),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '수량'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final newName = nameController.text;
              final newPrice =
                  int.tryParse(priceController.text) ?? item.unitPrice;
              final newQty = int.tryParse(qtyController.text) ?? item.quantity;

              viewModel.updateItem(
                index,
                ReceiptItem(
                  name: newName,
                  unitPrice: newPrice,
                  quantity: newQty,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}
