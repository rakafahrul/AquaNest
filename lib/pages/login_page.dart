import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../routes/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;
  late AnimationController _fishController;
  late AnimationController _seaweedController;
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _fishController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _seaweedController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Trigger animasi masuk
    _fishController.forward();
    _seaweedController.forward();
    _bgController.forward();
  }

  @override
  void dispose() {
    _fishController.dispose();
    _seaweedController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login gagal: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _bgController,
          builder: (context, child) {
            return Positioned(
              top: 10 * (1 - _bgController.value),
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFA7E9FF), Color(0xFFDCF5FF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            );
          },
        ),

        // background biru gelap
        AnimatedBuilder(
          animation: _seaweedController,
          builder: (context, child) {
            return Positioned(
              left: 0,
              right: 0,
              bottom: 50,
              child: Opacity(
                opacity: _seaweedController.value,
                child: Image.asset(
                  'assets/images/login/background_splashscreen1.png',
                  fit: BoxFit.cover,
                  height: 200,
                ),
              ),
            );
          },
        ),

        // Rumput laut
        AnimatedBuilder(
          animation: _seaweedController,
          builder: (context, child) {
            return Positioned(
              left: 0,
              right: 260,
              bottom: 0,
              child: Opacity(
                opacity: _seaweedController.value,
                child: Image.asset(
                  'assets/images/login/rumput_laut1.png',
                  // fit: BoxFit.contain,
                  height: 500,
                  // width: 500,
                ),
              ),
            );
          },
        ),

        //background biru muda
        AnimatedBuilder(
          animation: _seaweedController,
          builder: (context, child) {
            return Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Opacity(
                opacity: _seaweedController.value,
                child: Image.asset(
                  'assets/images/login/background_splashscreen2.png',
                  fit: BoxFit.cover,
                  height: 200,
                ),
              ),
            );
          },
        ),

        // rumput bintang
        AnimatedBuilder(
          animation: _seaweedController,
          builder: (context, child) {
            return Positioned(
              top: 700,
              left: 0,
              right: 300,
              bottom: 0,
              child: Opacity(
                opacity: _seaweedController.value,
                child: Image.asset(
                  'assets/images/login/rumput_laut2.png',
                  // fit: BoxFit.contain,
                  fit: BoxFit.contain,
                  width: 500,
                  // width: 500,
                ),
              ),
            );
          },
        ),

        // Ikan
        AnimatedBuilder(
          animation: _fishController,
          builder: (context, child) {
            return Positioned(
              // bottom: 20 + (100 * (1 - _fishController.value)),
              bottom: 50,
              right: 0,
              child: Opacity(
                opacity: _fishController.value,
                child: Image.asset(
                  'assets/images/login/ikan.png',
                  width: 150,
                  fit: BoxFit.contain,
                ),
              ),
            );
          },
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text(
              "Masuk",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF054B95),
              ),
            ),
            centerTitle: true,
            elevation: 0,
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/login/ikon_login.png',
                    width: 200,
                  ), // header gambar tangan + chat
                  const SizedBox(height: 20),
                  // const Text(
                  //   'Selamat Datang',
                  //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                  // ),
                  const SizedBox(height: 20),
                  _buildTextField('Email', emailController),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Kata Sandi',
                    passwordController,
                    isPassword: true,
                  ),
                  const SizedBox(height: 24),
                  isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Text('Masuk',
                        style: TextStyle(color: Colors.white),),
                      ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        fillColor: Color(0xFF91D3F2).withOpacity(0.4),
        filled: true,
      ),
    );
  }
}