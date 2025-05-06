import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase sesuai platform
  await Firebase.initializeApp(
    options: kIsWeb
        ? const FirebaseOptions(
            apiKey: "AIzaSyCPtIw3P_uKbuV4RspL2CN8k5en_1s9ruk",
            authDomain: "aquanest-ad54e.firebaseapp.com",
            projectId: "aquanest-ad54e",
            messagingSenderId: "552773995749",
            appId: "1:552773995749:web:f47202e8e9f857db55580c",
            databaseURL: "https://aquanest-ad54e-default-rtdb.asia-southeast1.firebasedatabase.app/",
          )
        : null, // Untuk Android/iOS gunakan konfigurasi default dari file google-services.json / GoogleService-Info.plist
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AquaNest',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      initialRoute: AppRoutes.splash, // Splash sebagai halaman awal
      routes: AppRoutes.routes, // Semua rute didefinisikan di sini
    );
  }
}