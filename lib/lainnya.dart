import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';


class lainnyaScreen extends StatefulWidget {
  @override
  _lainnyaScreenState createState() => _lainnyaScreenState();
}

class _lainnyaScreenState extends State<lainnyaScreen> {
  final _messageController1 = TextEditingController();
  final _messageController2 = TextEditingController();
  bool _isSending = false;

  final Color primaryAqua = Color(0xFF1C6B6F);
  final Color lightAqua = Color(0xFF1C6B6F);
  final Color darkAqua = Color(0xFF1C6B6F);
  final Color paleAqua = Color(0xFF1C6B6F);

  @override
  void dispose() {
    _messageController1.dispose();
    _messageController2.dispose();
    super.dispose();
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  void _showDeveloperInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('About Developer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Developer 1
              Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/REZA.jpg'),
                  ),
                  SizedBox(height: 8),
                  Text('Fahreza Riana Attarik', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('15-2022-238', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('fahreza.riana@mhs.itenas.ac.id'),
                ],
              ),
              SizedBox(height: 16),
              // Developer 2
              Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/RAFLI.jpg'),
                  ),
                  SizedBox(height: 8),
                  Text('Rafli Nugraha', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('15-2022-254', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Email: rafli.nugraha@mhs.itenas.ac.id'),
                ],
              ),
              SizedBox(height: 16),
              Text('Version: 1.0.0'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }


  void _openYoutube() async {
      const url = 'https://youtu.be/8M6xbEAWsCM';
      try {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open YouTube: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

  Future<void> _sendMessage() async {
    if (_messageController1.text.isEmpty || _messageController2.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in both message fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final messageData = {
        'message1': _messageController1.text,
        'message2': _messageController2.text,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('https://api-ticketconcert.vercel.app/update_realtime'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(messageData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Messages sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        _messageController1.clear();
        _messageController2.clear();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to send messages');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: paleAqua,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Icon(Icons.arrow_back_ios, color: darkAqua),
        actions: [
          Icon(Icons.settings_outlined, color: darkAqua, size: 24),
          SizedBox(width: 16),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [paleAqua, Colors.white],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Column(
                        children: [
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/icon.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Profile',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: darkAqua,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildMessageInput(_messageController1, 'First Message'),
                          SizedBox(height: 16),
                          _buildMessageInput(_messageController2, 'Second Message'),
                          SizedBox(height: 16),
                          _buildSendButton(),
                        ],
                      ),
                    ),

                    // Tambahkan kode berikut setelah _buildSendButton() dan sebelum tombol logout:

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: _showDeveloperInfo,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryAqua,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.info_outline, size: 20, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'About Developer',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _openYoutube,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.play_circle_outline, size: 20, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Open YouTube',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: ElevatedButton(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(TextEditingController controller, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryAqua.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: 3,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(20),
          labelText: label,
          labelStyle: TextStyle(
            color: darkAqua.withOpacity(0.7),
            fontSize: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primaryAqua, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSending ? null : _sendMessage,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAqua,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: _isSending
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send, size: 20, color: Colors.white), // Ikon putih
                  SizedBox(width: 8),
                  Text(
                    'Send Messages',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white, // Teks putih
                    ),
                  ),
                ],
              ),
      ),
    );
  }

}