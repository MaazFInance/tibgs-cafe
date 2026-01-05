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
  // Future vars
  late Future<List<Session>> _historyFuture;
  late Future<double> _dailyRevenueFuture;

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Revenue & Knowledge')),
      body: FutureBuilder<List<Session>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final history = snapshot.data!;

          return Column(
            children: [
              // 1. REVENUE CHART / SUMMARY
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                height: 300,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade900, Colors.purple.shade900],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5)),
                  ],
                ),
                child: Column(
                  children: [
                    const Text('TOTAL REVENUE TODAY',
                        style: TextStyle(letterSpacing: 1.5, fontSize: 12)),
                    const SizedBox(height: 8),
                    FutureBuilder<double>(
                      future: _dailyRevenueFuture,
                      builder: (c, s) => Text(
                        '₹ ${s.data?.toStringAsFixed(2) ?? "0.00"}',
                        style: const TextStyle(
                            fontSize: 36, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: FutureBuilder<Map<DateTime, double>>(
                        future: DatabaseHelper.instance.getWeeklyRevenue(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox();
                          final data = snapshot.data!;
                          final dataEntries = data.entries.toList();
                          final spots =
                              List.generate(dataEntries.length, (index) {
                            return FlSpot(
                                index.toDouble(), dataEntries[index].value);
                          });

                          return LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: false),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      // value is index 0..6
                                      if (value < 0 ||
                                          value >= dataEntries.length) {
                                        return const SizedBox();
                                      }
                                      final date =
                                          dataEntries[value.toInt()].key;
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          DateFormat('E').format(date)[0],
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 10),
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
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: spots.isEmpty
                                      ? [const FlSpot(0, 0)]
                                      : spots,
                                  isCurved: true,
                                  color: Colors.cyanAccent,
                                  barWidth: 3,
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.cyanAccent.withOpacity(0.1),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // 2. HISTORY LIST
              Expanded(
                child: ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final session = history[index];
                    return ListTile(
                      leading: Icon(
                        session.deviceType == 'PC'
                            ? Icons.monitor
                            : Icons.videogame_asset,
                        color: Colors.white54,
                      ),
                      title: Text(session.deviceName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(DateFormat('MMM dd, hh:mm a')
                          .format(session.startTime)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₹ ${session.totalCost.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold)),
                          Text('${session.durationMinutes} min',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
