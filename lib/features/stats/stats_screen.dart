import 'dart:developer';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:zzik_ssu/features/stats/stats_view_model.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  int touchedIndex = -1;
  DateTime selectedDate = DateTime.now();

  void _incrementMonth() {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month + 1);
    });
  }

  void _decrementMonth() {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(statsViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('통계')),
      body: transactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(child: Text('데이터가 없습니다.'));
          }

          log('StatsScreen Debug: SelectedDate=$selectedDate');

          final currentMonthTransactions = transactions.where((t) {
            return t.date.year == selectedDate.year &&
                t.date.month == selectedDate.month;
          }).toList();

          log(
            'Filtered transactions count: ${currentMonthTransactions.length}',
          );

          if (currentMonthTransactions.isEmpty) {
            return Column(
              children: [
                _buildMonthSelector(),
                const Expanded(
                  child: Center(child: Text('해당 월의 지출 내역이 없습니다.')),
                ),
              ],
            );
          }

          final totalAmount = currentMonthTransactions.fold<int>(
            0,
            (sum, item) => sum + item.totalAmount,
          );

          // Group by Category
          final categoryStats = <String, int>{};
          for (var t in currentMonthTransactions) {
            final category = t.category;
            categoryStats[category] =
                (categoryStats[category] ?? 0) + t.totalAmount;
          }

          final sortedCategories = categoryStats.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Month Header
                _buildMonthSelector(),

                // Pie Chart
                SizedBox(
                  height: 250,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback:
                                (FlTouchEvent event, pieTouchResponse) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions ||
                                        pieTouchResponse == null ||
                                        pieTouchResponse.touchedSection ==
                                            null) {
                                      touchedIndex = -1;
                                      return;
                                    }
                                    touchedIndex = pieTouchResponse
                                        .touchedSection!
                                        .touchedSectionIndex;
                                  });
                                },
                          ),
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 2,
                          centerSpaceRadius: 50,
                          sections: List.generate(sortedCategories.length, (i) {
                            final entry = sortedCategories[i];
                            final isTouched = i == touchedIndex;
                            final fontSize = isTouched ? 16.0 : 12.0;
                            final radius = isTouched ? 60.0 : 50.0;
                            final percentage =
                                (entry.value / totalAmount) * 100;

                            return PieChartSectionData(
                              color: _getCategoryColor(entry.key),
                              value: entry.value.toDouble(),
                              title: '${percentage.toStringAsFixed(1)}%',
                              radius: radius,
                              titleStyle: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: const [
                                  Shadow(color: Colors.black26, blurRadius: 2),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '총 지출',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            NumberFormat('#,###').format(totalAmount),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // List
                const Text(
                  '카테고리별 상세',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedCategories.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final entry = sortedCategories[index];
                    final percentage = (entry.value / totalAmount) * 100;
                    final color = _getCategoryColor(entry.key);

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getCategoryIcon(entry.key),
                          color: color,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${NumberFormat('#,###').format(entry.value)}원',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _decrementMonth,
            icon: const Icon(Icons.arrow_back_ios),
          ),
          Text(
            '${selectedDate.year}년 ${selectedDate.month}월',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: _incrementMonth,
            icon: const Icon(Icons.arrow_forward_ios),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '식비':
        return Colors.orange;
      case '교통':
        return Colors.blue;
      case '쇼핑':
        return Colors.purple;
      case '의료':
        return Colors.green;
      case '주거':
        return Colors.brown;
      case '기타':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '식비':
        return Icons.restaurant;
      case '교통':
        return Icons.directions_bus;
      case '쇼핑':
        return Icons.shopping_bag;
      case '의료':
        return Icons.medical_services;
      case '주거':
        return Icons.home;
      case '기타':
        return Icons.more_horiz;
      default:
        return Icons.category;
    }
  }
}
