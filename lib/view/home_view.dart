import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 120,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello,',
              style: TextStyle(
                fontSize: 32,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              'The one who wait!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          _buildCircleAction(Icons.search),
          const SizedBox(width: 12),
          _buildCircleAction(Icons.notifications_none_outlined, hasNotification: true),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBalanceCard(context),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Assets Values',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See all', style: TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
              _buildAssetsList(),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See all', style: TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
              _buildTransactionList(),
              const SizedBox(height: 100), // Space for FAB
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildCircleAction(IconData icon, {bool hasNotification = false}) {
    return Stack(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Icon(icon, color: Colors.black, size: 22),
        ),
        if (hasNotification)
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.deepPurple.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            '\$12,450.00',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBalanceInfo('Income', '\$4,200', Icons.arrow_upward),
              _buildBalanceInfo('Expenses', '\$1,800', Icons.arrow_downward),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceInfo(String label, String amount, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text(amount, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildAssetsList() {
    final assets = [
      {'title': 'Bitcoin', 'value': '\$45,200', 'subtitle': 'Crypto Portfolio', 'icon': Icons.currency_bitcoin, 'isPrimary': true},
      {'title': 'Tesla Stock', 'value': '\$12,400', 'subtitle': 'Stocks & Equity', 'icon': Icons.electric_car, 'isPrimary': false},
      {'title': 'Real Estate', 'value': '\$250k', 'subtitle': 'Property', 'icon': Icons.home_work, 'isPrimary': false},
    ];

    return SizedBox(
      height: 180,
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
    final bgColor = isPrimary ? const Color(0xFF4F3FF0) : Colors.grey.shade50;
    final textColor = isPrimary ? Colors.white : Colors.black;
    final subTextColor = isPrimary ? Colors.white70 : Colors.grey.shade600;

    return Container(
      width: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: isPrimary ? null : Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isPrimary ? Colors.white.withValues(alpha: 0.2) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isPrimary ? [] : [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)
                  ],
                ),
                child: Icon(icon, color: isPrimary ? Colors.white : Colors.black, size: 24),
              ),
              Icon(Icons.more_vert, color: isPrimary ? Colors.white : Colors.grey, size: 20),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: subTextColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    final transactions = [
      {'title': 'Grocery Store', 'amount': '-\$45.00', 'category': 'Food', 'icon': Icons.shopping_basket},
      {'title': 'Salary', 'amount': '+\$3,500.00', 'category': 'Income', 'icon': Icons.work},
      {'title': 'Electricity Bill', 'amount': '-\$120.00', 'category': 'Utilities', 'icon': Icons.bolt},
      {'title': 'Netflix Subscription', 'amount': '-\$15.00', 'category': 'Entertainment', 'icon': Icons.movie},
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final isPositive = (tx['amount'] as String).startsWith('+');

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                    )
                  ],
                ),
                child: Icon(tx['icon'] as IconData, color: Colors.black, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      tx['category'] as String,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                tx['amount'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isPositive ? Colors.green.shade600 : Colors.red.shade400,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
