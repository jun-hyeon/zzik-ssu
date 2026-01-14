import 'dart:developer';
import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zzik_ssu/features/scan/data/gemini_service.dart';
import 'package:zzik_ssu/features/scan/data/model/receipt_result.dart';
import 'package:zzik_ssu/features/scan/data/scan_repository.dart';
import 'package:zzik_ssu/features/transaction/data/model/transaction_model.dart';
import 'package:zzik_ssu/features/transaction/data/transaction_repository.dart';

part 'add_transaction_view_model.freezed.dart';
part 'add_transaction_view_model.g.dart';

@freezed
class AddTransactionState with _$AddTransactionState {
  const factory AddTransactionState({
    @Default(false) bool isLoading,
    ReceiptResult? receiptResult,
    @Default([]) List<ReceiptItem> items,
    String? imagePath,
    String? title,
    String? category,
    DateTime? date,
    int? amount,
    String? memo,
    @Default(true) bool shouldSaveImage,
  }) = _AddTransactionState;
}

@riverpod
class AddTransactionViewModel extends _$AddTransactionViewModel {
  @override
  AddTransactionState build() {
    return const AddTransactionState();
  }

  Future<void> pickAndParseImage(ImageSource source) async {
    state = state.copyWith(isLoading: true);
    try {
      // final xFile = await ref.read(scanRepositoryProvider).pickImage(source);
      // if (xFile != null) {
      //   state = state.copyWith(imagePath: xFile.path);

      //   final result = await ref
      //       .read(geminiServiceProvider)
      //       .analyzeReceipt(File(xFile.path));

      //   if (result != null) {
      //     DateTime parsedDate;
      //     try {
      //       parsedDate = DateTime.parse(result.date);
      //     } catch (_) {
      //       parsedDate = DateTime.now();
      //     }

      //     state = state.copyWith(
      //       receiptResult: result,
      //       items: result.items,
      //       title: result.storeName,
      //       date: parsedDate,
      //       amount: result.totalAmount,
      //     );
      //   }
      // }
      final file = source == ImageSource.camera
          ? await ref.read(scanRepositoryProvider).pickImageNativeFromCamera()
          : await ref.read(scanRepositoryProvider).pickImageNative();
      if (file != null) {
        state = state.copyWith(imagePath: file.path);

        final result = await ref
            .read(geminiServiceProvider)
            .analyzeReceipt(file);

        if (result != null) {
          DateTime parsedDate;
          try {
            parsedDate = DateTime.parse(result.date);
          } catch (_) {
            parsedDate = DateTime.now();
          }

          state = state.copyWith(
            receiptResult: result,
            items: result.items,
            title: result.storeName,
            date: parsedDate,
            amount: result.totalAmount,
          );
        }
      }
    } catch (e) {
      // Handle error
      // ignore: avoid_print
      // ignore: avoid_print
      log('Error parsing receipt: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  void updateAmount(int amount) {
    state = state.copyWith(amount: amount);
  }

  void updateDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  void updateCategory(String category) {
    state = state.copyWith(category: category);
  }

  void updateMemo(String memo) {
    state = state.copyWith(memo: memo);
  }

  void toggleSaveImage(bool value) {
    state = state.copyWith(shouldSaveImage: value);
  }

  void removeItem(int index) {
    final newItems = List<ReceiptItem>.from(state.items);
    newItems.removeAt(index);
    state = state.copyWith(items: newItems);
    _recalculateTotal(newItems);
  }

  void addItem(ReceiptItem item) {
    final newItems = List<ReceiptItem>.from(state.items);
    newItems.add(item);
    state = state.copyWith(items: newItems);
    _recalculateTotal(newItems);
  }

  void updateItem(int index, ReceiptItem item) {
    final newItems = List<ReceiptItem>.from(state.items);
    newItems[index] = item;
    state = state.copyWith(items: newItems);
    _recalculateTotal(newItems);
  }

  void _recalculateTotal(List<ReceiptItem> items) {
    state = state.copyWith(
      amount: items.fold<int>(
        0,
        (sum, item) => sum + (item.unitPrice * item.quantity).toInt(),
      ),
    );
  }

  Future<bool> saveTransaction() async {
    // Basic validation
    if (state.title == null || state.title!.isEmpty) {
      log('Save failed: Title is empty');
      return false;
    }
    if (state.amount == null) {
      log('Save failed: Amount is null');
      return false;
    }
    if (state.date == null) {
      log('Save failed: Date is null');
      return false;
    }

    // Default category if null
    final category = state.category ?? '기타';

    log(
      'Saving transaction: Title=${state.title}, Amount=${state.amount}, Date=${state.date}, Category=$category',
    );

    state = state.copyWith(isLoading: true);
    try {
      final transaction = Transaction()
        ..title = state.title!
        ..totalAmount = state.amount!
        ..date = state.date!
        ..category = category
        ..imagePath = state.imagePath
        ..memo = state.memo
        ..createdAt = DateTime.now();

      // Image Persistence Logic
      if (state.shouldSaveImage && state.imagePath != null) {
        try {
          final directory = await getApplicationDocumentsDirectory();
          final fileName =
              'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final savedImage = await File(
            state.imagePath!,
          ).copy('${directory.path}/$fileName');
          transaction.imagePath = savedImage.path;
          log('Image saved as: ${savedImage.path}');
        } catch (e) {
          log('Failed to save image: $e');
          // Proceed without saving image path if copy fails, or handle as needed
          transaction.imagePath = null;
        }
      } else {
        transaction.imagePath = null;
      }

      // Convert ReceiptItem (UI model) to TransactionItem (Isar model)
      final transactionItems = state.items.map((item) {
        return TransactionItem()
          ..name = item.name
          ..unitPrice = item.unitPrice
          ..quantity = item.quantity;
      }).toList();

      // Since TransactionItem is now embedded, we just assign the list
      transaction.items = transactionItems;

      await ref.read(transactionRepositoryProvider).addTransaction(transaction);

      // Reset state or handle success
      return true;
    } catch (e) {
      // ignore: avoid_print
      // ignore: avoid_print
      log('Save error: $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
