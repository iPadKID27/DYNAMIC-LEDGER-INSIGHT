import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/netview_bloc.dart';
import '../bloc/netview_event.dart';
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
    
    DateTime selectedDate = DateTime.now();
    RecordType selectedType = RecordType.expense;
    
    final categories = {
      RecordType.income: ['Active Income', 'Passive Income', 'Others'],
      RecordType.expense: ['Saving Outflows', 'Fixed Outflows', 'Installment Payments', 'Variable Outflows'],
      RecordType.asset: ['Liquid Assets', 'Investment Assets', 'Personal Use Assets'],
    };
    
    String selectedCategory = categories[selectedType]![0];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {


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
                                  maxLength: 120,
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
                                            maxLength: 20,
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
                                              maxLength: 5,
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
                                              maxLength: 20,
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
                                      
                                      bool isAssetInvalid = selectedType == RecordType.asset && 
                                        (assetSymbolController.text.trim().isEmpty || (double.tryParse(assetQuantityController.text.trim()) ?? 0.0) <= 0);

                                      if (note.isEmpty || amount <= 0 || isAssetInvalid) {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => Dialog(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                            backgroundColor: Colors.white,
                                            elevation: 10,
                                            child: Padding(
                                              padding: const EdgeInsets.all(24.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(16),
                                                    decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), shape: BoxShape.circle),
                                                    child: const Icon(Icons.error_outline, color: Colors.redAccent, size: 36),
                                                  ),
                                                  const SizedBox(height: 20),
                                                  const Text('Invalid Input', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                                                  const SizedBox(height: 8),
                                                  const Text('Please enter a valid amount, note, and asset details (if applicable).', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey)),
                                                  const SizedBox(height: 32),
                                                  SizedBox(
                                                    width: double.infinity,
                                                    child: ElevatedButton(
                                                      onPressed: () => Navigator.pop(ctx),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.redAccent,
                                                        foregroundColor: Colors.white,
                                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                        elevation: 0,
                                                      ),
                                                      child: const Text('Got it', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      if (selectedType != RecordType.asset && !RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(amountStr)) {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => Dialog(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                            backgroundColor: Colors.white,
                                            elevation: 10,
                                            child: Padding(
                                              padding: const EdgeInsets.all(24.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(16),
                                                    decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), shape: BoxShape.circle),
                                                    child: const Icon(Icons.error_outline, color: Colors.redAccent, size: 36),
                                                  ),
                                                  const SizedBox(height: 20),
                                                  const Text('Invalid Amount', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                                                  const SizedBox(height: 8),
                                                  const Text('Amount can have at most 2 decimal places.', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey)),
                                                  const SizedBox(height: 32),
                                                  SizedBox(
                                                    width: double.infinity,
                                                    child: ElevatedButton(
                                                      onPressed: () => Navigator.pop(ctx),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.redAccent,
                                                        foregroundColor: Colors.white,
                                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                        elevation: 0,
                                                      ),
                                                      child: const Text('Got it', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
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

                                        showDialog(
                                          context: context,
                                          builder: (dialogContext) {
                                            return Dialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(24),
                                              ),
                                              backgroundColor: Colors.white,
                                              elevation: 10,
                                              child: Padding(
                                                padding: const EdgeInsets.all(24.0),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding: const EdgeInsets.all(10),
                                                          decoration: BoxDecoration(
                                                            color: const Color(0xFF4F3FF0).withOpacity(0.1),
                                                            shape: BoxShape.circle,
                                                          ),
                                                          child: const Icon(Icons.check_circle_outline, color: Color(0xFF4F3FF0), size: 28),
                                                        ),
                                                        const SizedBox(width: 16),
                                                        const Text(
                                                          'Confirm Entry',
                                                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 24),
                                                    Container(
                                                      padding: const EdgeInsets.all(16),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFF5F5F7),
                                                        borderRadius: BorderRadius.circular(16),
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          _buildDetailRow('Type', record.type.name.toUpperCase(), isHighlight: true),
                                                          const Divider(height: 24, color: Colors.black12),
                                                          _buildDetailRow('Category', record.category),
                                                          const SizedBox(height: 12),
                                                          _buildDetailRow('Amount', 'THB ${record.amount.toStringAsFixed(2)}'),
                                                          const SizedBox(height: 12),
                                                          _buildDetailRow('Note', record.note),
                                                          if (record.type == RecordType.asset) ...[
                                                            const SizedBox(height: 12),
                                                            _buildDetailRow('Symbol', record.assetSymbol ?? ''),
                                                            const SizedBox(height: 12),
                                                            _buildDetailRow('Quantity', record.assetQuantity?.toString() ?? ''),
                                                          ],
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 32),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: TextButton(
                                                            onPressed: () => Navigator.pop(dialogContext),
                                                            style: TextButton.styleFrom(
                                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                            ),
                                                            child: const Text('Cancel', style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 16),
                                                        Expanded(
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              context.read<NetViewBloc>().add(LedgerRecordAdded(record));
                                                              Navigator.pop(dialogContext); // Close dialog
                                                              Navigator.pop(context); // Close bottom sheet
                                                            },
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: const Color(0xFF4F3FF0),
                                                              foregroundColor: Colors.white,
                                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                                              elevation: 0,
                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                            ),
                                                            child: const Text('Confirm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
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

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: isHighlight ? const Color(0xFF4F3FF0) : const Color(0xFF1E1E1E),
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
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
