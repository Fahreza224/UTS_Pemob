import 'package:flutter/material.dart';

class KeranjangScreen extends StatelessWidget {
  final String namaPemesanan;
  final int jumlah;
  final DateTime? tanggalDikirim;
  final TimeOfDay? jamDikirim;
  final String metodePembayaran;
  final List<String> jenisGalon;
  final int hargaPerGalon = 15000; // Harga per galon

  KeranjangScreen({
    required this.namaPemesanan,
    required this.jumlah,
    required this.tanggalDikirim,
    required this.jamDikirim,
    required this.metodePembayaran,
    required this.jenisGalon,
  });

  @override
  Widget build(BuildContext context) {
    final int totalHarga = jumlah * hargaPerGalon;

    return Scaffold(
      backgroundColor: Color(0xFFCAF0F8), // Pale Aqua color directly used here
      appBar: AppBar(
        title: Text('Keranjang'),
        backgroundColor: Color(0xFF1C6B6F), // Primary Aqua color directly used here
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detail Pemesanan',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0077B6), // Dark Aqua color directly used here
                ),
              ),
              SizedBox(height: 20),
              _buildDetailBox('Nama Pemesanan', namaPemesanan),
              _buildDetailBox('Jumlah Pesanan', '$jumlah'),
              _buildDetailBox(
                'Tanggal Dikirim',
                tanggalDikirim != null
                    ? tanggalDikirim!.toLocal().toString().split(' ')[0]
                    : '',
              ),
              _buildDetailBox(
                'Jam Dikirim',
                jamDikirim != null ? jamDikirim!.format(context) : '',
              ),
              _buildDetailBox('Metode Pembayaran', metodePembayaran),
              _buildDetailBox('Jenis Galon', jenisGalon.join(', ')),
              _buildDetailBox('Total Harga', 'Rp$totalHarga'),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Kembali'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF90E0EF), // Light Aqua color directly used here
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      final orderData = {
                        'namaPemesanan': namaPemesanan,
                        'jumlah': jumlah,
                        'tanggalDikirim': tanggalDikirim != null
                            ? tanggalDikirim!.toLocal().toString().split(' ')[0]
                            : '',
                        'jamDikirim': jamDikirim != null
                            ? jamDikirim!.format(context)
                            : '',
                        'metodePembayaran': metodePembayaran,
                        'jenisGalon': jenisGalon.join(', '),
                        'totalHarga': totalHarga,
                      };

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RiwayatPemesananScreen(
                            riwayatPesanan: [orderData],
                          ),
                        ),
                      );
                    },
                    child: Text('Order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0077B6), // Dark Aqua color directly used here
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
  }

  Widget _buildDetailBox(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0077B6), // Dark Aqua color directly used here
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class RiwayatPemesananScreen extends StatelessWidget {
  final List<Map<String, dynamic>> riwayatPesanan;

  RiwayatPemesananScreen({required this.riwayatPesanan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Pemesanan'),
        backgroundColor: Color(0xFF00ACC1), // Matching the original AppBar color
      ),
      body: ListView.builder(
        itemCount: riwayatPesanan.length,
        itemBuilder: (context, index) {
          final pesanan = riwayatPesanan[index];
          return ListTile(
            title: Text(pesanan['namaPemesanan']),
            subtitle: Text('Jumlah: ${pesanan['jumlah']}'),
            trailing: Text('Metode: ${pesanan['metodePembayaran']}'),
          );
        },
      ),
    );
  }
}
