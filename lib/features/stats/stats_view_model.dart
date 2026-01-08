import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zzik_ssu/features/transaction/data/model/transaction_model.dart';
import 'package:zzik_ssu/features/transaction/data/transaction_repository.dart';

part 'stats_view_model.g.dart';

@riverpod
class StatsViewModel extends _$StatsViewModel {
  @override
  Stream<List<Transaction>> build() {
    final repository = ref.read(transactionRepositoryProvider);
    return repository.watchTransactions();
  }
}
