import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class NetWorthView extends StatefulWidget {
  const NetWorthView({super.key});

  @override
  State<NetWorthView> createState() => _NetWorthViewState();
}

class _NetWorthViewState extends State<NetWorthView> {
  String _selectedTimeframe = 'Year'; // 'Week', 'Month', 'Year'

  // --- Goals State (Moved from ActivityView) ---
  final List<String> _availableAssets = [
    'Cash',
    'Bitcoin',
    'Gold',
    'Alphabet',
    'Amazon',
    'Apple',
    'Meta Platforms',
    'Microsoft',
    'NVIDIA',
    'Tesla',
  ];

  final Map<String, IconData> _assetIcons = {
    'Cash': Icons.account_balance_wallet_rounded,
    'Bitcoin': Icons.currency_bitcoin_rounded,
    'Gold': Icons.workspace_premium_rounded,
    'Alphabet': Icons.search_rounded,
    'Amazon': Icons.shopping_bag_rounded,
    'Apple': Icons.apple,
    'Meta Platforms': Icons.facebook_rounded,
    'Microsoft': Icons.grid_view_rounded,
    'NVIDIA': Icons.memory_rounded,
    'Tesla': Icons.electric_car_rounded,
  };

  final Map<String, String> _assetPrices = {
    'Cash': '\$12,450',
    'Bitcoin': '\$68,420.00',
    'Gold': '\$2,350.40/oz',
    'Alphabet': '\$175.20',
    'Amazon': '\$182.15',
    'Apple': '\$190.40',
    'Meta Platforms': '\$475.30',
    'Microsoft': '\$420.10',
    'NVIDIA': '\$950.40',
    'Tesla': '\$170.60',
  };

  final Map<String, List<FlSpot>> _assetSparklines = {
    'Cash': const [FlSpot(0, 1), FlSpot(1, 1.1), FlSpot(2, 1.05), FlSpot(3, 1.2), FlSpot(4, 1.15)],
    'Bitcoin': const [FlSpot(0, 1), FlSpot(1, 0.8), FlSpot(2, 1.5), FlSpot(3, 1.2), FlSpot(4, 2.1)],
    'Gold': const [FlSpot(0, 1), FlSpot(1, 1.05), FlSpot(2, 1.1), FlSpot(3, 1.08), FlSpot(4, 1.25)],
    'Alphabet': const [FlSpot(0, 1), FlSpot(1, 1.2), FlSpot(2, 1.15), FlSpot(3, 1.3), FlSpot(4, 1.4)],
    'Amazon': const [FlSpot(0, 1), FlSpot(1, 1.1), FlSpot(2, 1.3), FlSpot(3, 1.2), FlSpot(4, 1.5)],
    'Apple': const [FlSpot(0, 1), FlSpot(1, 1.05), FlSpot(2, 1.02), FlSpot(3, 1.08), FlSpot(4, 1.12)],
    'Meta Platforms': const [FlSpot(0, 1), FlSpot(1, 1.4), FlSpot(2, 1.3), FlSpot(3, 1.6), FlSpot(4, 1.8)],
    'Microsoft': const [FlSpot(0, 1), FlSpot(1, 1.1), FlSpot(2, 1.2), FlSpot(3, 1.15), FlSpot(4, 1.3)],
    'NVIDIA': const [FlSpot(0, 1), FlSpot(1, 1.5), FlSpot(2, 2.2), FlSpot(3, 2.8), FlSpot(4, 3.5)],
    'Tesla': const [FlSpot(0, 1), FlSpot(1, 0.9), FlSpot(2, 0.8), FlSpot(3, 0.85), FlSpot(4, 0.75)],
  };

  final List<Goal> _goals = [
    Goal(title: 'New Car', targetAmount: 20000, currentAmount: 5000, color: Colors.blue, linkedAsset: 'Savings'),
    Goal(title: 'Emergency Fund', targetAmount: 10000, currentAmount: 8500, color: Colors.green, linkedAsset: 'Cash'),
    Goal(title: 'Vacation', targetAmount: 5000, currentAmount: 1200, color: Colors.orange, linkedAsset: 'Savings'),
  ];

