import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../widgets/navbar.dart';
import 'package:firebase_database/firebase_database.dart';


class PengurasanPage extends StatefulWidget {
  const PengurasanPage({super.key});

  @override
  State<PengurasanPage> createState() => _PengurasanPageState();
}

class _PengurasanPageState extends State<PengurasanPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  bool isDraining = false;
  double waterLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _setupListeners();
    // _connectToMQTT();
  }

  void _setupListeners() {
    // Listen ke level air
    _dbRef.child('sensors/water_level').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          waterLevel = double.parse(data.toString());
        });
        
        // Otomatis matikan pompa jika level di bawah 10cm
        if (isDraining && waterLevel < 10) {
          _stopDraining();
        }
      }
    });
    // Listen ke status pompa
    _dbRef.child('controls/pompa_pengisian').onValue.listen((event) {
      final data = event.snapshot.value as bool?;
      setState(() {
        isDraining = data ?? false;
      });
    });
  }

  void _startDraining() {
    _dbRef.child('controls/pompa_pengisian').set(true);
  }

  void _stopDraining() {
    _dbRef.child('controls/pompa_pengisian').set(false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengurasan selesai.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "Pengurasan",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF054B95),
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      bottomNavigationBar: const Navbar(selectedIndex: 1),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFA7E9FF), Color(0xFFDCF5FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          //background pertama
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Image.asset(
                'assets/images/login/background_splashscreen1.png',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),

          //background kedua
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              'assets/images/background_splashscreen2.png',
              height: 210, // ubah tinggi sesuai keinginan, misal 200 atau 250
              fit: BoxFit.contain,
            ),
          ),

          //ikan
          Positioned(
            left: 54,
            bottom: 142,
            child: Image.asset(
              'assets/images/pengurasan/ikan.png',
              height: 88,
              // fit: BoxFit.contain,
            ),
          ),

          //coral
          Positioned(
            bottom: -10,
            right: 0,
            child: Image.asset(
              'assets/images/dashboard/coral.png',
              fit: BoxFit.contain,
            ),
          ),

           //rumput laut
          Positioned(
            left: 0,
            right: 260,
            bottom: 0,
            child: Image.asset(
              'assets/images/rumput_splashscreen.png',
              fit: BoxFit.contain,
              // height: 200,
            ),
          ),

          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Jarak ketinggihan Air',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF054B95),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 250,
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    decoration: BoxDecoration(
                      color: Color(0xFF054B95),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.bar_chart,
                          size: 40,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${waterLevel.toStringAsFixed(1)} cm',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isDraining ? null : _startDraining,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF054B95),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // <-- Radius di sini
                        ),
                      ),
                      child: Text(
                        isDraining ? 'Sedang Menguras...' : 'Mulai Pengurasan',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
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