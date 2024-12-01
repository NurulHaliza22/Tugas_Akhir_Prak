import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_akhir/edit_profile.dart';
import 'package:tugas_akhir/riwayat_transaksi.dart';
import 'package:tugas_akhir/welcome_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = '';
  String username = '';
  String email = '';
  String phone = '';
  String imageUrl = 'https://example.com/profile.jpg'; // Default Image URL

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    Box userBox = await Hive.openBox('userBox');
    String? storedUsername = userBox.get('username');
    String? storedEmail = userBox.get('email');
    String? storedPhone = userBox.get('phone');
    String? storedName = userBox.get('name');

    setState(() {
      username = storedUsername ?? 'Username not set';
      email = storedEmail ?? 'Email not set';
      phone = storedPhone ?? 'Phone not set';
      name = storedName ?? 'Name not set';
    });
  }

  void updateProfile(String updatedName, String updatedUsername, String updatedEmail, String updatedPhone, String updatedImageUrl) {
    setState(() {
      name = updatedName;
      username = updatedUsername;
      email = updatedEmail;
      phone = updatedPhone;
      imageUrl = updatedImageUrl;
    });

    Hive.openBox('userBox').then((box) {
      box.put('name', updatedName);
      box.put('username', updatedUsername);
      box.put('email', updatedEmail);
      box.put('phone', updatedPhone);
      box.put('imageUrl', updatedImageUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF5F5F5),
        foregroundColor: Colors.black,
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('isLoggedIn');
              await prefs.remove('username');

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const StartPages()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Foto Profil dan Nama
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(imageUrl),
                      backgroundColor: Colors.grey[300],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@$username',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 1.5),
              const SizedBox(height: 16),

              // Informasi Akun
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileInfo('Email', email),
                  const SizedBox(height: 10),
                  _buildProfileInfo('Phone Number', phone),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(thickness: 1.5),
              const SizedBox(height: 20),

              // Tombol Aksi
              Column(
                children: [
                  _buildActionButton(
                    context,
                    'Edit Profile',
                    Icons.edit,
                    const Color.fromARGB(255, 215, 153, 161),
                    () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(
                            name: name,
                            username: username,
                            email: email,
                            phone: phone,
                            imageUrl: imageUrl,
                          ),
                        ),
                      );
                      if (result != null) {
                        updateProfile(
                          result['name'],
                          result['username'],
                          result['email'],
                          result['phone'],
                          result['imageUrl'],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    context,
                    'Transaction History',
                    Icons.history,
                    const Color.fromARGB(255, 215, 153, 161),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TransactionHistoryPage()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Row(
      children: [
        Text(
          '$label:',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onPressed: onPressed,
    );
  }
}
