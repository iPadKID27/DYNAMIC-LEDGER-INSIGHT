import 'package:flutter/material.dart';

class ActivityView extends StatefulWidget {
  const ActivityView({super.key});

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  // --- Goals State ---
  final List<Goal> _goals = [
    Goal(title: 'New Car', targetAmount: 20000, currentAmount: 5000, color: Colors.blue),
    Goal(title: 'Emergency Fund', targetAmount: 10000, currentAmount: 8500, color: Colors.green),
    Goal(title: 'Vacation', targetAmount: 5000, currentAmount: 1200, color: Colors.orange),
  ];

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

  void _addNewGoal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String title = '';
        double target = 0;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create New Goal',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Goal Title',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => title = value,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Target Amount',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => target = double.tryParse(value) ?? 0,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (title.isNotEmpty && target > 0) {
                      setState(() {
                        _goals.add(Goal(
                          title: title,
                          targetAmount: target,
                          currentAmount: 0,
                          color: Colors.primaries[_goals.length % Colors.primaries.length],
                        ));
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F3FF0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Create Goal'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showAddFundsDialog(Goal goal) {
    double amountToAdd = 0;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add funds to ${goal.title}'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'Amount',
            prefixText: '\$',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) => amountToAdd = double.tryParse(value) ?? 0,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (amountToAdd > 0) {
                setState(() {
                  goal.currentAmount += amountToAdd;
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeColor = theme.colorScheme.primary;
    final textMain = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final textMuted = Colors.grey;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Custom Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black12),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, size: 18),
                  ),
                  const Text(
                    'Activity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black12),
                    ),
                    child: const Icon(Icons.description_outlined, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Activity Calendar Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      themeColor.withValues(alpha: 0.1),
                      themeColor.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white, width: 2),
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
                            Text(
                              'Current Balance',
                              style: TextStyle(color: textMuted, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '\$12,450.00',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        PopupMenuButton<String>(
                          initialValue: _selectedPeriod,
                          onSelected: (String value) {
                            setState(() {
                              _selectedPeriod = value;
                            });
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'Day',
                              child: Text('Day'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'Week',
                              child: Text('Week'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'Month',
                              child: Text('Month'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'Year',
                              child: Text('Year'),
                            ),
                          ],
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: Row(
                              children: [
                                Text(_selectedPeriod,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                const Icon(Icons.keyboard_arrow_down, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Dynamic Content based on selection
                    if (_selectedPeriod == 'Day')
                      _buildCalendarView(themeColor, textMain, textMuted)
                    else if (_selectedPeriod == 'Week')
                      _buildWeekView(themeColor, textMain, textMuted)
                    else if (_selectedPeriod == 'Month')
                      _buildMonthView(themeColor, textMain, textMuted)
                    else
                      _buildYearView(themeColor, textMain, textMuted),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- My Goals Section ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Goals',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _addNewGoal,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New Goal'),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _goals.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text('No goals yet', style: TextStyle(color: textMuted)),
                      ),
                    )
                  : SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _goals.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final goal = _goals[index];
                          return _buildGoalCard(goal);
                        },
                      ),
                    ),
              const SizedBox(height: 30),

              // Quick Menu
              const Text(
                'Quick Menu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildQuickMenuItem(Icons.auto_awesome, 'AI Smart\nExpense Log', themeColor),
                    _buildQuickMenuItem(Icons.add_chart, 'Track New\nAsset', themeColor),
                    _buildQuickMenuItem(Icons.flag_outlined, 'Set Wealth\nTarget', themeColor),
                    _buildQuickMenuItem(Icons.currency_bitcoin, 'Market\nRates', themeColor),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Breakdown Section
              Text(
                _getBreakdownTitle(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _buildBreakdownContent(),
              const SizedBox(height: 100), // Space for FAB
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildGoalCard(Goal goal) {
    double progress = goal.currentAmount / goal.targetAmount;
    if (progress > 1.0) progress = 1.0;

    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: goal.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${goal.currentAmount.toStringAsFixed(0)} / \$${goal.targetAmount.toStringAsFixed(0)}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: goal.color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(goal.color),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => _showAddFundsDialog(goal),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: goal.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, size: 16, color: goal.color),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getBreakdownTitle() {
    switch (_selectedPeriod) {
      case 'Day':
        return 'Daily Breakdown';
      case 'Week':
        return 'Week Breakdown';
      case 'Month':
        return 'Month Breakdown';
      case 'Year':
        return 'Year Breakdown';
      default:
        return 'Breakdown';
    }
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
        _buildDetailItem('Grocery', '-\$120.00', '11:00 AM', Colors.orange),
        _buildDetailItem('Uber', '-\$15.50', '02:30 PM', Colors.black),
        _buildDetailItem('Subscription', '-\$9.99', '08:00 PM', Colors.blue),
      ],
    );
  }

  Widget _buildWeekBreakdown() {
    return Column(
      children: [
        _buildDetailItem('Monday', '-\$340.00', '4 transactions', Colors.deepPurple),
        _buildDetailItem('Tuesday', '-\$120.50', '2 transactions', Colors.deepPurple),
        _buildDetailItem('Wednesday', '-\$1,200.00', 'Rent & Bills', Colors.red),
        _buildDetailItem('Thursday', '-\$45.00', '1 transaction', Colors.deepPurple),
      ],
    );
  }

  Widget _buildMonthBreakdown() {
    return Column(
      children: [
        _buildDetailItem('Week 1', '-\$1,450.00', 'Apr 1 - Apr 7', Colors.blue),
        _buildDetailItem('Week 2', '-\$980.00', 'Apr 8 - Apr 14', Colors.blue),
        _buildDetailItem('Week 3', '-\$2,100.00', 'Apr 15 - Apr 21', Colors.red),
        _buildDetailItem('Week 4', '-\$450.00', 'Apr 22 - Apr 30', Colors.blue),
      ],
    );
  }

  Widget _buildYearBreakdown() {
    return Column(
      children: [
        _buildDetailItem('January', '-\$4,200.00', 'Monthly Avg: \$3,500', Colors.green),
        _buildDetailItem('February', '-\$3,800.00', 'Fixed Costs focus', Colors.green),
        _buildDetailItem('March', '-\$5,100.00', 'Leisure & Travel', Colors.orange),
        _buildDetailItem('April', '-\$4,980.00', 'Current Month', Colors.blue),
      ],
    );
  }

  Widget _buildWeekView(Color themeColor, Color textMain, Color textMuted) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_days.length, (index) {
        final day = _days[index];
        final isSelected = _selectedDayIndex == index;
        return GestureDetector(
          onTap: () => setState(() => _selectedDayIndex = index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: isSelected ? themeColor : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  day['label']!,
                  style: TextStyle(
                    color: isSelected ? Colors.white : textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  day['day']!,
                  style: TextStyle(
                    color: isSelected ? Colors.white : textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCalendarView(Color themeColor, Color textMain, Color textMuted) {
    final List<String> weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    const int daysInMonth = 30;
    const int firstDayOffset = 3; // April 1, 2026 is Wed (S=0, M=1, T=2, W=3)

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekdays
              .map((d) => SizedBox(
                    width: 30,
                    child: Text(d,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
                  ))
              .toList(),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
            childAspectRatio: 1,
          ),
          itemCount: daysInMonth + firstDayOffset,
          itemBuilder: (context, index) {
            if (index < firstDayOffset) return const SizedBox();
            final day = index - firstDayOffset + 1;
            final isSelected = day == 21; // April 21st
            return Center(
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isSelected ? themeColor : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : textMain,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMonthView(Color themeColor, Color textMain, Color textMuted) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final isSelected = index == 3; // April
        return Container(
          decoration: BoxDecoration(
            color: isSelected ? themeColor : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black12),
          ),
          alignment: Alignment.center,
          child: Text(
            months[index],
            style: TextStyle(
              color: isSelected ? Colors.white : textMain,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        );
      },
    );
  }

  Widget _buildYearView(Color themeColor, Color textMain, Color textMuted) {
    final years = ['2023', '2024', '2025', '2026'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: years.map((year) {
        final isSelected = year == '2026';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? themeColor : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? Colors.transparent : Colors.black12),
          ),
          child: Text(
            year,
            style: TextStyle(
              color: isSelected ? Colors.white : textMain,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickMenuItem(IconData icon, String label, Color themeColor) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: themeColor),
          ),
          const SizedBox(height: 20),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String title, String amount, String time, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.1),
          child: Icon(Icons.circle, color: iconColor, size: 12),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(time),
        trailing: Text(
          amount,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
      ),
    );
  }
}

class Goal {
  final String title;
  final double targetAmount;
  double currentAmount;
  final Color color;

  Goal({
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.color,
  });
}
