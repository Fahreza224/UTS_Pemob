import 'package:flutter/material.dart';

class PemesananScreen extends StatefulWidget {
  @override
  _PemesananScreenState createState() => _PemesananScreenState();
}

class _PemesananScreenState extends State<PemesananScreen> {
  final _formKey = GlobalKey<FormState>();

  final Color primaryColor = Color(0xFF1C6B6F);
  final Color secondaryColor = Color(0xFF1C6B6F);
  final Color backgroundColor = Color(0xFF1C6B6F);
  final Color cardColor = Colors.white;
  final Color textColor = Color(0xFF1C6B6F);

  TextEditingController _namaController = TextEditingController();
  TextEditingController _jumlahController = TextEditingController();
  DateTime? _tanggalDikirim;
  TimeOfDay? _jamDikirim;

  String _metodePembayaran = 'Tunai';
  final List<String> _pembayaranOptions = [
    'Tunai',
    'Transfer',
    'OVO',
    'Gopay',
    'Debit'
  ];

  final Map<String, int> _galonPrices = {
    'afkir': 22000,
    'Le kampung': 20000,
    'jantan': 19000,
    'broiler': 21000,
  };

  Map<String, bool> _jenisGalon = {
    'afkir': false,
    'Le kampung': false,
    'jantan': false,
    'broiler': false,
  };

