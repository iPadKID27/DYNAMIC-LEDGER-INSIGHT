import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/netview_bloc.dart';
import '../bloc/netview_event.dart';
import '../bloc/netview_state.dart';
import '../model/financial_record.dart';
import 'home_view.dart';
import 'profile_view.dart';
import 'net_worth_view.dart';
import 'activity_view.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final userId = context.read<AuthBloc>().state.userId;
    if (userId != null) {
      context.read<NetViewBloc>().add(LedgerSubscriptionRequested(userId));
    }
  }

  static const List<Widget> _pages = [
    HomeView(),
    ActivityView(),
    NetWorthView(),
    ProfileView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAddTransactionDialog() {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final assetSymbolController = TextEditingController();
    final assetQuantityController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        DateTime selectedDate = DateTime.now();
        RecordType selectedType = RecordType.expense;
        
        final categories = {
          RecordType.income: ['Active Income', 'Passive Income', 'Others'],
          RecordType.expense: ['Saving Outflows', 'Fixed Outflows', 'Installment Payments', 'Variable Outflows'],
          RecordType.asset: ['Liquid Assets', 'Investment Assets', 'Personal Use Assets'],
        };
        
        String selectedCategory = categories[selectedType]![0];

        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Add Entry',
                                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
                                    ),
                                    IconButton(
                                      onPressed: () => Navigator.pop(context),
                                      icon: const Icon(Icons.close),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                // Record Type
                                Row(
                                  children: RecordType.values.map((type) {
                                    return Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: ChoiceChip(
                                          label: Text(type.name.toUpperCase()),
                                          selected: selectedType == type,
                                          onSelected: (val) {
                                            setModalState(() {
                                              selectedType = type;
                                              selectedCategory = categories[type]![0];
                                            });
                                          },
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 24),
                                // Category Selection
                                const Text(
                                  'Category',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F7),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedCategory,
                                      isExpanded: true,
                                      items: categories[selectedType]!.map((cat) {
                                        return DropdownMenuItem(value: cat, child: Text(cat));
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) setModalState(() => selectedCategory = val);
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Note',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: descriptionController,
                                  decoration: InputDecoration(
                                    hintText: 'e.g., Dinner at Siam',
                                    prefixIcon: const Icon(Icons.description_outlined, color: Color(0xFF4F3FF0)),
                                    filled: true,
                                    fillColor: const Color(0xFFF5F5F7),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Amount (THB)',
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
                                          ),
                                          const SizedBox(height: 12),
                                          TextField(
                                            controller: amountController,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              hintText: '0.00',
                                              prefixIcon: const Icon(Icons.payments_outlined, color: Color(0xFF4F3FF0)),
                                              filled: true,
                                              fillColor: const Color(0xFFF5F5F7),
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (selectedType == RecordType.asset) ...[
                                  const SizedBox(height: 24),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Symbol',
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
                                            ),
                                            const SizedBox(height: 12),
                                            TextField(
                                              controller: assetSymbolController,
                                              decoration: InputDecoration(
                                                hintText: 'BTC, Gold, AAPL',
                                                filled: true,
                                                fillColor: const Color(0xFFF5F5F7),
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Quantity',
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
                                            ),
                                            const SizedBox(height: 12),
                                            TextField(
                                              controller: assetQuantityController,
                                              keyboardType: TextInputType.number,
                                              decoration: InputDecoration(
                                                hintText: '0.0',
                                                filled: true,
                                                fillColor: const Color(0xFFF5F5F7),
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 24),
                                const Text(
                                  'When did it happen?',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
                                ),
                                const SizedBox(height: 12),
                                _buildDateTimePicker(context, selectedDate, (newDate) {
                                  setModalState(() => selectedDate = newDate);
                                }),
                                const SizedBox(height: 40),
                                SizedBox(
                                  width: double.infinity,
                                  height: 60,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final note = descriptionController.text.trim();
                                      final amountStr = amountController.text.trim();
                                      final amount = double.tryParse(amountStr) ?? 0.0;
                                      
                                      if (note.isEmpty || amount <= 0) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Please enter a valid amount and note.'),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                        return;
                                      }

                                      final userId = context.read<AuthBloc>().state.userId;
                                      if (userId != null) {
                                        final record = FinancialRecord(
                                          id: '',
                                          userId: userId,
                                          amount: amount,
                                          date: selectedDate,
                                          note: note,
                                          type: selectedType,
                                          category: selectedCategory,
                                          assetSymbol: selectedType == RecordType.asset ? assetSymbolController.text : null,
                                          assetQuantity: selectedType == RecordType.asset ? double.tryParse(assetQuantityController.text) : null,
                                        );
                                        context.read<NetViewBloc>().add(LedgerRecordAdded(record));
                                        Navigator.pop(context);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4F3FF0),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    ),
                                    child: const Text('Save Entry', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDateTimePicker(BuildContext context, DateTime selectedDate, Function(DateTime) onDateSelected) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(selectedDate),
          );
          if (time != null) {
            onDateSelected(DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            ));
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: Color(0xFF4F3FF0), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year} ${selectedDate.hour}:${selectedDate.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A)),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      floatingActionButton: Container(
        height: 64,
        width: 64,
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: FloatingActionButton(
          onPressed: _showAddTransactionDialog,
          elevation: 0,
          backgroundColor: const Color(0xFF4F3FF0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 80,
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 12.0,
        elevation: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(_selectedIndex == 0 ? Icons.home_filled : Icons.home_outlined, color: _selectedIndex == 0 ? const Color(0xFF1A1A1A) : Colors.grey, size: 26),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: Icon(_selectedIndex == 1 ? Icons.analytics : Icons.analytics_outlined, color: _selectedIndex == 1 ? const Color(0xFF1A1A1A) : Colors.grey, size: 26),
              onPressed: () => _onItemTapped(1),
            ),
            const SizedBox(width: 48),
            IconButton(
              icon: Icon(_selectedIndex == 2 ? Icons.account_balance_wallet : Icons.account_balance_wallet_outlined, color: _selectedIndex == 2 ? const Color(0xFF1A1A1A) : Colors.grey, size: 26),
              onPressed: () => _onItemTapped(2),
            ),
            IconButton(
              icon: Icon(_selectedIndex == 3 ? Icons.person : Icons.person_outline, color: _selectedIndex == 3 ? const Color(0xFF1A1A1A) : Colors.grey, size: 26),
              onPressed: () => _onItemTapped(3),
            ),
          ],
        ),
      ),
    );
  }
}
