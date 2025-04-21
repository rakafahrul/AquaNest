import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';                                                         // Tambahan untuk gauge
import '../services/blynk_service.dart';
import '../routes/app_routes.dart';
import 'history_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final BlynkService blynk = BlynkService();
  double _turbidityValue = 0.0;
  double _distanceValue = 0.0;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _startMonitoring();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);
    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<void> _showNotification(String message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'turbidity_alerts',
      'Turbidity Alerts',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Peringatan Kekeruhan',
      message,
      platformDetails,
    );
  }

  void _startMonitoring() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3));
      try {
        final turbidityStr = await blynk.getDataFromBlynk("v0");
        final distanceStr = await blynk.getDataFromBlynk("v3");

        final turbidity = double.tryParse(turbidityStr) ?? 0.0;
        final distance = double.tryParse(distanceStr) ?? 0.0;

        setState(() {
          _turbidityValue = turbidity;
          _distanceValue = distance;
        });

        FirebaseFirestore.instance.collection('water_quality_history').add({
          'pin': 'v0',
          'value': turbidity.toStringAsFixed(1),
          'timestamp': FieldValue.serverTimestamp(),
        });

        if (turbidity > 70.0) {
          _showNotification("Kekeruhan air tinggi: ${turbidity.toStringAsFixed(1)} NTU");
        }
      } catch (_) {
        // Handle silently
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Monitoring", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white,),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blueAccent, Colors.greenAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            "Kekeruhan Air",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Neon',
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildGauge(_turbidityValue),
                          const SizedBox(height: 20),
                          _buildInfoCard(
                            icon: Icons.vertical_align_bottom,
                            title: "Jarak Ketinggian Air",
                            value: "${_distanceValue.toStringAsFixed(1)} cm",
                          ),
                          const SizedBox(height: 20),
                          _buildActionButtons(),
                          const SizedBox(height: 20),
                          Card(
                            color: Colors.transparent,
                            child: ListTile(
                              leading: const Icon(Icons.history, color: Colors.white),
                              title: const Text(
                                "Riwayat Kekeruhan",
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const HistoryPage()),
                                );
                              },
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGauge(double value) {
    return SizedBox(
      height: 220,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 0,
            maximum: 100,
            ranges: <GaugeRange>[
              GaugeRange(startValue: 0, endValue: 30, color: Colors.green),
              GaugeRange(startValue: 30, endValue: 70, color: Colors.orange),
              GaugeRange(startValue: 70, endValue: 100, color: Colors.red),
            ],
            pointers: <GaugePointer>[
              NeedlePointer(value: value),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Text(
                  '${value.toStringAsFixed(1)} NTU',
                  style: const TextStyle(
                    fontSize: 20,
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
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(value, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () => blynk.setDataToBlynk("v1", "1"),
          icon: const Icon(Icons.water, color: Colors.white),
          label: const Text("Kuras Air", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            side: BorderSide.none,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => blynk.setDataToBlynk("v2", "1"),
          icon: const Icon(Icons.invert_colors, color: Colors.white),
          label: const Text("Isi Air", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            side: BorderSide.none,
          ),
        ),
      ],
    );
  }
}




