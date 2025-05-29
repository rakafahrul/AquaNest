import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // await Firebase.initializeApp();

  await Firebase.initializeApp(
    options: kIsWeb 
      ? const FirebaseOptions(
          apiKey: "AIzaSyBGytCVvan_AqhKVil9Le3oKw5S-hYwEH4",
          authDomain: "aquanest-ad54e.firebaseapp.com",
          projectId: "aquanest-ad54e",
          messagingSenderId: "552773995749",
          appId: "1:552773995749:web:f47202e8e9f857db55580c", 
          storageBucket: "aquanest-ad54e.appspot.com",
          databaseURL: "https://aquanest-ad54e-default-rtdb.asia-southeast1.firebasedatabase.app/",
        )
      : null, // Untuk mobile akan menggunakan file konfigurasi default
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
      // Tambahkan konfigurasi localization berikut
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'), // Locale Indonesia
        Locale('en', 'US'), // Locale English sebagai fallback
      ],
      initialRoute: AppRoutes.splash, // Splash sebagai halaman awal
      routes: AppRoutes.routes, // Semua rute didefinisikan di sini
    );
  }
}