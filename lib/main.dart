import 'package:flutter/material.dart'; // Mengimpor paket Flutter untuk UI dan widget.
import 'dart:async'; // Mengimpor paket untuk menggunakan Timer.
import 'dashboard.dart'; // Mengimpor file untuk halaman Dashboard.
import 'lainnya.dart'; // Mengimpor file untuk halaman Lainnya.
import 'pesanan.dart';
import 'product.dart';
import 'users.dart';

void main() {
  runApp(const MyApp()); // Menjalankan aplikasi Flutter.
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Konstruktor untuk MyApp.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App', // Menentukan judul aplikasi.
      theme: ThemeData(
        primarySwatch: Colors.blue, // Menentukan warna utama aplikasi.
        visualDensity: VisualDensity.adaptivePlatformDensity, // Menyesuaikan kepadatan tampilan untuk berbagai platform.
      ),
      initialRoute: '/splash', // Menentukan halaman awal aplikasi.
      routes: {
        '/splash': (context) => SplashScreen(), // Menentukan rute untuk halaman SplashScreen.
        '/login': (context) => LoginPage(), // Menentukan rute untuk halaman Login.
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState(); // Menghasilkan status untuk SplashScreen.
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController; // Mendeklarasikan kontroler animasi.
  late Animation<double> _fadeAnimation; // Mendeklarasikan animasi fade (transparansi).
  late Animation<double> _scaleAnimation; // Mendeklarasikan animasi scale (perubahan ukuran).

  @override
  void initState() {
    super.initState();

    // Inisialisasi kontroler animasi
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    // Animasi untuk fade (opacity)
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Animasi untuk scale (perubahan ukuran)
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Memulai animasi
    _animationController.forward();

    // Setelah 5 detik, navigasi ke halaman login
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void dispose() {
    _animationController.dispose(); // Menghentikan animasi saat widget dihancurkan.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
               Color(0xFF1C6B6F),
              Color(0xFF4DC4E1)
            ], // Warna gradasi biru untuk latar belakang.
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation, // Menggunakan animasi fade.
            child: ScaleTransition(
              scale: _scaleAnimation, // Menggunakan animasi scale.
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Gambar di tengah layar dengan bentuk bulat
                  Container(
                    width: MediaQuery.of(context).size.width *
                        0.5, // Menggunakan 50% lebar layar.
                    height: MediaQuery.of(context).size.width * 0.5, // Membuat tinggi sama dengan lebar untuk gambar bulat.
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, // Bentuk gambar bulat.
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/icon.png', // Menampilkan gambar dengan path yang ditentukan.
                        fit: BoxFit.cover, // Mengatur gambar agar sesuai dengan kontainer.
                      ),
                    ),
                  ),
                  SizedBox(height: 5), // Jarak vertikal.
                  Text(
                    'Konserku', // Teks dengan nama dan nomor ID.
                    textAlign: TextAlign.center, // Teks rata tengah.
                    style: TextStyle(
                      fontSize: 65,
                      fontWeight: FontWeight.bold, // Mengatur font menjadi tebal.
                      color: Colors.white, // Mengatur warna teks menjadi putih.
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState(); // Menghasilkan status untuk LoginPage.
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController(); // Mengontrol input username.
  final TextEditingController _passwordController = TextEditingController(); // Mengontrol input password.
  bool _obscureText = true; // Menentukan apakah teks password disembunyikan.

  // Fungsi login untuk memproses login
  void _login(BuildContext context) {
    // Periksa apakah username dan password sesuai
    if (_usernameController.text == 'admin' && _passwordController.text == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(username: _usernameController.text), // Pindah ke HomePage.
        ),
      );

      // Menampilkan SnackBar untuk login berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login berhasil! Selamat datang, ${_usernameController.text}'),
        ),
      );
    } else {
      // Menampilkan SnackBar untuk login gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal login! Username atau password salah.'),
        ),
      );
    }
  }


  // Fungsi untuk toggle visibilitas password
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
               Color(0xFF1C6B6F),
              Color(0xFF4DC4E1)
            ], // Warna gradasi biru untuk latar belakang.
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('KONSERKU',style: TextStyle(fontSize: 55,fontWeight: FontWeight.bold,color: Colors.white)), // Mengatur gaya teks.
              Text('ADMIN',style: TextStyle(fontSize: 55,fontWeight: FontWeight.bold,color: Colors.white)), 
              SizedBox(height: 20), // Jarak vertikal.
              Column(
                children: [
                  _buildInputField( // Membangun input field untuk username.
                    controller: _usernameController,
                    label: 'Username',
                    icon: Icons.person,
                  ),
                  SizedBox(height: 20), // Jarak vertikal.
                  _buildInputField( // Membangun input field untuk password.
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock,
                    obscureText: _obscureText, // Menyembunyikan teks password.
                    isPassword: true,
                    onTap: _togglePasswordVisibility, // Mengaktifkan tombol toggle visibilitas password.
                  ),
                  SizedBox(height: 20), // Jarak vertikal.
                  ElevatedButton(
                    onPressed: () => _login(context), // Ketika tombol login ditekan.
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1C6B6F), // Mengatur warna tombol.
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30), // Padding tombol.
                    ),
                    child: Text(
                      'LOGIN', // Teks tombol.
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white, // Mengatur warna teks tombol.
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

  // Fungsi untuk membangun input field
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    bool isPassword = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30), // Membulatkan sudut input field.
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 3), // Efek bayangan untuk input field.
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText, // Menyembunyikan teks password jika diperlukan.
        style: TextStyle(
          color: Colors.black, // Warna teks input.
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: label, // Placeholder untuk input.
          hintStyle: TextStyle(
            color: Colors.grey[500],
          ),
          prefixIcon: Icon(
            icon,
            color:  Color(0xFF1C6B6F), // Warna ikon di input field.
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility, // Ikon untuk toggle visibilitas password.
                    color: Color(0xFF1C6B6F), // Warna ikon.
                  ),
                  onPressed: onTap,
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Padding konten input field.
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String username; // Menyimpan username pengguna.

  const HomePage({Key? key, required this.username}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState(); // Menghasilkan status untuk HomePage.
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // Mengatur index tab yang aktif.

  final List<Widget> _pages = [
    DashboardScreen(), // Halaman Dashboard.
    ConcertListScreen(),  
    PesananScreen(),
    UserListScreen(),
    lainnyaScreen(), // Halaman Profil. 
  ];

  // Fungsi untuk mengubah tab yang aktif.
  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: _pages[_currentIndex], // Menampilkan halaman berdasarkan index tab yang aktif.
    bottomNavigationBar: BottomNavigationBar(
      onTap: onTabTapped, // Menangani perubahan tab.
      currentIndex: _currentIndex, // Mengatur tab yang aktif.
      backgroundColor: Color(0xFF1C6B6F), // Warna latar belakang sesuai dengan gambar.
      selectedItemColor: Colors.white, // Warna item yang dipilih.
      unselectedItemColor: Colors.blue[200], // Warna item yang tidak dipilih.
      type: BottomNavigationBarType.fixed, // Tetapkan tipe untuk pewarnaan tetap.
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'), // Item Dashboard.
        BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Produk'), // Item Produk.
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Pesanan'), // Item Pesanan.
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'), // Item Pesanan.
        BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Lainnya'), // Item Lainnya.
      ],
    ),
  );
}
}
