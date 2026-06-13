import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/netview_bloc.dart';
import '../bloc/netview_event.dart';
import '../bloc/netview_state.dart';
import '../model/financial_record.dart';

class ActivityView extends StatefulWidget {
  const ActivityView({super.key});

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  int _selectedDayIndex = 3; // Default to Wednesday (21st)
  String _selectedPeriod = 'Week';

  final List<Map<String, String>> _days = [
    {'day': '18', 'label': 'S'},
    {'day': '19', 'label': 'M'},
    {'day': '20', 'label': 'T'},
    {'day': '21', 'label': 'W'},
    {'day': '22', 'label': 'T'},
    {'day': '23', 'label': 'F'},
    {'day': '24', 'label': 'S'},
  ];

  @override
  void initState() {
    super.initState();
    final userId = context.read<AuthBloc>().state.userId;
    if (userId != null) {
      context.read<NetViewBloc>().add(LedgerSubscriptionRequested(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetViewBloc, NetViewState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Activity',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
                        ),
                        _buildTimeframeSelector(),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildBalanceSummaryCard(state.records),
                    const SizedBox(height: 32),
                    if (_selectedPeriod == 'Day') _buildCalendarView()
                    else if (_selectedPeriod == 'Week') _buildWeekView()
                    else if (_selectedPeriod == 'Month') _buildMonthView()
                    else _buildYearView(),
                    const SizedBox(height: 32),
                    Text(
                      '$_selectedPeriod Breakdown',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(height: 16),
                    _buildBreakdownContent(state.records),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeframeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: ['Day', 'Week', 'Month', 'Year'].map((timeframe) {
          bool isSelected = _selectedPeriod == timeframe;
          return GestureDetector(
            onTap: () => setState(() => _selectedPeriod = timeframe),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF4F3FF0) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                timeframe,
                style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBalanceSummaryCard(List<FinancialRecord> records) {
    double income = 0;
    double expense = 0;
    for (var r in records) {
      if (r.type == RecordType.income) income += r.amount;
      else if (r.type == RecordType.expense) expense += r.amount;
    }
    double balance = income - expense;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF8E84FF), Color(0xFF4F3FF0)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Text(
                    '\$${balance.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const Icon(Icons.description_outlined, color: Colors.white, size: 24),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildSimpleStat('Income', '+\$${income.toStringAsFixed(0)}'),
              const SizedBox(width: 40),
              _buildSimpleStat('Expense', '-\$${expense.toStringAsFixed(0)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildBreakdownContent(List<FinancialRecord> records) {
    // Basic day filtering for demo purposes
    final selectedDay = int.parse(_days[_selectedDayIndex]['day']!);
    final filteredRecords = records.where((r) => r.date.day == selectedDay).toList();

    if (filteredRecords.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text('No transactions found', style: TextStyle(color: Colors.grey)),
      ));
    }

    return Column(
      children: filteredRecords.map((record) {
        final color = record.type == RecordType.income ? Colors.green : Colors.orange;
        return _buildDetailItem(
          record.category,
          '${record.type == RecordType.income ? "+" : "-"}\$${record.amount.toStringAsFixed(2)}',
          '${record.date.hour}:${record.date.minute.toString().padLeft(2, "0")}',
          color,
          record.type == RecordType.income ? Icons.add_circle_outline : Icons.remove_circle_outline,
        );
      }).toList(),
    );
  }

  Widget _buildDetailItem(String title, String amount, String time, Color iconColor, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
        subtitle: Text(time, style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w600, fontSize: 13)),
        trailing: Text(amount, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      ),
    );
  }

  // Placeholder views for timeframe selectors (reusing the original UI)
  Widget _buildWeekView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_days.length, (index) {
        final isSelected = _selectedDayIndex == index;
        return GestureDetector(
          onTap: () => setState(() => _selectedDayIndex = index),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF4F3FF0) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(_days[index]['label']!, style: TextStyle(color: isSelected ? Colors.white : Colors.grey)),
                Text(_days[index]['day']!, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCalendarView() => const SizedBox(height: 100, child: Center(child: Text('Calendar View')));
  Widget _buildMonthView() => const SizedBox(height: 100, child: Center(child: Text('Month View')));
  Widget _buildYearView() => const SizedBox(height: 100, child: Center(child: Text('Year View')));
}
