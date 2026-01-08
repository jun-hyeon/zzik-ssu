import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zzik_ssu/features/transaction/presentation/add_transaction_view_model.dart';
import 'package:zzik_ssu/features/transaction/presentation/widgets/transaction_form.dart';
import 'package:zzik_ssu/features/transaction/presentation/widgets/transaction_image_header.dart';
import 'package:zzik_ssu/features/transaction/presentation/widgets/transaction_items_list.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();

  final List<String> _categories = ['식비', '교통', '쇼핑', '의료', '주거', '기타'];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to state changes to populate fields
    ref.listen(addTransactionViewModelProvider, (previous, next) {
      if (previous?.title != next.title && next.title != null) {
        _titleController.text = next.title!;
      }
      if (previous?.amount != next.amount && next.amount != null) {
        _amountController.text = next.amount.toString();
      }
    });

    final state = ref.watch(addTransactionViewModelProvider);
    final viewModel = ref.read(addTransactionViewModelProvider.notifier);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('AI 영수증 등록'),
            actions: [
              TextButton(
                onPressed: state.isLoading
                    ? null
                    : () async {
                        final success = await viewModel.saveTransaction();
                        if (context.mounted) {
                          if (success) {
                            context.pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('필수 정보를 모두 입력해주세요.'),
                              ),
                            );
                          }
                        }
                      },
                child: const Text('저장', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Image Header
                TransactionImageHeader(
                  imagePath: state.imagePath,
                  onImagePick: viewModel.pickAndParseImage,
                ),
                const SizedBox(height: 24),

                // 2. Transaction Form
                TransactionForm(
                  titleController: _titleController,
                  amountController: _amountController,
                  memoController: _memoController,
                  date: state.date,
                  category: state.category,
                  categories: _categories,
                  onTitleChanged: viewModel.updateTitle,
                  onAmountChanged: viewModel.updateAmount,
                  onDateChanged: viewModel.updateDate,
                  onCategoryChanged: viewModel.updateCategory,
                  onMemoChanged: viewModel.updateMemo,
                ),
                const SizedBox(height: 32),

                // 3. Items List
                TransactionItemsList(items: state.items, viewModel: viewModel),
                const SizedBox(height: 24),

                // 4. Save Image Option
                if (state.imagePath != null)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CheckboxListTile(
                      value: state.shouldSaveImage,
                      onChanged: (val) {
                        if (val != null) viewModel.toggleSaveImage(val);
                      },
                      title: const Text(
                        '영수증 사진 저장',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: const Text('앱에 사진을 안전하게 보관합니다.'),
                      secondary: const Icon(Icons.save_alt, color: Colors.blue),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                const SizedBox(height: 48), // Bottom padding
              ],
            ),
          ),
        ),

        // Loading Overlay
        if (state.isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Gemini가 영수증을 분석하고 있어요...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      shadows: [Shadow(blurRadius: 8, color: Colors.black45)],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '잠시만 기다려주세요',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
