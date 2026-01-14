import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController amountController;
  final TextEditingController memoController;
  final DateTime? date;
  final String? category;
  final List<String> categories;

  final ValueChanged<String> onTitleChanged;
  final ValueChanged<int> onAmountChanged;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onMemoChanged;

  const TransactionForm({
    super.key,
    required this.titleController,
    required this.amountController,
    required this.memoController,
    required this.date,
    required this.category,
    required this.categories,
    required this.onTitleChanged,
    required this.onAmountChanged,
    required this.onDateChanged,
    required this.onCategoryChanged,
    required this.onMemoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '기본 정보',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: titleController,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            labelText: '상호명',
            hintText: '예: 스타벅스 강남점',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.store_outlined),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          onChanged: onTitleChanged,
        ),
        const SizedBox(height: 16),

        TextField(
          controller: amountController,
          style: const TextStyle(color: Colors.black),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: '금액',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.attach_money),
            suffixText: '원',
            filled: true,
            fillColor: Colors.grey[50],
          ),
          onChanged: (val) {
            final amount = int.tryParse(val);
            if (amount != null) onAmountChanged(amount);
          },
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) onDateChanged(picked);
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: '날짜',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  child: Text(
                    date != null
                        ? DateFormat('yyyy-MM-dd').format(date!)
                        : '날짜 선택',
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: category,
                decoration: InputDecoration(
                  labelText: '카테고리',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.category_outlined),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) onCategoryChanged(val);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        TextField(
          controller: memoController,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            labelText: '메모 (선택)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.note_alt_outlined),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          maxLines: 2,
          onChanged: onMemoChanged,
        ),
      ],
    );
  }
}
