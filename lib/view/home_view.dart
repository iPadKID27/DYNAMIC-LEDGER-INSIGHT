import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/netview_bloc.dart';
import '../bloc/netview_event.dart';
import '../bloc/netview_state.dart';
import '../model/financial_record.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

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
                    // Header / AppBar Replacement
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello,',
                              style: TextStyle(
                                fontSize: 28,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'The one who wait!',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A1A),
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _buildCircleAction(Icons.search_rounded),
                            const SizedBox(width: 12),
                            _buildCircleAction(Icons.notifications_none_rounded, hasNotification: true),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Total Balance Card
                    _buildBalanceCard(state.records),
                    const SizedBox(height: 32),

                    // Assets Values Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Asset Values',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        Text(
                          'See all',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildAssetsList(state.records),
                    const SizedBox(height: 32),

                    // Recent Transactions Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Transactions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        Text(
                          'See all',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTransactionList(state.records),
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

  Widget _buildCircleAction(IconData icon, {bool hasNotification = false}) {
    return Stack(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF1A1A1A), size: 24),
        ),
        if (hasNotification)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFFE74C3C),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF8F9FE), width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBalanceCard(List<FinancialRecord> records) {
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
        gradient: const LinearGradient(
          colors: [Color(0xFF8E84FF), Color(0xFF4F3FF0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F3FF0).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
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
                  const Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    '\$${balance.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text('+2.4%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildSimpleStat('Income', '+\$${income.toStringAsFixed(0)}'),
              const SizedBox(width: 40),
              _buildSimpleStat('Expenses', '-\$${expense.toStringAsFixed(0)}'),
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
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildAssetsList(List<FinancialRecord> records) {
    final assetRecords = records.where((r) => r.type == RecordType.asset).toList();
    
    if (assetRecords.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text('No assets recorded', style: TextStyle(color: Colors.grey))),
      );
    }

    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: assetRecords.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final asset = assetRecords[index];
          return _buildAssetCard(
            asset.assetSymbol ?? asset.category,
            '\$${asset.amount.toStringAsFixed(0)}',
            asset.category,
            Icons.account_balance_wallet_rounded,
            index == 0,
          );
        },
      ),
    );
  }

  Widget _buildAssetCard(String title, String value, String subtitle, IconData icon, bool isPrimary) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFF4F3FF0) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isPrimary 
              ? const Color(0xFF4F3FF0).withOpacity(0.2)
              : Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isPrimary ? Colors.white.withOpacity(0.15) : const Color(0xFFF8F9FE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: isPrimary ? Colors.white : const Color(0xFF4F3FF0), size: 22),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              color: isPrimary ? Colors.white70 : Colors.grey[500],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: isPrimary ? Colors.white : const Color(0xFF1A1A1A),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<FinancialRecord> records) {
    final transactions = records.take(5).toList();

    if (transactions.isEmpty) {
      return const Center(child: Text('No recent transactions', style: TextStyle(color: Colors.grey)));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final isPositive = tx.type == RecordType.income;
        final iconColor = isPositive ? Colors.green : Colors.orange;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(isPositive ? Icons.add_circle_outline : Icons.remove_circle_outline, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.note,
                      style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A), fontSize: 15),
                    ),
                    Text(
                      tx.category,
                      style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                '${isPositive ? "+" : "-"}\$${tx.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: isPositive ? const Color(0xFF27AE60) : const Color(0xFFE74C3C),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
