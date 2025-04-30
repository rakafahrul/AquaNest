import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../widgets/navbar.dart';

class PengurasanPage extends StatefulWidget {
  const PengurasanPage({super.key});

  @override
  State<PengurasanPage> createState() => _PengurasanPageState();
}

class _PengurasanPageState extends State<PengurasanPage> {
  late MqttServerClient client;
  String waterLevel = 'Loading...';
  bool isDraining = false;

  @override
  void initState() {
    super.initState();
    _connectToMQTT();
  }

  Future<void> _connectToMQTT() async {
    client = MqttServerClient('broker.hivemq.com', '');
    client.port = 1883;
    client.keepAlivePeriod = 20;
    client.onDisconnected = _onDisconnected;
    client.logging(on: false);
    client.onConnected = _onConnected;

    try {
      await client.connect();
    } catch (e) {
      debugPrint('MQTT Error: $e');
      client.disconnect();
    }
  }

  void _onConnected() {
    debugPrint('Connected to MQTT');
    client.subscribe('aquanest/level', MqttQos.atMostOnce);
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final recMess = c[0].payload as MqttPublishMessage;
      final message =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      setState(() {
        waterLevel = '$message cm';
      });

      final double level = double.tryParse(message) ?? 0;
      if (isDraining && level < 10) {
        _stopDraining();
      }
    });
  }

  void _onDisconnected() {
    debugPrint('Disconnected from MQTT');
  }

  void _startDraining() {
    final builder = MqttClientPayloadBuilder();
    builder.addString('ON');
    client.publishMessage('aquanest/pump/drain', MqttQos.atMostOnce, builder.payload!);
    setState(() {
      isDraining = true;
    });
  }

  void _stopDraining() {
    final builder = MqttClientPayloadBuilder();
    builder.addString('OFF');
    client.publishMessage('aquanest/pump/drain', MqttQos.atMostOnce, builder.payload!);
    setState(() {
      isDraining = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengurasan selesai.')),
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
      appBar: AppBar(title: const Text('Pengurasan Air')),
      bottomNavigationBar: const Navbar(selectedIndex: 1),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.water_drop, size: 100, color: Colors.teal),
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
                onPressed: isDraining ? null : _startDraining,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDraining ? Colors.red : Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: Text(
                  isDraining ? 'Sedang Menguras...' : 'Mulai Menguras',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
}