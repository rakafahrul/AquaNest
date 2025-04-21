
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class BlynkService {
  final String authToken = '???????????????'; // nanti kalo udah ada auth tokennya Ganti
  final String baseUrl = 'https://blynk.cloud/external/api/';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger(); 

  Future<String> getDataFromBlynk(String pin) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get/$authToken/$pin'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String value = data[0].toString();
        await saveDataToFirestore(pin, value);
        return value;
      } else {
        throw Exception('Failed to load data from Blynk');
      }
    } catch (e) {
      _logger.e('Error fetching data from Blynk: $e');
      throw Exception('Error fetching data from Blynk: $e');
    }
  }

  Future<void> sendDataToBlynk(String pin, String value) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/update/$authToken/$pin?value=$value'));

      if (response.statusCode != 200) {
        throw Exception('Failed to send data to Blynk');
      }
    } catch (e) {
      _logger.e('Error sending data to Blynk: $e'); 
      throw Exception('Error sending data to Blynk: $e');
    }
  }

  Future<void> setDataToBlynk(String pin, String value) async {
    await sendDataToBlynk(pin, value);
  }

  Future<void> saveDataToFirestore(String pin, String value) async {
    try {
      await _firestore.collection('water_quality_history').add({
        'pin': pin,
        'value': value,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': FirebaseAuth.instance.currentUser?.uid,
      });
    } catch (e) {
      _logger.e('Error saving data to Firestore: $e'); 
    }
  }
}





























