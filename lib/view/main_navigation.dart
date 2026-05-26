import 'package:flutter/material.dart';
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        DateTime selectedDate = DateTime.now();

        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6, // Adjusted for fewer fields
              minChildSize: 0.4,
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
                      // Drag Handle
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
                                      'Add Transaction',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        onPressed: () => Navigator.pop(context),
                                        icon: const Icon(Icons.close, size: 20),
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                // Description Input
                                const Text(
                                  'What is your money activity you want to record?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  decoration: InputDecoration(
                                    hintText: 'e.g., Dinner 50 Bath, Buy Stock 50 bath got 0.001 share, Income 50,000 Bath',
                                    hintStyle: TextStyle(color: Colors.grey[400]),
                                    prefixIcon: const Icon(Icons.description_outlined, color: Color(0xFF4F3FF0)),
                                    filled: true,
                                    fillColor: const Color(0xFFF5F5F7),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Date & Time Selector
                                const Text(
                                  'When did it happen?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildDateTimePicker(context, selectedDate, (newDate) {
                                  setModalState(() => selectedDate = newDate);
                                }),
                                const SizedBox(height: 40),
                                // Save Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 60,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4F3FF0),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Text(
                                      'Save Transaction',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                ),
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
                _selectedIndex == 1 ? Icons.analytics : Icons.analytics_outlined,
                color: _selectedIndex == 1 ? const Color(0xFF1A1A1A) : Colors.grey,
                size: 26,
              ),
              onPressed: () => _onItemTapped(1),
            ),
            const SizedBox(width: 48), // Space for the oversized FAB
            IconButton(
              icon: Icon(
                _selectedIndex == 2 ? Icons.account_balance_wallet : Icons.account_balance_wallet_outlined,
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
