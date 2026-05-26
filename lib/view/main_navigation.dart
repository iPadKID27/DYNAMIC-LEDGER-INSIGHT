import 'package:flutter/material.dart';
import 'home_view.dart';
import 'profile_view.dart';
import 'history_view.dart';
import 'activity_view.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    HomeView(),
    HistoryView(),
    ActivityView(),
    ProfileView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAddTransactionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String mainType = 'Transaction'; // 'Transaction' or 'Asset'
        String transactionType = 'Expense'; // 'Income' or 'Expense'
        DateTime selectedDate = DateTime.now();

        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Add $mainType',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Primary Toggle: Transaction vs Asset
                        Center(
                          child: SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(
                                value: 'Transaction',
                                label: Text('Transaction'),
                                icon: Icon(Icons.receipt_long),
                              ),
                              ButtonSegment(
                                value: 'Asset',
                                label: Text('Asset'),
                                icon: Icon(Icons.account_balance),
                              ),
                            ],
                            selected: {mainType},
                            onSelectionChanged: (Set<String> newSelection) {
                              setModalState(() {
                                mainType = newSelection.first;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        if (mainType == 'Transaction') ...[
                          // Transaction Specific UI
                          Center(
                            child: SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(
                                  value: 'Income',
                                  label: Text('Income'),
                                  icon: Icon(Icons.add_circle_outline),
                                ),
                                ButtonSegment(
                                  value: 'Expense',
                                  label: Text('Expense'),
                                  icon: Icon(Icons.remove_circle_outline),
                                ),
                              ],
                              selected: {transactionType},
                              onSelectionChanged: (Set<String> newSelection) {
                                setModalState(() {
                                  transactionType = newSelection.first;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          const TextField(
                            decoration: InputDecoration(
                              labelText: 'Amount',
                              prefixIcon: Icon(Icons.attach_money),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          _buildDateTimePicker(context, selectedDate, (newDate) {
                            setModalState(() => selectedDate = newDate);
                          }),
                          const SizedBox(height: 16),
                          const TextField(
                            decoration: InputDecoration(
                              labelText: 'Category',
                              prefixIcon: Icon(Icons.category),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const TextField(
                            decoration: InputDecoration(
                              labelText: 'Description',
                              prefixIcon: Icon(Icons.description),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ] else ...[
                          // Asset Specific UI
                          const TextField(
                            decoration: InputDecoration(
                              labelText: 'Asset Name',
                              prefixIcon: Icon(Icons.label),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const TextField(
                            decoration: InputDecoration(
                              labelText: 'Asset Type',
                              hintText: 'e.g., Real Estate, Stocks, Gold',
                              prefixIcon: Icon(Icons.category),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const TextField(
                            decoration: InputDecoration(
                              labelText: 'Current Value',
                              prefixIcon: Icon(Icons.payments),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          _buildDateTimePicker(context, selectedDate, (newDate) {
                            setModalState(() => selectedDate = newDate);
                          }, label: 'Purchase/Acquisition Date'),
                        ],
                        
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mainType == 'Asset' 
                                  ? Colors.blue.shade700
                                  : (transactionType == 'Income' 
                                      ? Colors.green.shade700 
                                      : Colors.deepPurple),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text('Save $mainType'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDateTimePicker(BuildContext context, DateTime selectedDate, Function(DateTime) onDateSelected, {String label = 'Date & Time'}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.calendar_today),
      title: Text(label),
      subtitle: Text(
        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year} ${selectedDate.hour}:${selectedDate.minute.toString().padLeft(2, '0')}',
      ),
      trailing: const Icon(Icons.edit),
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
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: FloatingActionButton(
          onPressed: _showAddTransactionDialog,
          elevation: 0,
          backgroundColor: const Color(0xFF4F3FF0), // Vibrant purple from image
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.add, 
            color: Colors.white, 
            size: 32,
          ),
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
              icon: Icon(
                _selectedIndex == 0 ? Icons.home_filled : Icons.home_outlined,
                color: _selectedIndex == 0 ? const Color(0xFF1A1A1A) : Colors.grey,
                size: 26,
              ),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: Icon(
                _selectedIndex == 1 ? Icons.account_balance_wallet : Icons.account_balance_wallet_outlined,
                color: _selectedIndex == 1 ? const Color(0xFF1A1A1A) : Colors.grey,
                size: 26,
              ),
              onPressed: () => _onItemTapped(1),
            ),
            const SizedBox(width: 48), // Space for the oversized FAB
            IconButton(
              icon: Icon(
                _selectedIndex == 2 ? Icons.flag : Icons.flag_outlined,
                color: _selectedIndex == 2 ? const Color(0xFF1A1A1A) : Colors.grey,
                size: 26,
              ),
              onPressed: () => _onItemTapped(2),
            ),
            IconButton(
              icon: Icon(
                _selectedIndex == 3 ? Icons.person : Icons.person_outline,
                color: _selectedIndex == 3 ? const Color(0xFF1A1A1A) : Colors.grey,
                size: 26,
              ),
              onPressed: () => _onItemTapped(3),
            ),
          ],
        ),
      ),
    );
  }
}
