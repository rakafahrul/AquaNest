import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

  await Firebase.initializeApp(
    options: kIsWeb 
      ? const FirebaseOptions(
          apiKey: "AIzaSyCPtIw3P_uKbuV4RspL2CN8k5en_1s9ruk",
          authDomain: "aquanest-ad54e.firebaseapp.com",
          projectId: "aquanest-ad54e",
          messagingSenderId: "552773995749",
          appId: "1:552773995749:web:f47202e8e9f857db55580c", // Pastikan ini app ID untuk web
          databaseURL: "https://aquanest-ad54e-default-rtdb.asia-southeast1.firebasedatabase.app/",
        )
      : null, // Untuk mobile akan menggunakan file konfigurasi default
  );


  // if (kIsWeb){
  //   await Firebase.initializeApp(
  //     options: FirebaseOptions(
  //         apiKey: "AIzaSyCPtIw3P_uKbuV4RspL2CN8k5en_1s9ruk",
  //         authDomain: "aquanest-ad54e.firebaseapp.com",
  //         projectId: "aquanest-ad54e",
  //         // storageBucket: "sample-firebase-ai-app-af792.appspot.com",
  //         messagingSenderId: "552773995749",
  //         appId: "1:552773995749:android:f47202e8e9f857db55580c",
  //         databaseURL: "https://aquanest-ad54e-default-rtdb.asia-southeast1.firebasedatabase.app/"
  //     ),
  //   );
  // }else{
  //   await Firebase.initializeApp(); 
  // }
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
      initialRoute: AppRoutes.splash, // Splash
      routes: AppRoutes.routes,
      // initialRoute: FirebaseAuth.instance.currentUser == null
      // initialRoute: AppRoutes.splash,
      // routes: AppRoutes.login,
      // routes: AppRoutes.dashboard,
          // ? AppRoutes.login
          // : AppRoutes.dashboard,
      // routes: AppRoutes.routes,
    );
  }
}