  int _totalCost = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Pemesanan',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundColor, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildSectionCard(
                  'Data Pemesanan',
                  Icon(Icons.person_outline, color: primaryColor, size: 28),
                  Column(
                    children: [
                      _buildTextField(
                        controller: _namaController,
                        label: 'Nama Pemesanan',
                        validatorMessage: 'Nama pemesanan wajib diisi',
                        prefixIcon: Icons.person,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _jumlahController,
                        label: 'Jumlah yang Dipesan',
                        keyboardType: TextInputType.number,
                        validatorMessage: 'Jumlah yang dipesan wajib diisi',
                        validatorType: 'number',
                        onChanged: (value) => _calculateTotalCost(),
                        prefixIcon: Icons.shopping_cart,
                      ),
                    ],
                  ),
                ),
                _buildSectionCard(
                  'Waktu Pengiriman',
                  Icon(Icons.access_time, color: primaryColor, size: 28),
                  _buildModernDateTimeSection(),
                ),
                _buildSectionCard(
                  'Metode Pembayaran',
                  Icon(Icons.payment, color: primaryColor, size: 28),
                  _buildModernRadioList(),
                ),
                _buildSectionCard(
                  'Jenis ayam',
                  Icon(Icons.water_drop, color: primaryColor, size: 28),
                  _buildModernCheckboxList(),
                ),
                _buildSectionCard(
                  'Ringkasan Pembayaran',
                  Icon(Icons.receipt_long, color: primaryColor, size: 28),
                  _buildModernPriceSummary(),
                ),
                SizedBox(height: 24),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, Icon icon, Widget content) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                icon,
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? validatorMessage,
    TextInputType keyboardType = TextInputType.text,
    String? validatorType,
    void Function(String)? onChanged,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textColor),
        prefixIcon: Icon(prefixIcon, color: primaryColor),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primaryColor),
        ),
      ),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorMessage;
        }
        if (validatorType == 'number' && int.tryParse(value) == null) {
          return 'Masukkan jumlah yang valid';
        }
        return null;
      },
    );
  }

  void _calculateTotalCost() {
    int subtotal = 0;

    // Hitung biaya berdasarkan jenis galon yang dipilih
    _jenisGalon.forEach((key, isSelected) {
      if (isSelected) {
        subtotal += _galonPrices[key] ?? 0;
      }
    });

    // Hitung biaya berdasarkan jumlah pesanan
    int jumlah = int.tryParse(_jumlahController.text) ?? 0;
    _totalCost = subtotal * jumlah;

    // Tambahkan PPN 10% (misal)
    _totalCost = (_totalCost * 1.1).round();

    // Jika ada diskon (misal untuk jumlah tertentu)
    if (_totalCost > 100000) {
      _totalCost = (_totalCost - 10000); // Diskon Rp 10.000
    }

    setState(() {});
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2021),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _tanggalDikirim)
      setState(() {
        _tanggalDikirim = picked;
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _jamDikirim)
      setState(() {
        _jamDikirim = picked;
      });
  }

  Widget _buildModernDateTimeSection() {
    return Column(
      children: [
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: primaryColor),
                SizedBox(width: 12),
                Text(
                  _tanggalDikirim != null
                      ? _tanggalDikirim!.toLocal().toString().split(' ')[0]
                      : 'Pilih tanggal',
                  style: TextStyle(
                    color:
                        _tanggalDikirim != null ? Colors.black87 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12),
        InkWell(
          onTap: () => _selectTime(context),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: primaryColor),
                SizedBox(width: 12),
                Text(
                  _jamDikirim != null
                      ? _jamDikirim!.format(context)
                      : 'Pilih waktu',
                  style: TextStyle(
                    color: _jamDikirim != null ? Colors.black87 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernRadioList() {
    return Column(
      children: _pembayaranOptions.map((option) {
        return RadioListTile<String>(
          title: Text(option),
          value: option,
          groupValue: _metodePembayaran,
          onChanged: (value) {
            setState(() {
              _metodePembayaran = value!;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildModernCheckboxList() {
    return Column(
      children: _jenisGalon.keys.map((String key) {
        return Container(
          margin: EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: _jenisGalon[key]!
                ? primaryColor.withOpacity(0.1)
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            title: Text(
              key,
              style: TextStyle(
                color: _jenisGalon[key]! ? textColor : Colors.black87,
                fontWeight:
                    _jenisGalon[key]! ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              'Rp ${_galonPrices[key]}', // Menampilkan harga galon
              style: TextStyle(color: primaryColor),
            ),
            leading: Checkbox(
              value: _jenisGalon[key],
              onChanged: (bool? value) {
                setState(() {
                  _jenisGalon[key] = value!;
                  _calculateTotalCost(); // Pastikan untuk menghitung total biaya setelah pilihan berubah
                });
              },
              activeColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModernPriceSummary() {
    int totalGalon = int.tryParse(_jumlahController.text) ?? 0;
    int galonPrice = totalGalon * (_galonPrices.entries.first.value);

    // Hitung PPN 10%
    int ppn = (galonPrice * 10 ~/ 100);

    // Total biaya setelah PPN
    int totalAfterPPN = galonPrice + ppn;

    // Jika total biaya lebih dari 100.000, beri diskon 10%
    int discount = 0;
    if (totalAfterPPN > 100000) {
      discount = (totalAfterPPN * 10 ~/ 100); // Diskon 10%
    }

    // Total biaya setelah diskon
    int totalCost = totalAfterPPN - discount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Total Harga: Rp$galonPrice',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Text(
          'PPN (10%): Rp$ppn',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        // Jika ada diskon, tampilkan
        if (discount > 0)
          Text(
            'Diskon 10%: -Rp$discount',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500, color: Colors.green),
          ),
        Divider(),
        Text(
          'Total Biaya: Rp$totalCost',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitOrder,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Text(
        'Kirim Pesanan',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  void _submitOrder() {
    if (_formKey.currentState!.validate()) {
      // Ambil data dari form
      String nama = _namaController.text;
      String jumlah = _jumlahController.text;
      String metodePembayaran = _metodePembayaran;
      DateTime? tanggalDikirim = _tanggalDikirim;
      TimeOfDay? jamDikirim = _jamDikirim;

      // Membuat ringkasan pesanan untuk diproses
      String summary = '''
      Nama Pemesanan: $nama
      Jumlah: $jumlah
      Metode Pembayaran: $metodePembayaran
      Tanggal Pengiriman: ${tanggalDikirim?.toLocal().toString().split(' ')[0] ?? 'Tidak dipilih'}
      Waktu Pengiriman: ${jamDikirim?.format(context) ?? 'Tidak dipilih'}
    ''';

      // Konfirmasi pesanan
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Pesanan Dikirim'),
            content: Text('Pesanan Anda berhasil dikirim!\n\n$summary'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Menutup dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );

      // Opsional: Reset form setelah mengirim pesanan
      _formKey.currentState!.reset();
      setState(() {
        _totalCost = 0;
        _jenisGalon = {
          'afkir': false,
          'Le kampung': false,
          'jantan': false,
          'broiler': false,
        };
        _metodePembayaran = 'Tunai'; // Reset metode pembayaran
        _tanggalDikirim = null;
        _jamDikirim = null;
      });
    }
  }
}
