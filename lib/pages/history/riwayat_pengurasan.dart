
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RiwayatPengurasanPage extends StatefulWidget {
  const RiwayatPengurasanPage({super.key});

  @override
  State<RiwayatPengurasanPage> createState() => _RiwayatPengurasanPageState();
}

class _RiwayatPengurasanPageState extends State<RiwayatPengurasanPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  // Mendapatkan referensi koleksi drain_history
  CollectionReference get _drainHistoryCollection => 
      _firestore.collection('drain_history');

  // Mendapatkan stream data riwayat pengurasan
  Stream<QuerySnapshot> _getDrainHistoryStream() {
    return _drainHistoryCollection
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Menambahkan riwayat pengurasan manual
  Future<void> _addManualDrainHistory(DateTime selectedDateTime) async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      await _drainHistoryCollection.add({
        'timestamp': Timestamp.fromDate(selectedDateTime),
        'userId': _auth.currentUser?.uid,
        'isAutomatic': false,
        'manual_entry': true,
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Riwayat pengurasan berhasil ditambahkan'),
            backgroundColor: Color(0xFF054B95),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan riwayat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String formatTanggal(DateTime date) {
    // Definisikan nama hari dalam Bahasa Indonesia
    final List<String> hariIndonesia = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final List<String> bulanIndonesia = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    
    // Ambil hari (1-7, dimana 1 adalah Senin)
    final int dayIndex = date.weekday - 1;
    final String hari = hariIndonesia[dayIndex];
    
    // Format tanggal manual
    final String tanggal = date.day.toString();
    final String bulan = bulanIndonesia[date.month - 1];
    final String tahun = date.year.toString();
    
    return '$hari, $tanggal $bulan $tahun';
  }

  String formatJam(DateTime date) {
    final String jam = date.hour.toString().padLeft(2, '0');
    final String menit = date.minute.toString().padLeft(2, '0');
    return '$jam:$menit';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Riwayat Pengurasan Air',
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
            // Background images
            Positioned(
              right: 0,
              bottom: 0,
              child: Image.asset(
                'assets/images/dashboard/background1.png',
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              child: Image.asset(
                'assets/images/dashboard/coral.png',
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 20,
              child: Image.asset(
                'assets/images/dashboard/ikan.png',
                height: 100,
                fit: BoxFit.contain,
              ),
            ),

            // Data Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : StreamBuilder<QuerySnapshot>(
                      stream: _getDrainHistoryStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text(
                              'Belum ada riwayat pengurasan.',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: Color(0xFF054B95),
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: snapshot.data!.docs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final doc = snapshot.data!.docs[index];
                            final data = doc.data() as Map<String, dynamic>;
                            
                            // Handle timestamp
                            DateTime timestamp;
                            if (data['timestamp'] is Timestamp) {
                              timestamp = (data['timestamp'] as Timestamp).toDate();
                            } else {
                              // Fallback jika timestamp tidak ada
                              timestamp = DateTime.now();
                            }

                            return Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF054B95),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      formatTanggal(timestamp),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      formatJam(timestamp),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF054B95),
        onPressed: () {
          _showAddManualDialog(context);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddManualDialog(BuildContext context) {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF054B95),
              ),
            ),
            child: child!,
          );
        },
      );
      if (picked != null) {
        selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          selectedTime.hour,
          selectedTime.minute,
        );
      }
    }

    Future<void> _selectTime(BuildContext context) async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF054B95),
              ),
            ),
            child: child!,
          );
        },
      );
      if (picked != null) {
        selectedTime = picked;
        selectedDate = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Tambah Riwayat Pengurasan',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF054B95),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      'Tanggal: ${DateFormat('dd MMMM yyyy').format(selectedDate)}',
                      style: const TextStyle(fontFamily: 'Poppins'),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      await _selectDate(context);
                      setState(() {});
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Waktu: ${selectedTime.format(context)}',
                      style: const TextStyle(fontFamily: 'Poppins'),
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      await _selectTime(context);
                      setState(() {});
                    },
                  ),
                ],
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
                    _addManualDrainHistory(selectedDate);
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
}