  void _addNewGoal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String title = '';
        double target = 0;
        String? selectedAsset;

        return StatefulBuilder(
          builder: (context, setModalState) => DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) => Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FE),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Stack(
                children: [
                  // Top Gradient Accent
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 180,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF8E84FF), Color(0xFF4F3FF0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10)),
                      ),
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Text(
                              'Create New Goal',
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                          ),
                          padding: const EdgeInsets.all(24),
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                const Text('What are you saving for?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey)),
                                const SizedBox(height: 12),
                                TextField(
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                  decoration: InputDecoration(
                                    hintText: 'e.g., New Laptop',
                                    hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w400),
                                    filled: true,
                                    fillColor: const Color(0xFFF5F5F7),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                                  ),
                                  onChanged: (value) => title = value,
                                ),
                                const SizedBox(height: 24),
                                const Text('Target Value', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey)),
                                const SizedBox(height: 12),
                                TextField(
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                                  decoration: InputDecoration(
                                    hintText: '0.00',
                                    prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF4F3FF0)),
                                    filled: true,
                                    fillColor: const Color(0xFFF5F5F7),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) => target = double.tryParse(value) ?? 0,
                                ),
                                const SizedBox(height: 32),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Stacking on (Asset)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
                                    Text('See all', style: TextStyle(color: Colors.grey[400], fontSize: 13, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _availableAssets.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    String asset = _availableAssets[index];
                                    bool isSelected = selectedAsset == asset;
                                    return _buildAssetSelectionCard(
                                      asset,
                                      isSelected,
                                      () => setModalState(() => selectedAsset = isSelected ? null : asset),
                                    );
                                  },
                                ),
                                const SizedBox(height: 40),
                                Container(
                                  width: double.infinity,
                                  height: 65,
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
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (title.isNotEmpty && target > 0) {
                                        setState(() {
                                          _goals.add(Goal(
                                            title: title,
                                            targetAmount: target,
                                            currentAmount: 0,
                                            color: Colors.primaries[_goals.length % Colors.primaries.length],
                                            linkedAsset: selectedAsset,
                                          ));
                                        });
                                        Navigator.pop(context);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                    ),
                                    child: const Text('Create Goal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAssetSelectionCard(String asset, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFFBFBFF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFF4F3FF0) : Colors.grey.withValues(alpha: 0.05),
            width: 2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: const Color(0xFF4F3FF0).withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF4F3FF0).withValues(alpha: 0.1) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                  )
                ],
              ),
              child: Icon(
                _assetIcons[asset],
                size: 24,
                color: isSelected ? const Color(0xFF4F3FF0) : Colors.black87,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? const Color(0xFF4F3FF0) : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _assetPrices[asset] ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 35,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _assetSparklines[asset] ?? [],
                        isCurved: true,
                        color: isSelected ? const Color(0xFF4F3FF0) : Colors.grey[300],
                        barWidth: 2.5,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: (isSelected ? const Color(0xFF4F3FF0) : Colors.grey[300]!).withValues(alpha: 0.05),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF4F3FF0) : Colors.grey[300]!,
                  width: 2,
                ),
                color: isSelected ? const Color(0xFF4F3FF0) : Colors.transparent,
              ),
              child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFundsDialog(Goal goal) {
    double amountToAdd = 0;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Add funds to ${goal.title}'),
        content: TextField(
          decoration: InputDecoration(
            hintText: '0.00',
            prefixText: '\$ ',
            filled: true,
            fillColor: const Color(0xFFF5F5F7),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) => amountToAdd = double.tryParse(value) ?? 0,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (amountToAdd > 0) {
                setState(() => goal.currentAmount += amountToAdd);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F3FF0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

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
                      'Net Worth',
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

                // Net Worth Summary Card
                _buildNetWorthSummaryCard(),
                const SizedBox(height: 32),

                // --- My Goals Section (Moved from ActivityView) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Goals',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
                    ),
                    IconButton(
                      onPressed: _addNewGoal,
                      icon: const Icon(Icons.add_circle_outline, color: Color(0xFF4F3FF0)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _goals.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                    itemBuilder: (context, index) => _buildGoalCard(_goals[index]),
                  ),
                ),
                const SizedBox(height: 32),

                // Growth Chart
                const Text(
                  'Wealth Growth',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 16),
                _buildGrowthChart(),
                const SizedBox(height: 32),

                // Asset Allocation
                const Text(
                  'Asset Allocation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 16),
                _buildAssetAllocation(),
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
        children: ['Week', 'Month', 'Year'].map((timeframe) {
          bool isSelected = _selectedTimeframe == timeframe;
          return GestureDetector(
            onTap: () => setState(() => _selectedTimeframe = timeframe),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _buildNetWorthSummaryCard() {
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
                  Text('Current Net Worth', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  SizedBox(height: 4),
                  Text(
                    '\$124,570.80',
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
                    Text('+12.5%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildSimpleStat('Assets', '\$145,200'),
              const SizedBox(width: 40),
              _buildSimpleStat('Liabilities', '\$20,630'),
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

  Widget _buildGrowthChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [FlSpot(0, 1), FlSpot(1, 1.5), FlSpot(2, 1.4), FlSpot(3, 2), FlSpot(4, 2.5), FlSpot(5, 2.2), FlSpot(6, 3)],
              isCurved: true,
              color: const Color(0xFF4F3FF0),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: const Color(0xFF4F3FF0).withValues(alpha: 0.1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetAllocation() {
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
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(color: const Color(0xFF4F3FF0), value: 40, title: 'Stocks', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  PieChartSectionData(color: const Color(0xFF8E84FF), value: 30, title: 'Cash', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  PieChartSectionData(color: const Color(0xFF1A1A1A), value: 20, title: 'Crypto', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  PieChartSectionData(color: const Color(0xFFF1F1F1), value: 10, title: 'Other', radius: 50, titleStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildAllocationItem('Stocks & Funds', '40%', const Color(0xFF4F3FF0)),
          _buildAllocationItem('Cash & Savings', '30%', const Color(0xFF8E84FF)),
          _buildAllocationItem('Digital Assets', '20%', const Color(0xFF1A1A1A)),
          _buildAllocationItem('Others', '10%', Colors.grey[200]!),
        ],
      ),
    );
  }

  Widget _buildAllocationItem(String label, String percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
          const Spacer(),
          Text(percentage, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
        ],
      ),
    );
  }

  Widget _buildGoalCard(Goal goal) {
    double progress = goal.currentAmount / goal.targetAmount;
    if (progress > 1.0) progress = 1.0;

    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)), overflow: TextOverflow.ellipsis),
                    if (goal.linkedAsset != null)
                      Row(
                        children: [
                          Icon(_assetIcons[goal.linkedAsset] ?? Icons.help_outline, size: 12, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            'on ${goal.linkedAsset}',
                            style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: goal.color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(Icons.stars, color: goal.color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('\$${goal.currentAmount.toStringAsFixed(0)} / \$${goal.targetAmount.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFF5F5F7),
              valueColor: AlwaysStoppedAnimation<Color>(goal.color),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(progress * 100).toStringAsFixed(0)}%', style: TextStyle(color: goal.color, fontWeight: FontWeight.w800, fontSize: 14)),
              GestureDetector(
                onTap: () => _showAddFundsDialog(goal),
                child: const Text('Add Funds', style: TextStyle(color: Color(0xFF4F3FF0), fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Goal {
  final String title;
  final double targetAmount;
  double currentAmount;
  final Color color;
  final String? linkedAsset;

  Goal({
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.color,
    this.linkedAsset,
  });
}
