import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

// Model for concert transaction
class Transaction {
  final String id;
  final ConcertDetails concertDetails;
  final String createdAt;
  final String paymentMethod;
  final int quantity;
  final int statusPayment;
  final int totalCost;
  final UserDetails userDetails;

  Transaction({
    required this.id,
    required this.concertDetails,
    required this.createdAt,
    required this.paymentMethod,
    required this.quantity,
    required this.statusPayment,
    required this.totalCost,
    required this.userDetails,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['_id'],
      concertDetails: json['concert_details'] is String 
          ? ConcertDetails.empty()
          : ConcertDetails.fromJson(json['concert_details']),
      createdAt: json['created_at'],
      paymentMethod: json['payment_method'],
      quantity: json['quantity'],
      statusPayment: json['status_payment'],
      totalCost: json['total_cost'],
      userDetails: UserDetails.fromJson(json['user_details']),
    );
  }
}

class ConcertDetails {
  final String date;
  final String location;
  final int price;
  final String title;

  ConcertDetails({
    required this.date,
    required this.location,
    required this.price,
    required this.title,
  });

  factory ConcertDetails.fromJson(Map<String, dynamic> json) {
    return ConcertDetails(
      date: json['date'],
      location: json['location'],
      price: json['price'],
      title: json['title'],
    );
  }

  factory ConcertDetails.empty() {
    return ConcertDetails(
      date: 'N/A',
      location: 'N/A',
      price: 0,
      title: 'Concert details not available',
    );
  }
}

class UserDetails {
  final String email;
  final String name;
  final String phone;

  UserDetails({
    required this.email,
    required this.name,
    required this.phone,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
    );
  }
}

class PesananScreen extends StatefulWidget {
  @override
  _PesananScreenState createState() => _PesananScreenState();
}

class _PesananScreenState extends State<PesananScreen> {
  List<Transaction> transactions = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      final response = await http.get(
        Uri.parse('https://api-ticketconcert.vercel.app/api/transactions'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          setState(() {
            transactions = (jsonData['data'] as List)
                .map((item) => Transaction.fromJson(item))
                .toList();
            isLoading = false;
          });
        } else {
          throw Exception('API returned error status');
        }
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  String getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Menunggu Pembayaran';
      case 1:
        return 'Pembayaran Berhasil';
      case 2:
        return 'Pembayaran Gagal';
      default:
        return 'Status Tidak Diketahui';
    }
  }

  Color getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.green;
      case 2:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String formatCurrency(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  void _showTransactionDetail(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detail Pesanan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Divider(),
            _buildDetailItem('ID Transaksi', transaction.id),
            _buildDetailItem('Tanggal', formatDate(transaction.createdAt)),
            _buildDetailItem('Status', getStatusText(transaction.statusPayment)),
            _buildDetailItem('Pembeli', transaction.userDetails.name),
            _buildDetailItem('Email', transaction.userDetails.email),
            _buildDetailItem('Metode Pembayaran', transaction.paymentMethod),
            SizedBox(height: 16),
            Text(
              'Detail Konser',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.concertDetails.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      transaction.concertDetails.location,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      'Tanggal: ${transaction.concertDetails.date}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${transaction.quantity}x ${formatCurrency(transaction.concertDetails.price)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Pembayaran',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  formatCurrency(transaction.totalCost),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C6B6F),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Daftar Pesanan'),
          backgroundColor: Color(0xFF1C6B6F),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Daftar Pesanan'),
          backgroundColor: Color(0xFF1C6B6F),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    error = null;
                  });
                  fetchTransactions();
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Pesanan'),
        backgroundColor: Color(0xFF1C6B6F),
      ),
      body: transactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada pesanan',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: fetchTransactions,
              child: ListView.builder(
                itemCount: transactions.length,
                padding: EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      onTap: () => _showTransactionDetail(transaction),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    transaction.concertDetails.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: getStatusColor(transaction.statusPayment)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    getStatusText(transaction.statusPayment),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: getStatusColor(
                                          transaction.statusPayment),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              formatDate(transaction.createdAt),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            Divider(),
                            Text(
                              transaction.concertDetails.location,
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Tanggal Konser: ${transaction.concertDetails.date}',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${transaction.quantity} tiket',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  formatCurrency(transaction.totalCost),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1C6B6F),
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
              ),
            ),
    );
  }
}