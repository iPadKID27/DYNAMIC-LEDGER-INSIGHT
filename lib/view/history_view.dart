import 'package:flutter/material.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  String _selectedTab = 'Transactions'; // 'Transactions' or 'Assets'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildTab('Transactions'),
                  _buildTab('Assets'),
                ],
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: _selectedTab == 'Transactions' 
          ? _buildTransactionHistory() 
          : _buildAssetHistory(),
    );
  }

  Widget _buildTab(String label) {
    bool isSelected = _selectedTab == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = label),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionHistory() {
    final transactions = [
      {'title': 'Starbucks Coffee', 'amount': '-\$5.50', 'date': 'Today, 09:30 AM', 'type': 'Expense', 'icon': Icons.coffee},
      {'title': 'Freelance Payment', 'amount': '+\$800.00', 'date': 'Yesterday', 'type': 'Income', 'icon': Icons.payments},
      {'title': 'Rent Payment', 'amount': '-\$1,200.00', 'date': '25 Apr 2026', 'type': 'Expense', 'icon': Icons.home},
      {'title': 'Dividends', 'amount': '+\$45.20', 'date': '24 Apr 2026', 'type': 'Income', 'icon': Icons.trending_up},
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return _buildHistoryItem(
          context,
          title: tx['title'] as String,
          subtitle: tx['date'] as String,
          amount: tx['amount'] as String,
          icon: tx['icon'] as IconData,
          isPositive: (tx['amount'] as String).startsWith('+'),
        );
      },
    );
  }

  Widget _buildAssetHistory() {
    final assets = [
      {'title': 'Bitcoin Portfolio', 'value': '\$45,200.00', 'date': 'Updated 2 mins ago', 'type': 'Crypto', 'icon': Icons.currency_bitcoin},
      {'title': 'Tesla Stock', 'value': '\$12,400.00', 'date': 'Updated 1 hour ago', 'type': 'Stock', 'icon': Icons.show_chart},
      {'title': 'Main Savings', 'value': '\$8,500.00', 'date': 'Updated Yesterday', 'type': 'Bank', 'icon': Icons.account_balance},
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: assets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final asset = assets[index];
        return _buildHistoryItem(
          context,
          title: asset['title'] as String,
          subtitle: asset['date'] as String,
          amount: asset['value'] as String,
          icon: asset['icon'] as IconData,
          isPositive: true,
        );
      },
    );
  }

  Widget _buildHistoryItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String amount,
    required IconData icon,
    required bool isPositive,
  }) {
    return InkWell(
      onTap: () {
        // Here you would navigate to an Edit screen
        _showEditDialog(context, title);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.deepPurple, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.edit_note, size: 20, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit mode for: $title'),
        action: SnackBarAction(label: 'Open', onPressed: () {}),
      ),
    );
  }
}
