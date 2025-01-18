import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Model Provinsi
class Province {
  final String id;
  final String name;

  Province({required this.id, required this.name});

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: json['id'],
      name: json['name'],
    );
  }
}

// Model Kota
class City {
  final String id;
  final String provinceId;
  final String name;

  City({required this.id, required this.provinceId, required this.name});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      provinceId: json['province_id'],
      name: json['name'],
    );
  }
}

// Model Konser
class Concert {
  String? id;
  String title;
  String city;
  String province;
  String description;
  String location;
  String date;
  String time;
  String image;
  int price;
  int remainingTickets;
  Map<String, double> coordinates;

  Concert({
    this.id,
    required this.title,
    required this.city,
    required this.province,
    required this.description,
    required this.location,
    required this.date,
    required this.time,
    required this.image,
    required this.price,
    required this.remainingTickets,
    required this.coordinates,
  });

  factory Concert.fromJson(Map<String, dynamic> json) {
    return Concert(
      id: json['_id'],
      title: json['title'],
      city: json['city'],
      province: json['province'],
      description: json['description'],
      location: json['location'],
      date: json['date'],
      time: json['time'],
      image: json['image'],
      price: json['price'],
      remainingTickets: json['remaining_tickets'],
      coordinates: {
        'latitude': json['coordinates']['latitude'].toDouble(),
        'longitude': json['coordinates']['longitude'].toDouble(),
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'city': city,
      'province': province,
      'description': description,
      'location': location,
      'date': date,
      'time': time,
      'image': image,
      'price': price,
      'remaining_tickets': remainingTickets,
      'coordinates': {
        'latitude': coordinates['latitude'],
        'longitude': coordinates['longitude'],
      },
    };
  }
}

class ConcertListScreen extends StatefulWidget {
  @override
  _ConcertListScreenState createState() => _ConcertListScreenState();
}

class _ConcertListScreenState extends State<ConcertListScreen> {
  List<Concert> concerts = [];
  List<Province> provinces = [];
  List<City> cities = [];
  Province? selectedProvince;
  City? selectedCity;
  final String apiUrl = 'https://api-ticketconcert.vercel.app/api/concerts';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchConcerts();
    fetchProvinces();
  }

  Future<void> fetchProvinces() async {
    try {
      final response = await http.get(
        Uri.parse('https://www.emsifa.com/api-wilayah-indonesia/api/provinces.json'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          provinces = data.map((json) => Province.fromJson(json)).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error mengambil data provinsi: $e')),
      );
    }
  }

  Future<void> fetchCities(String provinceId) async {
    if (provinceId.isEmpty) return;
    setState(() {
      isLoading = true;
      cities = [];
    });

    final String url = 'https://www.emsifa.com/api-wilayah-indonesia/api/regencies/$provinceId.json';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          cities = data.map((json) => City.fromJson(json)).toList();
          selectedCity = null;
        });
      } else {
        throw Exception('Gagal mendapatkan data kota. Status: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error mengambil data kota: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchConcerts() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          concerts = data.map((json) => Concert.fromJson(json)).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error mengambil data konser: $e')),
      );
    }
    setState(() => isLoading = false);
  }

  Future<void> addConcert(Concert concert) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(concert.toJson()),
      );

      if (response.statusCode == 201) {
        fetchConcerts();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Konser berhasil ditambahkan')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error menambahkan konser: $e')),
      );
    }
  }

  Future<void> updateConcert(String id, Concert concert) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(concert.toJson()),
      );

      if (response.statusCode == 200) {
        fetchConcerts();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Konser berhasil diperbarui')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error memperbarui konser: $e')),
      );
    }
  }

  Future<void> deleteConcert(String id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));

      if (response.statusCode == 200) {
        fetchConcerts();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Konser berhasil dihapus')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error menghapus konser: $e')),
      );
    }
  }

  void _showMapPicker(BuildContext context, TextEditingController latController, TextEditingController longController) async {
    LatLng initialPosition = LatLng(-6.200000, 106.816666);
    LatLng? selectedPosition;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Pilih Lokasi di Peta'),
              ),
              body: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initialPosition,
                  zoom: 10,
                ),
                markers: selectedPosition != null
                    ? {
                        Marker(
                          markerId: MarkerId('selected_location'),
                          position: selectedPosition!,
                          infoWindow: InfoWindow(title: 'Lokasi Terpilih'),
                        ),
                      }
                    : {},
                onTap: (LatLng position) {
                  setState(() {
                    selectedPosition = position;
                    latController.text = position.latitude.toString();
                    longController.text = position.longitude.toString();
                  });
                },
              ),
              floatingActionButton: FloatingActionButton(
                child: Icon(Icons.check),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            );
          },
        );
      },
    );
  }

