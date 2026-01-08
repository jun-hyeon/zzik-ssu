import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zzik_ssu/features/transaction/data/model/transaction_model.dart';
import 'package:zzik_ssu/features/transaction/data/transaction_repository.dart';

part 'home_view_model.g.dart';

@riverpod
class HomeViewModel extends _$HomeViewModel {
  @override
  Stream<List<Transaction>> build() {
    return _watchTransactions();
  }

  Stream<List<Transaction>> _watchTransactions() {
    final repository = ref.read(transactionRepositoryProvider);
    return repository.watchTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    final repository = ref.read(transactionRepositoryProvider);
    await repository.deleteTransaction(id);
    // Isar stream will auto-update the UI
  }
}
