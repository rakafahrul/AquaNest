import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:aquanest/widgets/navbar.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  double ntuValue = 0.0;
  late MqttServerClient client;

  @override
  void initState() {
    super.initState();

    _initializeNotifications();
    _connectToMqtt();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<void> _showNotification(String message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'aqua_channel',
          'Aqua Notifications',
          importance: Importance.max,
          priority: Priority.high,
        );
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      'AquaNest',
      message,
      platformDetails,
    );
  }

  Future<void> _connectToMqtt() async {
    client = MqttServerClient.withPort(
      'broker.emqx.io',
      'flutter_client',
      1883,
    );
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.onDisconnected = () {
      debugPrint('MQTT Disconnected'); // Use debugPrint instead of print
    };

    final connMessage =
        MqttConnectMessage()
            .withClientIdentifier('flutter_client')
            .startClean();
    client.connectionMessage = connMessage;

    try {
      await client.connect();
      debugPrint('MQTT Connected'); // Use debugPrint instead of print

      client.subscribe('aquanest/ntu', MqttQos.atMostOnce);

      client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? event) {
        final recMess = event![0].payload as MqttPublishMessage;
        final message = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );

        final parsedValue = double.tryParse(message);
        if (parsedValue != null) {
          setState(() {
            ntuValue = parsedValue;
          });
        }
      });
    } catch (e) {
      debugPrint('MQTT Error: $e'); // Use debugPrint instead of print
      client.disconnect();
    }
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

    _showNotification('Data kekeruhan berhasil disimpan!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.white,
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
            left: 0,
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
            left: 0,
            right: 0,
            bottom: 1,
            child: Image.asset(
              'assets/images/dashboard/background2.png',
              fit: BoxFit.cover,
              height: 200,
            ),
          ),

          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Kekeruhan Air',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Neon',
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
                      backgroundColor: Color(0xFF054B95)
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
