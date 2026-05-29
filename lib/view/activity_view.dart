import 'package:flutter/material.dart';

class ActivityView extends StatefulWidget {
  const ActivityView({super.key});

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  // --- Activity State ---
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
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Activity',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    _buildTimeframeSelector(),
                  ],
                ),
                const SizedBox(height: 32),

                // Balance Card (Matches NetWorth Summary)
                _buildBalanceSummaryCard(),
                const SizedBox(height: 32),

                // Dynamic Content based on selection
                if (_selectedPeriod == 'Day')
                  _buildCalendarView()
                else if (_selectedPeriod == 'Week')
                  _buildWeekView()
                else if (_selectedPeriod == 'Month')
                  _buildMonthView()
                else
                  _buildYearView(),

                const SizedBox(height: 32),

                // Breakdown Section
                Text(
                  _getBreakdownTitle(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 16),
                _buildBreakdownContent(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBalanceSummaryCard() {
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
                  Text('Current Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  SizedBox(height: 4),
                  Text(
                    '\$12,450.00',
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.description_outlined, color: Colors.white, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildSimpleStat('Income', '+\$2,450'),
              const SizedBox(width: 40),
              _buildSimpleStat('Expense', '-\$1,200'),
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

  String _getBreakdownTitle() {
    return '$_selectedPeriod Breakdown';
  }

  Widget _buildBreakdownContent() {
    if (_selectedPeriod == 'Day') return _buildDayBreakdown();
    if (_selectedPeriod == 'Week') return _buildWeekBreakdown();
    if (_selectedPeriod == 'Month') return _buildMonthBreakdown();
    return _buildYearBreakdown();
  }

  Widget _buildDayBreakdown() {
    return Column(
      children: [
        _buildDetailItem('Grocery', '-\$120.00', '11:00 AM', Colors.orange, Icons.shopping_basket_rounded),
        _buildDetailItem('Uber', '-\$15.50', '02:30 PM', Colors.black, Icons.directions_car_rounded),
        _buildDetailItem('Subscription', '-\$9.99', '08:00 PM', Colors.blue, Icons.subscriptions_rounded),
      ],
    );
  }

  Widget _buildWeekBreakdown() {
    return Column(
      children: [
        _buildDetailItem('Monday', '-\$340.00', '4 transactions', Colors.deepPurple, Icons.calendar_today_rounded),
        _buildDetailItem('Tuesday', '-\$120.50', '2 transactions', Colors.deepPurple, Icons.calendar_today_rounded),
        _buildDetailItem('Wednesday', '-\$1,200.00', 'Rent & Bills', Colors.red, Icons.home_rounded),
        _buildDetailItem('Thursday', '-\$45.00', '1 transaction', Colors.deepPurple, Icons.calendar_today_rounded),
      ],
    );
  }

  Widget _buildMonthBreakdown() {
    return Column(
      children: [
        _buildDetailItem('Week 1', '-\$1,450.00', 'Apr 1 - Apr 7', Colors.blue, Icons.date_range_rounded),
        _buildDetailItem('Week 2', '-\$980.00', 'Apr 8 - Apr 14', Colors.blue, Icons.date_range_rounded),
        _buildDetailItem('Week 3', '-\$2,100.00', 'Apr 15 - Apr 21', Colors.red, Icons.warning_amber_rounded),
        _buildDetailItem('Week 4', '-\$450.00', 'Apr 22 - Apr 30', Colors.blue, Icons.date_range_rounded),
      ],
    );
  }

  Widget _buildYearBreakdown() {
    return Column(
      children: [
        _buildDetailItem('January', '-\$4,200.00', 'Monthly Avg: \$3,500', Colors.green, Icons.analytics_rounded),
        _buildDetailItem('February', '-\$3,800.00', 'Fixed Costs focus', Colors.green, Icons.analytics_rounded),
        _buildDetailItem('March', '-\$5,100.00', 'Leisure & Travel', Colors.orange, Icons.beach_access_rounded),
        _buildDetailItem('April', '-\$4,980.00', 'Current Month', Colors.blue, Icons.analytics_rounded),
      ],
    );
  }

  Widget _buildWeekView() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_days.length, (index) {
          final day = _days[index];
          final isSelected = _selectedDayIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedDayIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF4F3FF0) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    day['label']!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[400],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    day['day']!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCalendarView() {
    final List<String> weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    const int daysInMonth = 30;
    const int firstDayOffset = 3;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekdays
                .map((d) => SizedBox(
                      width: 30,
                      child: Text(d,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.w800)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: daysInMonth + firstDayOffset,
            itemBuilder: (context, index) {
              if (index < firstDayOffset) return const SizedBox();
              final day = index - firstDayOffset + 1;
              final isSelected = day == 21;
              return Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF4F3FF0) : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      day.toString(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMonthView() {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          final isSelected = index == 3; // April
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF4F3FF0) : const Color(0xFFFBFBFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.withValues(alpha: 0.05)),
            ),
            alignment: Alignment.center,
            child: Text(
              months[index],
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildYearView() {
    final years = ['2023', '2024', '2025', '2026'];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: years.map((year) {
          final isSelected = year == '2026';
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF4F3FF0) : const Color(0xFFFBFBFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.withValues(alpha: 0.05)),
            ),
            child: Text(
              year,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w800,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDetailItem(String title, String amount, String time, Color iconColor, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
        ),
        subtitle: Text(
          time,
          style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w600, fontSize: 13),
        ),
        trailing: Text(
          amount,
          style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFE74C3C), fontSize: 16),
        ),
      ),
    );
  }
}
