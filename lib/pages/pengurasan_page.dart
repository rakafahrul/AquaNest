import 'package:flutter/material.dart';
// import 'package:mqtt_client/mqtt_client.dart';
// import 'package:mqtt_client/mqtt_server_client.dart';
import '../widgets/navbar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';


class PengurasanPage extends StatefulWidget {
  const PengurasanPage({super.key});

  @override
  State<PengurasanPage> createState() => _PengurasanPageState();
}

class _PengurasanPageState extends State<PengurasanPage> {
  final DatabaseReference _controlRef = FirebaseDatabase.instance.ref('controls');
  final DatabaseReference _sensorRef = FirebaseDatabase.instance.ref('sensors');

  bool _isLoading = true;
  bool _isDraining = false;
  String controlSource = 'app';  // Default kontrol dari aplikasi
  double waterLevel = 100.0; // Asumsi awal air pada ketinggian 100 cm


   @override
  void initState() {
    super.initState();
    _listenToFirebase();
    status_siklus();
    
  }

  void status_siklus() {
    _controlRef.child('status_siklus').onValue.listen((event) {
      final status = event.snapshot.value?.toString() ?? 'idle';
      setState(() {
        _isDraining = status == 'running';
      });
    });
  }

  // Menghubungkan dengan Firebase dan mendengarkan perubahan data
  void _listenToFirebase() {
    _sensorRef.child('jarak').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          waterLevel = double.tryParse(data.toString()) ?? 100.0;
        });
      }
    });

    _controlRef.child('control_source').onValue.listen((event) {
      setState(() {
        controlSource = (event.snapshot.value ?? 'app').toString();
      });
    });
  }
  
  // Fungsi untuk mencatat riwayat pengurasan
  Future<void> _recordDrainHistory() async {
    try {
      await FirebaseFirestore.instance.collection('drain_history').add({
        'timestamp': FieldValue.serverTimestamp(),
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'waterLevel': waterLevel, // Jika ada variabel waterLevel
        'isAutomatic': true,
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Riwayat pengurasan berhasil dicatat')),
        );
      }
    } catch (e) {
      print('Error recording drain history: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mencatat riwayat pengurasan: $e')),
        );
      }
    }
  }

  // Fungsi untuk memulai siklus pengurasan
  Future<void> _startDraining() async {
    setState(() {
      _isLoading = true;
    });

    try {

      // Update status pengurasan ke 'running' terlebih dahulu
      await _controlRef.update({
        'status_siklus': 'running',
      });
      
      // Kemudian aktifkan pompa pengurasan
      await _controlRef.update({
        'pompa_pengurasan': true, 
        'pompa_pengisian': false,  
      });
      
      // Update sumber kontrol
      await _controlRef.update({
        'control_source': 'device',
      });
      
      // await _controlRef.update({
      //   'pompa_pengurasan': true, 
      //   'pompa_pengisian': false,  
      //   'status_siklus': 'running',
      // });

      
      // await _controlRef.update({
      //   'control_source': 'device',
      // });

      setState(() {
        _isLoading = false;
        _isDraining = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Siklus pengurasan dimulai')),
      );

      // Catat riwayat pengurasan
      await _recordDrainHistory();

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memulai pengurasan: $e')),
      );
    }
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
                        onPressed: _isDraining ? null : _startDraining,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isDraining ? Colors.red : const Color(0xFF054B95),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                       child: Text(
                          _isDraining ? 'Sedang Berjalan' : 'Mulai Pengurasan',
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