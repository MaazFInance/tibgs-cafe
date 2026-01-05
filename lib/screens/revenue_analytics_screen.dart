import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/session_model.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class RevenueAnalyticsScreen extends StatefulWidget {
  const RevenueAnalyticsScreen({super.key});

  @override
  State<RevenueAnalyticsScreen> createState() => _RevenueAnalyticsScreenState();
}

class _RevenueAnalyticsScreenState extends State<RevenueAnalyticsScreen> {
  late Future<List<Session>> _historyFuture;
  late Future<double> _dailyRevenueFuture;
  late Future<Map<DateTime, double>> _monthlyRevenueFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _historyFuture = DatabaseHelper.instance.getAllSessions();
      _dailyRevenueFuture =
          DatabaseHelper.instance.getDailyRevenue(DateTime.now());
      _monthlyRevenueFuture = DatabaseHelper.instance.getMonthlyRevenue();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ANALYTICS & HISTORY',
            style: Theme.of(context).textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildRevenueCard(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('RECENT SESSIONS',
                      style: Theme.of(context).textTheme.titleMedium)),
            ),
            _buildHistoryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueCard() {
    return Container(
      height: 400,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
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
                  Text('30-DAY TREND',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  FutureBuilder<double>(
                    future: _dailyRevenueFuture,
                    builder: (c, s) => Text(
                      'Today: ₹ ${s.data?.toStringAsFixed(0) ?? "0"}',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Icon(Icons.bar_chart,
                  color: Theme.of(context).primaryColor, size: 32),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: FutureBuilder<Map<DateTime, double>>(
              future: _monthlyRevenueFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                final data = snapshot.data!;
                // Ensure data is sorted by date
                final sortedEntries = data.entries.toList()
                  ..sort((a, b) => a.key.compareTo(b.key));

                List<BarChartGroupData> barGroups = [];
                for (int i = 0; i < sortedEntries.length; i++) {
                  barGroups.add(
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: sortedEntries[i].value,
                          color: sortedEntries[i].value > 0
                              ? Theme.of(context).primaryColor
                              : Colors.grey.withOpacity(0.2),
                          width: 6,
                          borderRadius: BorderRadius.circular(2),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: 1000, // Max scale placeholder
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        )
                      ],
                    ),
                  );
                }

                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 2000, // Fixed max for scale or dynamic
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Theme.of(context).cardTheme.color,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final date = sortedEntries[group.x.toInt()].key;
                          return BarTooltipItem(
                            '${DateFormat('MM/dd').format(date)}\n',
                            const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 10),
                            children: [
                              TextSpan(
                                text: '₹ ${rod.toY.toInt()}',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() % 5 != 0)
                              return const SizedBox(); // Show every 5th date
                            if (value.toInt() >= sortedEntries.length)
                              return const SizedBox();
                            final date = sortedEntries[value.toInt()].key;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('dd').format(date),
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return FutureBuilder<List<Session>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.isEmpty)
          return const Padding(
              padding: EdgeInsets.all(20), child: Text('No history yet'));

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: snapshot.data!.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final session = snapshot.data![index];
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color?.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: session.deviceType == 'PC'
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.purple.withOpacity(0.1),
                  child: Icon(
                    session.deviceType == 'PC' ? Icons.computer : Icons.gamepad,
                    color: session.deviceType == 'PC'
                        ? Colors.blue
                        : Colors.purple,
                    size: 20,
                  ),
                ),
                title: Text(session.deviceName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    DateFormat('MMM dd, hh:mm a').format(session.startTime),
                    style: Theme.of(context).textTheme.bodySmall),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹ ${session.totalCost.toStringAsFixed(0)}',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    Text('${session.durationMinutes} min',
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
