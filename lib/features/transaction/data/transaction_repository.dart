import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zzik_ssu/features/transaction/data/model/transaction_model.dart';

part 'transaction_repository.g.dart';

@riverpod
TransactionRepository transactionRepository(Ref ref) {
  throw UnimplementedError('Initialize this provider in main.dart');
}

class TransactionRepository {
  final Isar _isar;

  TransactionRepository(this._isar);

  Future<void> addTransaction(Transaction transaction) async {
    await _isar.writeTxn(() async {
      await _isar.transactions.put(transaction);
    });
  }

  Future<List<Transaction>> getAllTransactions() async {
    return await _isar.transactions.where().sortByDateDesc().findAll();
  }

  Stream<List<Transaction>> watchTransactions() {
    return _isar.transactions.where().sortByDateDesc().watch(
      fireImmediately: true,
    );
  }

  Future<void> deleteTransaction(Id id) async {
    await _isar.writeTxn(() async {
      await _isar.transactions.delete(id);
    });
  }
}
