import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../routes/app_routes.dart';
import '../../widgets/navbar.dart';
import '../../services/logging.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Ubah referensi dari 'threshold' menjadi 'thresholds'
  final DatabaseReference _thresholdRef = FirebaseDatabase.instance.ref('threshold');
  final DatabaseReference _controlRef = FirebaseDatabase.instance.ref('controls');
  
  String _userEmail = '';
  bool _isLoading = true;
  bool _isDraining = false; // Status pengurasan
  
  // Threshold values
  double _maxTurbidity = 100.0;
  double _maxWaterLevel = 5.0;
  double _minWaterLevel = 20.0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _createDefaultThresholdIfNeeded();
    // _loadThresholdValues();
    _listenToDrainingStatus();
  }


  // Fungsi untuk membuat data threshold default jika belum ada
  Future<void> _createDefaultThresholdIfNeeded() async {
    try {
      final snapshot = await _thresholdRef.get();
      if (!snapshot.exists) {
        await _thresholdRef.set({
          'max_turbidity': 70.0,
          'max_water_level': 80.0,
          'min_water_level': 20.0,
        });
        LogHelper.logInfo('Created default threshold values');
      }
      
      // Setelah memastikan data ada, load nilai threshold
      _loadThresholdValues();
    } catch (e) {
      LogHelper.logError('Error checking/creating threshold values: $e');
      
      // Tampilkan pesan error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat data threshold: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
      // Gunakan nilai default
      setState(() {
        _maxTurbidity = 70.0;
        _maxWaterLevel = 80.0;
        _minWaterLevel = 20.0;
      });
    }
  }
  

  // Mendengarkan status pengurasan
  void _listenToDrainingStatus() {
    _controlRef.child('status_siklus').onValue.listen((event) {
      final status = event.snapshot.value?.toString() ?? 'idle';
      setState(() {
        _isDraining = status == 'running';
      });
    });
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        setState(() {
          _userEmail = user.email ?? 'admin@aquanest.com';
        });
      }
    } catch (e) {
      LogHelper.logError('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadThresholdValues() async {
    try {
      LogHelper.logInfo('Loading threshold values...');
      final snapshot = await _thresholdRef.get();
      
      if (snapshot.exists) {
        final data = snapshot.value;
        LogHelper.logInfo('Threshold data loaded: $data');
        
        if (data is Map) {
          setState(() {
            _maxTurbidity = double.parse((data['max_turbidity'] ?? 70.0).toString());
            _maxWaterLevel = double.parse((data['max_water_level'] ?? 80.0).toString());
            _minWaterLevel = double.parse((data['min_water_level'] ?? 20.0).toString());
          });
        } else {
          throw Exception('Data threshold tidak valid: $data');
        }
      } else {
        LogHelper.logWarning('No threshold data found, using defaults');
        setState(() {
          _maxTurbidity = 70.0;
          _maxWaterLevel = 80.0;
          _minWaterLevel = 20.0;
        });
      }
    } catch (e) {
      LogHelper.logError('Error loading threshold values: $e');
      
      // Gunakan nilai default
      setState(() {
        _maxTurbidity = 70.0;
        _maxWaterLevel = 80.0;
        _minWaterLevel = 20.0;
      });
      
      // Tampilkan pesan error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat nilai threshold: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _saveThresholdValues() async {
    try {
      await _thresholdRef.update({
        'max_turbidity': _maxTurbidity,
        'max_water_level': _maxWaterLevel,
        'min_water_level': _minWaterLevel,
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengaturan threshold berhasil disimpan'),
            backgroundColor: Color(0xFF054B95),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan pengaturan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Fungsi untuk menangani proses logout
  Future<void> _handleLogout() async {
    // Cek apakah pengurasan sedang aktif
    if (_isDraining) {
      // Tampilkan peringatan jika pengurasan sedang aktif
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              'Tidak Dapat Logout',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            content: const Text(
              'Pompa anda masih aktif!',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF054B95),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Mengerti',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return;
    }

    // Jika pengurasan tidak aktif, tampilkan konfirmasi logout
    final confirmLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Konfirmasi Logout',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Color(0xFF054B95),
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari aplikasi?',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF054B95),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Ya, Logout',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    // Proses logout jika dikonfirmasi
    if (confirmLogout == true) {
      try {
        await FirebaseAuth.instance.signOut();
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
      } catch (e) {
        LogHelper.logError('Error during logout: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal logout: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showThresholdSettingsDialog() {
    double tempMaxTurbidity = _maxTurbidity;
    double tempMaxWaterLevel = _maxWaterLevel;
    double tempMinWaterLevel = _minWaterLevel;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Pengaturan Threshold',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF054B95),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Kekeruhan Maksimum (NTU)',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Slider(
                      value: tempMaxTurbidity,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      activeColor: const Color(0xFF054B95),
                      label: tempMaxTurbidity.round().toString(),
                      onChanged: (value) {
                        setState(() {
                          tempMaxTurbidity = value;
                        });
                      },
                    ),
                    Text(
                      '${tempMaxTurbidity.toStringAsFixed(1)} NTU',
                      style: const TextStyle(fontFamily: 'Poppins'),
                    ),
                    const SizedBox(height: 20),
                    
                    const Text(
                      'Level Air Maksimum (cm)',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Slider(
                      value: tempMaxWaterLevel,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      activeColor: const Color(0xFF054B95),
                      label: tempMaxWaterLevel.round().toString(),
                      onChanged: (value) {
                        setState(() {
                          tempMaxWaterLevel = value;
                        });
                      },
                    ),
                    Text(
                      '${tempMaxWaterLevel.toStringAsFixed(1)} cm',
                      style: const TextStyle(fontFamily: 'Poppins'),
                    ),
                    const SizedBox(height: 20),
                    
                    const Text(
                      'Level Air Minimum (cm)',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Slider(
                      value: tempMinWaterLevel,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      activeColor: const Color(0xFF054B95),
                      label: tempMinWaterLevel.round().toString(),
                      onChanged: (value) {
                        setState(() {
                          tempMinWaterLevel = value;
                        });
                      },
                    ),
                    Text(
                      '${tempMinWaterLevel.toStringAsFixed(1)} cm',
                      style: const TextStyle(fontFamily: 'Poppins'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF054B95),
                  ),
                  onPressed: () {
                    setState(() {
                      _maxTurbidity = tempMaxTurbidity;
                      _maxWaterLevel = tempMaxWaterLevel;
                      _minWaterLevel = tempMinWaterLevel;
                    });
                    _saveThresholdValues();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Simpan',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF054B95),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFA7E9FF), Color(0xFF7CBBF1)],
          ),
        ),
        child: Stack(
          children: [
            // Background elements
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/login/background_splashscreen1.png',
                fit: BoxFit.cover,
              ),
            ),
            
            // Fish elements
            Positioned(
              bottom: 100,
              left: 20,
              child: Image.asset(
                'assets/images/pengurasan/ikan.png',
                height: 40,
              ),
            ),
            
            Positioned(
              bottom: 150,
              right: 30,
              child: Image.asset(
                'assets/images/pengurasan/ikan.png',
                height: 30,
              ),
            ),
            
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  
                  // Profile avatar with ripple effect
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF054B95), width: 1),
                        ),
                      ),
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF054B95), width: 1),
                        ),
                      ),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF054B95), width: 1),
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Email
                  Text(
                    _userEmail,
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      color: Color(0xFF054B95),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Logout button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ElevatedButton(
                      onPressed: _handleLogout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isDraining 
                            ? Colors.grey // Disabled color
                            : const Color(0xFF054B95),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "LogOut",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Threshold Settings Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ElevatedButton(
                      onPressed: _showThresholdSettingsDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF054B95),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Pengaturan Threshold",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  // Warning message if draining is active
                  if (_isDraining)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning, color: Colors.red),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Proses pengurasan sedang aktif. Anda tidak dapat logout saat ini.',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Navbar(selectedIndex: 3),
    );
  }
}
