import 'package:flutter/material.dart';
import 'package:tugas_akhir/login.dart';

class StartPages extends StatefulWidget {
  const StartPages({super.key});

  @override
  State<StartPages> createState() => _StartPagesState();
}

class _StartPagesState extends State<StartPages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gambar sebagai background
          Positioned.fill(
            child: Image.asset(
              'assets/banner.jpg',
              fit: BoxFit.cover,
            ),
          ),
          
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.40,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 215, 153, 161).withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          'Welcome to LippyPay !!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 12,),
                        Text(
                          '-----',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      foregroundColor: const Color.fromARGB(255, 255, 239, 241),
                      backgroundColor: const Color.fromARGB(255, 215, 153, 161),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: const Text('Start'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
