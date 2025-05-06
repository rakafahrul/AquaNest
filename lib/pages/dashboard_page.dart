import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:mqtt_client/mqtt_client.dart';
// import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:aquanest/widgets/navbar.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
// import 'package:aquanest/widgets/turbidity_gauge.dart';


class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DatabaseReference _sensorRef = FirebaseDatabase.instance.ref('sensors');

  double ntuValue = 0.0;

  @override
  void initState() {
    super.initState();
    _setupFirebaseListener();

  }

  void _setupFirebaseListener() {
    _sensorRef.child('turbidity').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          ntuValue = (data as num).toDouble(); // Lebih aman dari parse string
          // ntuValue = double.parse(data.toString());
        });
      }
    });
  }

  void _saveToFirestore() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, dd MMMM yyyy - HH:mm');
    final formattedDate = formatter.format(now);

    FirebaseFirestore.instance.collection('riwayat_kekeruhan').add({
      'waktu': formattedDate,
      'ntu': ntuValue.toStringAsFixed(1),
      'timestamp': FieldValue.serverTimestamp(),
    });
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
      ),
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

          // background pertama
          Positioned(
            right: 0,
            bottom: 50,
            child: Image.asset(
              'assets/images/dashboard/background1.png',
              fit: BoxFit.cover,
              height: 200,
            ),
          ),

          //background kedua
          Positioned(
            right: 0,
            bottom: -40,
            child: Image.asset(
              'assets/images/dashboard/background2.png',
              fit: BoxFit.cover,
              height: 200,
            ),
          ),

          //rumput laut
          Positioned(
            left: 0,
            right: 260,
            bottom: 50,
            child: Image.asset(
              'assets/images/dashboard/rumput_laut.png',
              height: 200,
            ),
          ),

          //coral
          Positioned(
            bottom: 0,
            child: Image.asset(
              'assets/images/dashboard/coral.png',
              fit: BoxFit.contain,
            ),
          ),

          //ikan
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
              padding: const EdgeInsets.all(56),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                  const SizedBox(height: 20),
                  // Gauge ditambahkan di sini
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

                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _saveToFirestore,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      "Cetak Kekeruhan Air",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF054B95),
                      minimumSize: const Size(500, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)

                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const Navbar(selectedIndex: 0), // Corrected here
    );
  }
}