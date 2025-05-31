import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  String formatTanggal(DateTime date) {
    final List<String> hariIndonesia = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    final List<String> bulanIndonesia = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus',
      'September', 'Oktober', 'November', 'Desember'
    ];
    final int dayIndex = date.weekday - 1;
    final String hari = hariIndonesia[dayIndex];
    final String tanggal = date.day.toString();
    final String bulan = bulanIndonesia[date.month - 1];
    final String tahun = date.year.toString();
    final String jam = date.hour.toString().padLeft(2, '0');
    final String menit = date.minute.toString().padLeft(2, '0');
    return '$hari, $tanggal $bulan $tahun | $jam:$menit';
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
          'Notifikasi Kekeruhan Air',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF054B95),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFA7E9FF), Color(0xFFDCF5FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 50,
            child: Image.asset(
              'assets/images/dashboard/background1.png',
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            right: 0,
            bottom: -40,
            child: Image.asset(
              'assets/images/dashboard/background2.png',
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 0,
            right: 260,
            bottom: 50,
            child: Image.asset(
              'assets/images/dashboard/rumput_laut.png',
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0,
            child: Image.asset(
              'assets/images/dashboard/coral.png',
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 20,
            child: Image.asset(
              'assets/images/dashboard/ikan.png',
              fit: BoxFit.contain,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifikasi')
                  .orderBy('time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada notifikasi.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: snapshot.data!.docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    final String title = data['title'] ?? 'Peringatan Kekeruhan';
                    final String message = data['message'] ?? 'Kekeruhan Air Melewati Batas Aman';
                    final bool isWarning = data['isWarning'] ?? true;
                    final double ntu = (data['ntu'] as num).toDouble();
                    DateTime? waktu;
                    if (data['time'] != null) {
                      if (data['time'] is Timestamp) {
                        waktu = (data['time'] as Timestamp).toDate();
                      } else if (data['time'] is String) {
                        waktu = DateTime.tryParse(data['time']);
                      }
                    }
                    return Container(
                      decoration: BoxDecoration(
                        color: isWarning ? const Color(0xFF054B95) : Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            waktu != null ? formatTanggal(waktu) : '-',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'NTU: ${ntu.toStringAsFixed(1)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}