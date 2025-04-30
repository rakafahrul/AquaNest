import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

  if (kIsWeb){
    await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyCPtIw3P_uKbuV4RspL2CN8k5en_1s9ruk",
          authDomain: "sample-firebase-ai-app-af792.firebaseapp.com",
          projectId: "sample-firebase-ai-app-af792",
          storageBucket: "sample-firebase-ai-app-af792.appspot.com",
          messagingSenderId: "944546339089",
          appId: "1:944546339089:web:c41bf4f1652673f245d4b0",
      ),
    );
  }else{
    await Firebase.initializeApp(); 
  }
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
