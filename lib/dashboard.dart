import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

  // Data models
  class DailyRevenue {
    final DateTime date;
    final int revenue;
    final int tickets;
    final int orders;

    DailyRevenue({
      required this.date,
      required this.revenue,
      required this.tickets,
      required this.orders,
    });
  }

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _timer;
  List<FlSpot> _salesData = [];
  DateTime _lastUpdate = DateTime.now();
  int _sales = 0;
  int _productsSold = 0;
  int _concertCount = 0;
  int _todayOrders = 0;
  bool _isLoading = true;
  String _errorMessage = '';
  
  // Monthly revenue table variables
  DateTime _selectedMonth = DateTime.now();
  List<DailyRevenue> _monthlyRevenue = [];
  int _monthlyTotal = 0;
  bool _isTableLoading = false;
  
  // API endpoints
  final String concertApiUrl = 'https://api-ticketconcert.vercel.app/api/concerts';
  final String transactionApiUrl = 'https://api-ticketconcert.vercel.app/api/transactions';

  // Currency formatter
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupPeriodicUpdate();
  }

  void _initializeData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await Future.wait([
        _initializeSalesData(),
        _fetchConcertCount(),
        _fetchTransactions(),
        _fetchMonthlyRevenue(),
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan saat memuat data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setupPeriodicUpdate() {
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      _updateData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }



  // API calls and data processing
  Future<void> _initializeSalesData() async {
    _salesData = List.generate(7, (index) {
      return FlSpot(index.toDouble(), 0);
    });
  }

  Future<void> _fetchConcertCount() async {
    try {
      final response = await http.get(Uri.parse(concertApiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> concerts = json.decode(response.body);
        setState(() {
          _concertCount = concerts.length;
        });
      } else {
        throw Exception('Failed to load concert data');
      }
    } catch (e) {
      print('Error fetching concert count: $e');
      throw e;
    }
  }

  Future<void> _fetchTransactions() async {
    try {
      final response = await http.get(Uri.parse(transactionApiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          final List<dynamic> transactions = jsonResponse['data'];
          _processTransactions(transactions);
        } else {
          throw Exception('API returned error status');
        }
      } else {
        throw Exception('Failed to load transaction data');
      }
    } catch (e) {
      print('Error fetching transactions: $e');
      throw e;
    }
  }

  void _processTransactions(List<dynamic> transactions) {
    // Count today's completed orders
    int todayCompletedOrders = 0;
    int totalSales = 0;
    int totalTickets = 0;

    for (var tx in transactions) {
      if (_isToday(tx['created_at']) && tx['status_payment'] == 1) {
        todayCompletedOrders++;
        totalSales += tx['total_cost'] as int;
        totalTickets += tx['quantity'] as int;
      }
    }

    setState(() {
      _todayOrders = todayCompletedOrders;
      _sales = totalSales;
      _productsSold = totalTickets;
    });

    _updateSalesChart(transactions);
  }

  Future<void> _fetchMonthlyRevenue() async {
    setState(() {
      _isTableLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(transactionApiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          final List<dynamic> transactions = jsonResponse['data'];
          _processMonthlyRevenue(transactions);
        }
      }
    } catch (e) {
      print('Error fetching monthly revenue: $e');
    } finally {
      setState(() {
        _isTableLoading = false;
      });
    }
  }

  void _processMonthlyRevenue(List<dynamic> transactions) {
    // Filter and group transactions by day
    Map<int, DailyRevenue> dailyData = {};
    
    // Initialize all days of the month
    final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    for (int day = 1; day <= daysInMonth; day++) {
      dailyData[day] = DailyRevenue(
        date: DateTime(_selectedMonth.year, _selectedMonth.month, day),
        revenue: 0,
        tickets: 0,
        orders: 0,
      );
    }

    // Process transactions
    for (var tx in transactions) {
      try {
        final txDate = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parse(tx['created_at']);
        
        if (txDate.year == _selectedMonth.year && 
            txDate.month == _selectedMonth.month && 
            tx['status_payment'] == 1) {
          final day = txDate.day;
          final currentData = dailyData[day]!;
          
          dailyData[day] = DailyRevenue(
            date: currentData.date,
            revenue: currentData.revenue + (tx['total_cost'] as int),
            tickets: currentData.tickets + (tx['quantity'] as int),
            orders: currentData.orders + 1,
          );
        }
      } catch (e) {
        print('Error processing transaction: $e');
      }
    }

    // Calculate monthly total
    final total = dailyData.values.fold(0, (sum, daily) => sum + daily.revenue);

    setState(() {
      _monthlyRevenue = dailyData.values.toList()..sort((a, b) => a.date.compareTo(b.date));
      _monthlyTotal = total;
    });
  }

  void _updateSalesChart(List<dynamic> transactions) {
    Map<String, double> dailySales = {};
    final now = DateTime.now();
    
    // Initialize last 7 days
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      dailySales[dateStr] = 0;
    }
    
    // Calculate daily sales
    for (var tx in transactions) {
      if (tx['status_payment'] == 1) {
        try {
          final txDate = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parse(tx['created_at']);
          final dateStr = DateFormat('yyyy-MM-dd').format(txDate);
          
          if (dailySales.containsKey(dateStr)) {
            dailySales[dateStr] = (dailySales[dateStr] ?? 0) + 
                (tx['total_cost'] as int) / 1000;
          }
        } catch (e) {
          print('Error processing transaction for chart: $e');
        }
      }
    }
    
    setState(() {
      _salesData = dailySales.entries.map((entry) {
        return FlSpot(
          dailySales.keys.toList().indexOf(entry.key).toDouble(),
          entry.value
        );
      }).toList();
    });
  }

  void _updateData() {
    _fetchConcertCount();
    _fetchTransactions();
    _fetchMonthlyRevenue();
    setState(() {
      _lastUpdate = DateTime.now();
    });
  }

  // Helper methods
  bool _isToday(String dateString) {
    try {
      final inputFormat = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'");
      final orderDate = inputFormat.parse(dateString);
      final now = DateTime.now();
      
      return orderDate.year == now.year &&
             orderDate.month == now.month &&
             orderDate.day == now.day;
    } catch (e) {
      print('Error parsing date: $e');
      return false;
    }
  }

  // UI Building methods
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'Fly Admin',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: Colors.black),
          onPressed: _updateData,
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(_errorMessage),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeData,
              child: Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _updateData(),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Penting hari ini', showInfo: true),
              SizedBox(height: 12),
              _buildActivityGrid(),
              
              SizedBox(height: 24),
              _buildSectionTitle('Analisis toko dan produkmu', showInfo: true),
              _buildLastUpdateText(),
              SizedBox(height: 16),
              
              _buildStatisticsSection(),
              SizedBox(height: 24),
              
              _buildSalesChart(),
              SizedBox(height: 24),
              
              _buildMonthlyRevenueSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool showInfo = false}) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (showInfo) 
          IconButton(
            icon: Icon(Icons.info_outline, size: 16),
            onPressed: () {
              // Show info dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Informasi'),
                  content: Text('Statistik diperbarui setiap menit secara otomatis.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildLastUpdateText() {
    return Text(
      'Update Terakhir: ${DateFormat('d MMM y HH:mm').format(_lastUpdate)} WIB',
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: 12,
      ),
    );
  }

  Widget _buildActivityGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildActivityCard('Pesanan Selesai Hari Ini', '$_todayOrders'),
        _buildActivityCard('Jumlah Konser', '$_concertCount'),
      ],
    );
  }

  Widget _buildActivityCard(String title, String count) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Spacer(),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Penjualan Hari Ini',
            currencyFormatter.format(_sales),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Tiket Terjual Hari Ini',
            _productsSold.toString(),
            subtitle: '+${((_productsSold / 1) * 100).toStringAsFixed(0)}%',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, {String? subtitle}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.green,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSalesChart() {
    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grafik Penjualan 7 Hari Terakhir',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 1000,
                  verticalInterval: 1,
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final date = DateTime.now().subtract(
                          Duration(days: (6 - value).toInt()),
                        );
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('d MMM').format(date),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}K',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _salesData,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.1),
                    ),
                  ),
                ],
                minY: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyRevenueSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Pendapatan Bulanan', showInfo: true),
        SizedBox(height: 16),
        _buildMonthSelector(),
        SizedBox(height: 16),
        _buildRevenueTable(),
      ],
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month - 1,
                );
                _fetchMonthlyRevenue();
              });
            },
          ),
          Text(
            DateFormat('MMMM yyyy').format(_selectedMonth),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month + 1,
                );
                _fetchMonthlyRevenue();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueTable() {
    if (_isTableLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(
              label: Text('Tanggal'),
              tooltip: 'Tanggal transaksi',
            ),
            DataColumn(
              label: Text('Pendapatan'),
              tooltip: 'Total pendapatan harian',
              numeric: true,
            ),
            DataColumn(
              label: Text('Tiket'),
              tooltip: 'Jumlah tiket terjual',
              numeric: true,
            ),
            DataColumn(
              label: Text('Pesanan'),
              tooltip: 'Jumlah pesanan',
              numeric: true,
            ),
          ],
          rows: [
            ..._monthlyRevenue.map((daily) => DataRow(
              cells: [
                DataCell(Text(
                  DateFormat('d MMM yyyy').format(daily.date),
                )),
                DataCell(Text(
                  currencyFormatter.format(daily.revenue),
                )),
                DataCell(Text(
                  daily.tickets.toString(),
                )),
                DataCell(Text(
                  daily.orders.toString(),
                )),
              ],
            )).toList(),
            // Total row
            DataRow(
              cells: [
                DataCell(Text(
                  'Total',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
                DataCell(Text(
                  currencyFormatter.format(_monthlyTotal),
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
                DataCell(Text(
                  _monthlyRevenue
                    .fold(0, (sum, daily) => sum + daily.tickets)
                    .toString(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
                DataCell(Text(
                  _monthlyRevenue
                    .fold(0, (sum, daily) => sum + daily.orders)
                    .toString(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
            