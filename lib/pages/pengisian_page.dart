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
      // bottomNavigationBar: const Navbar(selectedIndex: 2),
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
