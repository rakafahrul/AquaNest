import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'notification_page.dart'; // Pastikan file notification_page.dart ada
import '../widgets/navbar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DatabaseReference _sensorRef = FirebaseDatabase.instance.ref('sensors');
  final DatabaseReference _thresholdRef = FirebaseDatabase.instance.ref('threshold');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  double ntuValue = 0.0;
  double waterLevel = 0.0;
  bool _isConnected = false;
  bool hasNotifications = false;
  double maxTurbidity = 70.0;
  bool _hasSentWarning = false;
  bool _hasShownPopup = false;

  @override
  void initState() {
    super.initState();
    _setupFirebaseListener();
    _setupThresholdListener();
    _checkNotifications();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setupFirebaseListener() {
    databaseReference.child('.info/connected').onValue.listen((event) {
      final connected = event.snapshot.value as bool?;
      if (mounted) {
        setState(() {
          _isConnected = connected ?? false;
        });
      }
    });

    _sensorRef.child('turbidity').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && mounted) {
        double ntu = (data as num).toDouble();
        setState(() {
          ntuValue = ntu;
          _checkNotifications();
        });

        // Notifikasi crossing threshold + popup
        if (ntu > maxTurbidity) {
          if (!_hasSentWarning) {
            _saveNotificationToFirestore(ntu);
            _hasSentWarning = true;
          }
          if (!_hasShownPopup) {
            _showWarningPopup(ntu);
            _hasShownPopup = true;
          }
        } else {
          _hasSentWarning = false;
          _hasShownPopup = false;
        }
      }
    });

    _sensorRef.child('jarak').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && mounted) {
        setState(() {
          waterLevel = (data as num).toDouble();
        });
      }
    });
  }

  void _setupThresholdListener() {
    _thresholdRef.child('max_turbidity').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && mounted) {
        setState(() {
          maxTurbidity = double.parse(data.toString());
          _checkNotifications();
        });
      }
    });
  }

  Future<void> _checkNotifications() async {
    if (!mounted) return;
    try {
      if (ntuValue > maxTurbidity) {
        if (mounted) {
          setState(() {
            hasNotifications = true;
          });
        }
        return;
      }
      final notifDocs = await _firestore
          .collection('notifikasi')
          .orderBy('time', descending: true)
          .limit(1)
          .get();

      bool hasWarning = false;
      if (notifDocs.docs.isNotEmpty) {
        final notif = notifDocs.docs.first.data();
        final double lastNtu = (notif['ntu'] as num).toDouble();
        final bool isWarning = notif['isWarning'] ?? false;
        if (isWarning && lastNtu > maxTurbidity) {
          hasWarning = true;
        }
      }

      if (mounted) {
        setState(() {
          hasNotifications = hasWarning;
        });
      }
    } catch (e) {
      print('Error checking notifications: $e');
    }
  }

  Future<void> _saveNotificationToFirestore(double ntu) async {
    try {
      await _firestore.collection('notifikasi').add({
        'isWarning': true,
        'message': 'Kekeruhan Air Melewati Batas Aman',
        'ntu': ntu,
        'time': FieldValue.serverTimestamp(),
        'title': 'Peringatan Kekeruhan',
      });
    } catch (e) {
      print('Gagal menyimpan notifikasi: $e');
    }
  }

  void _showWarningPopup(double ntu) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "PERINGATAN Kekeruhan Air",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF054B95),
          ),
        ),
        content: Text(
          "Kekeruhan air melebihi batas aman!\n\nNTU: ${ntu.toStringAsFixed(1)}",
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK", style: TextStyle(color: Color(0xFF054B95))),
          ),
        ],
      ),
    );
  }

  Future<void> _saveToFirestore() async {
    if (!mounted) return;
    try {
      await _firestore.collection('riwayat_kekeruhan').add({
        'ntu': ntuValue,
        'water_level': waterLevel,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil disimpan')),
        );
      }
      _checkNotifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
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
        centerTitle: true,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF054B95),
          ),
        ),
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications,
                  color: Color(0xFF054B95),
                  size: 28,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationPage()),
                  ).then((_) {
                    _checkNotifications();
                  });
                },
              ),
              if (hasNotifications)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromRGBO(210, 244, 255, 1), Color.fromRGBO(5, 78, 149, 1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 50,
            child: Image.asset(
              'assets/images/dashboard/background1.png',
              fit: BoxFit.cover,
              height: 200,
            ),
          ),
          Positioned(
            right: 0,
            bottom: -40,
            child: Image.asset(
              'assets/images/dashboard/background2.png',
              fit: BoxFit.cover,
              height: 200,
            ),
          ),
          Positioned(
            left: 0,
            right: 260,
            bottom: 50,
            child: Image.asset(
              'assets/images/dashboard/rumput_laut.png',
              height: 200,
            ),
          ),
          Positioned(
            bottom: 0,
            child: Image.asset(
              'assets/images/dashboard/coral.png',
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 20,
            child: Image.asset(
              'assets/images/dashboard/ikan.png',
              fit: BoxFit.contain,
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  _buildTurbidityCard(),
                  const SizedBox(height: 10),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const Navbar(selectedIndex: 0),
    );
  }

  Widget _buildTurbidityCard() {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Kekeruhan Air',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF054B95),
              ),
            ),
            const SizedBox(height: 16),
            SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: 100,
                  ranges: <GaugeRange>[
                    GaugeRange(
                      startValue: 0,
                      endValue: 30,
                      color: Colors.green,
                    ),
                    GaugeRange(
                      startValue: 30,
                      endValue: 70,
                      color: Colors.orange,
                    ),
                    GaugeRange(
                      startValue: 70,
                      endValue: 100,
                      color: Colors.red,
                    ),
                  ],
                  pointers: <GaugePointer>[
                    NeedlePointer(value: ntuValue.clamp(0, 100)),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Text(
                        '${ntuValue.toStringAsFixed(1)} NTU',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      angle: 90,
                      positionFactor: 0.5,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: _saveToFirestore,
      icon: const Icon(Icons.save, color: Colors.white),
      label: const Text(
        "Cetak Data Kekeruhan",
        style: TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF054B95),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}