void _showAddEditConcertDialog([Concert? concert]) {
    final titleController = TextEditingController(text: concert?.title ?? '');
    final descriptionController = TextEditingController(text: concert?.description ?? '');
    final locationController = TextEditingController(text: concert?.location ?? '');
    final priceController = TextEditingController(text: concert?.price.toString() ?? '');
    final ticketsController = TextEditingController(text: concert?.remainingTickets.toString() ?? '');
    final latController = TextEditingController(text: concert?.coordinates['latitude'].toString() ?? '');
    final longController = TextEditingController(text: concert?.coordinates['longitude'].toString() ?? '');

    String? base64Image;

    if (concert != null) {
      selectedProvince = provinces.firstWhere(
        (p) => p.name == concert.province,
        orElse: () => provinces.first,
      );
      fetchCities(selectedProvince!.id).then((_) {
        setState(() {
          selectedCity = cities.firstWhere(
            (c) => c.name == concert.city,
            orElse: () => cities.first,
          );
        });
      });
    }

    DateTime? selectedDate = concert?.date.isNotEmpty == true
        ? DateTime.tryParse(concert!.date)
        : null;
    TimeOfDay? selectedTime = concert?.time.isNotEmpty == true
        ? TimeOfDay(
            hour: int.parse(concert!.time.split(':')[0]),
            minute: int.parse(concert.time.split(':')[1]),
          )
        : null;

    File? selectedImage;
    final ImagePicker picker = ImagePicker();

    Future<void> pickImage() async {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Compress image quality to 70%
      );
      if (image != null) {
        // Read the file
        List<int> imageBytes = await image.readAsBytes();
        // Convert to base64
        base64Image = 'data:image/jpeg;base64,${base64Encode(imageBytes)}';
        // Set selected image for preview
        selectedImage = File(image.path);
        setState(() {});
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(concert == null ? 'Tambah Konser Baru' : 'Edit Konser'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Judul'),
                ),
                SizedBox(height: 16),
                DropdownButton<Province>(
                  value: selectedProvince,
                  hint: Text('Pilih Provinsi'),
                  items: provinces.map((province) {
                    return DropdownMenuItem<Province>(
                      value: province,
                      child: Text(province.name),
                    );
                  }).toList(),
                  onChanged: (newProvince) {
                    setState(() {
                      selectedProvince = newProvince;
                      if (newProvince != null) {
                        fetchCities(newProvince.id);
                      }
                    });
                  },
                ),
                SizedBox(height: 16),
                DropdownButton<City>(
                  value: selectedCity,
                  hint: isLoading ? Text('Memuat data kota...') : Text('Pilih Kota'),
                  items: cities.map((city) {
                    return DropdownMenuItem<City>(
                      value: city,
                      child: Text(city.name),
                    );
                  }).toList(),
                  onChanged: (newCity) {
                    setState(() {
                      selectedCity = newCity;
                    });
                  },
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Deskripsi'),
                  maxLines: 3,
                ),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(labelText: 'Lokasi'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                        child: Text(selectedDate != null
                            ? 'Tanggal: ${selectedDate!.toLocal().toString().split(' ')[0]}'
                            : 'Pilih Tanggal'),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: selectedTime ?? TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              selectedTime = pickedTime;
                            });
                          }
                        },
                        child: Text(selectedTime != null
                            ? 'Waktu: ${selectedTime!.format(context)}'
                            : 'Pilih Waktu'),
                      ),
                    ),
                  ],
                ),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Harga'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: ticketsController,
                  decoration: InputDecoration(labelText: 'Sisa Tiket'),
                  keyboardType: TextInputType.number,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: latController,
                        decoration: InputDecoration(labelText: 'Latitude'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: longController,
                        decoration: InputDecoration(labelText: 'Longitude'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.map),
                      onPressed: () => _showMapPicker(context, latController, longController),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text('Gambar:'),
                GestureDetector(
                  onTap: () => pickImage(),
                  child: Container(
                    height: 100,
                    width: 100,
                    color: Colors.grey[200],
                    child: selectedImage != null
                        ? Image.file(selectedImage!, fit: BoxFit.cover)
                        : concert?.image != null && concert!.image.isNotEmpty
                            ? Image.network(concert.image, fit: BoxFit.cover)
                            : Icon(Icons.camera_alt),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedProvince == null || selectedCity == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Silakan pilih provinsi dan kota')),
                  );
                  return;
                }

                if (titleController.text.isEmpty ||
                    descriptionController.text.isEmpty ||
                    locationController.text.isEmpty ||
                    priceController.text.isEmpty ||
                    ticketsController.text.isEmpty ||
                    selectedDate == null ||
                    selectedTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Semua field harus diisi')),
                  );
                  return;
                }

                final newConcert = Concert(
                  title: titleController.text,
                  city: selectedCity!.name,
                  province: selectedProvince!.name,
                  description: descriptionController.text,
                  location: locationController.text,
                  date: selectedDate!.toIso8601String().split('T')[0],
                  time: '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                  image: base64Image ?? concert?.image ?? '',
                  price: int.parse(priceController.text),
                  remainingTickets: int.parse(ticketsController.text),
                  coordinates: {
                    'latitude': double.parse(latController.text),
                    'longitude': double.parse(longController.text),
                  },
                );

                if (concert != null) {
                  updateConcert(concert.id!, newConcert);
                } else {
                  addConcert(newConcert);
                }

                Navigator.pop(context);
              },
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Konser'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddEditConcertDialog(),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: concerts.length,
              itemBuilder: (context, index) {
                final concert = concerts[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        concert.image,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.error),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              concert.title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(concert.description),
                            SizedBox(height: 8),
                            Text(
                              'Lokasi: ${concert.city}, ${concert.province}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Harga: Rp ${concert.price.toString()}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Sisa Tiket: ${concert.remainingTickets}',
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => _showAddEditConcertDialog(concert),
                                  child: Text('Edit'),
                                ),
                                TextButton(
                                  onPressed: () => deleteConcert(concert.id!),
                                  child: Text(
                                    'Hapus',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}