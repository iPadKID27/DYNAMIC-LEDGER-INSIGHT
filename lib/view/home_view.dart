import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
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
                _buildBalanceCard(),
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
                _buildAssetsList(),
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
                _buildTransactionList(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
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
                color: Colors.black.withValues(alpha: 0.05),
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

  Widget _buildBalanceCard() {
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
            color: const Color(0xFF4F3FF0).withValues(alpha: 0.3),
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  SizedBox(height: 4),
                  Text(
                    '\$12,450.00',
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
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
              _buildSimpleStat('Income', '+\$4,200'),
              const SizedBox(width: 40),
              _buildSimpleStat('Expenses', '-\$1,800'),
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

  Widget _buildAssetsList() {
    final assets = [
      {'title': 'Bitcoin', 'value': '\$45,200', 'subtitle': 'Crypto Portfolio', 'icon': Icons.currency_bitcoin_rounded, 'isPrimary': true},
      {'title': 'Tesla Stock', 'value': '\$12,400', 'subtitle': 'Stocks & Equity', 'icon': Icons.electric_car_rounded, 'isPrimary': false},
      {'title': 'Real Estate', 'value': '\$250k', 'subtitle': 'Property', 'icon': Icons.home_work_rounded, 'isPrimary': false},
    ];

    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: assets.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final asset = assets[index];
          return _buildAssetCard(
            asset['title'] as String,
            asset['value'] as String,
            asset['subtitle'] as String,
            asset['icon'] as IconData,
            asset['isPrimary'] as bool,
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
              ? const Color(0xFF4F3FF0).withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.03),
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
              color: isPrimary ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFF8F9FE),
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

  Widget _buildTransactionList() {
    final transactions = [
      {'title': 'Grocery Store', 'amount': '-\$45.00', 'category': 'Food', 'icon': Icons.shopping_basket_rounded, 'color': Colors.orange},
      {'title': 'Salary', 'amount': '+\$3,500.00', 'category': 'Income', 'icon': Icons.work_rounded, 'color': Colors.green},
      {'title': 'Electricity Bill', 'amount': '-\$120.00', 'category': 'Utilities', 'icon': Icons.bolt_rounded, 'color': Colors.blue},
      {'title': 'Netflix Subscription', 'amount': '-\$15.00', 'category': 'Entertainment', 'icon': Icons.subscriptions_rounded, 'color': Colors.red},
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final isPositive = (tx['amount'] as String).startsWith('+');
        final iconColor = tx['color'] as Color;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
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
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(tx['icon'] as IconData, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A), fontSize: 15),
                    ),
                    Text(
                      tx['category'] as String,
                      style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                tx['amount'] as String,
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
