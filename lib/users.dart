import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class User {
  final String id;
  final String name;
  final String username;
  final String email;
  final String? profileImage;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id']?.toString() ?? '', // Konversi ObjectId ke String
      name: json['name'] ?? 'Unknown',
      username: json['username'] ?? 'Unknown',
      email: json['email'] ?? 'No email',
      profileImage: json['profileImage'], // Bisa null
    );
  }
}


class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final String apiUrl = 'https://api-ticketconcert.vercel.app/users';
  List<User> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          users = data.map((json) => User.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        showErrorSnackBar('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      showErrorSnackBar('Error: $e');
    }
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(leading: CircleAvatar(
                      backgroundImage: user.profileImage != null
                          ? NetworkImage(user.profileImage!)
                          : AssetImage('assets/avatar.jpg') as ImageProvider, // Gunakan gambar avatar default
                      onBackgroundImageError: (_, __) => Icon(Icons.error),
                    ),

                    title: Text(user.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Username: ${user.username}'),
                        Text('Email: ${user.email}'),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
