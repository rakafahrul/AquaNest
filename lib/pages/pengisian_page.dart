// // import 'package:aquanest/services/logging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:mqtt_client/mqtt_server_client.dart';
// // import 'package:intl/intl.dart';
// import '../widgets/navbar.dart';
// import 'package:mqtt_client/mqtt_client.dart';

// class PengisianPage extends StatefulWidget {
//   const PengisianPage({super.key});

//   @override
//   State<PengisianPage> createState() => _PengisianPage();
// }

// class _PengisianPage extends State<PengisianPage> {
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   late MqttServerClient client;
//   double waterLevel = 0.0; // Menggambarkan ketinggian air
//   bool isFilling = false; // Menandakan apakah pengisian sedang berlangsung

//   @override
//   void initState() {
//     super.initState();
//     _initializeNotifications();
//     _connectToMqtt();
//   }

//   void _initializeNotifications() async {
//     const AndroidInitializationSettings androidSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     const InitializationSettings initSettings =
//         InitializationSettings(android: androidSettings);
//     await flutterLocalNotificationsPlugin.initialize(initSettings);
//   }

//   Future<void> _showNotification(String message) async {
//     const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       'aqua_channel',
//       'Aqua Notifications',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//     const NotificationDetails platformDetails =
//         NotificationDetails(android: androidDetails);
//     await flutterLocalNotificationsPlugin.show(
//       0,
//       'AquaNest',
//       message,
//       platformDetails,
//     );
//   }

//   Future<void> _connectToMqtt() async {
//     client = MqttServerClient.withPort('broker.emqx.io', 'flutter_client', 1883);
//     client.logging(on: false);
//     client.keepAlivePeriod = 20;
//     client.onDisconnected = () {
//       print('MQTT Disconnected');
//     };

//     final connMessage = MqttConnectMessage()
//         .withClientIdentifier('flutter_client')
//         .startClean();
//     client.connectionMessage = connMessage;

//     try {
//       await client.connect();
//       print('MQTT Connected');
//     } catch (e) {
//       print('MQTT Error: $e');
//       client.disconnect();
//     }
//   }

//   void _startFilling() {
//     setState(() {
//       isFilling = true;
//       waterLevel = 0.0; // Misalnya, kita set ketinggian air kosong
//     });

//     // Simulasi pengisian
//     Future.delayed(const Duration(seconds: 5), () {
//       setState(() {
//         waterLevel = 100.0; // Setelah pengisian selesai, ketinggian air menjadi penuh
//         isFilling = false;
//       });
//       _showNotification('Pengisian selesai');
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Pengisian'),
//         backgroundColor: Colors.black,
//       ),
//       body: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.black, Colors.blueAccent, Colors.greenAccent],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const Text(
//               'Pengisian Air',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//                 fontFamily: 'Neon',
//               ),
//             ),
//             const SizedBox(height: 20),
//             Icon(Icons.water, size: 60, color: Colors.blue),
//             Text(
//               "Ketinggian Air: ${waterLevel.toStringAsFixed(1)}%",
//               style: const TextStyle(
//                 fontSize: 36,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//                 fontFamily: 'Neon',
//               ),
//             ),
//             Slider(
//               value: waterLevel,
//               min: 0,
//               max: 100,
//               divisions: 100,
//               onChanged: null,
//               activeColor: Colors.greenAccent,
//               inactiveColor: Colors.grey,
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton.icon(
//               onPressed: isFilling ? null : _startFilling,
//               icon: const Icon(Icons.invert_colors, color: Colors.white),
//               label: Text(
//                 isFilling ? 'Mengisi...' : 'Mulai Mengisi',
//                 style: const TextStyle(color: Colors.white),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: isFilling ? Colors.red : Colors.blue,
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: const Navbar(selectedIndex: 2),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../widgets/navbar.dart';

class PengisianPage extends StatefulWidget {
  const PengisianPage({super.key});

  @override
  State<PengisianPage> createState() => _PengisianPageState();
}

class _PengisianPageState extends State<PengisianPage> {
  late MqttServerClient client;
  String waterLevel = 'Loading...';
  bool isFilling = false;

  @override
  void initState() {
    super.initState();
    _connectToMQTT();
  }

  Future<void> _connectToMQTT() async {
    client = MqttServerClient('broker.hivemq.com', '');
    client.port = 1883;
    client.keepAlivePeriod = 20;
    client.logging(on: false);
    client.onConnected = _onConnected;
    client.onDisconnected = _onDisconnected;

    try {
      await client.connect();
    } catch (e) {
      debugPrint('MQTT Error: $e');
      client.disconnect();
    }
  }

  void _onConnected() {
    debugPrint('Connected to MQTT (Pengisian)');
    client.subscribe('aquanest/level', MqttQos.atMostOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final recMess = c[0].payload as MqttPublishMessage;
      final message =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      setState(() {
        waterLevel = '$message cm';
      });

      final double level = double.tryParse(message) ?? 0;
      if (isFilling && level > 40) {
        _stopFilling();
      }
    });
  }

  void _onDisconnected() {
    debugPrint('Disconnected from MQTT (Pengisian)');
  }

  void _startFilling() {
    final builder = MqttClientPayloadBuilder();
    builder.addString('ON');
    client.publishMessage('aquanest/pump/fill', MqttQos.atMostOnce, builder.payload!);
    setState(() {
      isFilling = true;
    });
  }

  void _stopFilling() {
    final builder = MqttClientPayloadBuilder();
    builder.addString('OFF');
    client.publishMessage('aquanest/pump/fill', MqttQos.atMostOnce, builder.payload!);
    setState(() {
      isFilling = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengisian selesai.')),
    );
  }

  @override
  void dispose() {
    client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengisian Air')),
      bottomNavigationBar: const Navbar(selectedIndex: 2),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.water_drop_outlined, size: 100, color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                'Ketinggian Air:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                waterLevel,
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: isFilling ? null : _startFilling,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFilling ? Colors.red : Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: Text(
                  isFilling ? 'Sedang Mengisi...' : 'Mulai Pengisian',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}
