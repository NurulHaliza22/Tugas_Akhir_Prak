import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_akhir/welcome_page.dart';
import 'home_page.dart';


class LandingPages extends StatefulWidget {
  const LandingPages({super.key});

  @override
  State<LandingPages> createState() => _LandingPagesState();
}

class _LandingPagesState extends State<LandingPages> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Cek status login
  _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // Navigasi otomatis setelah 1 detik
    Future.delayed(const Duration(seconds: 1), () {
      if (isLoggedIn) {
        // Jika sudah login, arahkan ke HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        // Jika belum login, arahkan ke LoginPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StartPages()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 252, 252),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/lippyPay.png',
              width: 250,
              height: 250,
            ),
          ],
        ),
      ),
    );
  }
}
