// import 'package:flutter/material.dart';

// class RiwayatKekeruhanPage extends StatelessWidget {
//   const RiwayatKekeruhanPage ({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Riwayat Kekeruhan Air'),
//         backgroundColor: Colors.cyan,
//       ),
//       body: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//           colors: [Colors.black, Colors.blueAccent, Colors.greenAccent],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight, 
//           ),
//         ),
//         child: ListView(
//           children: [
//             Card(
//               margin: const EdgeInsets.symmetric(vertical: 5),
//               color: Colors.white.withOpacity(0.1),
//               child: ListTile(
//                 title: Text(
//                   'Tanggal: 2025-04-20 - waktu: 10.00 AM',
//                   style: const TextStyle(color: Colors.white),
//                 ),
//                 subtitle: const Text(
//                   'NTU: 15.2',
//                   style: TextStyle(color: Colors.white),
//                 )
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RiwayatKekeruhanPage extends StatelessWidget {
  const RiwayatKekeruhanPage({super.key});

  // String formatTanggal(DateTime date) {
  //   final hari = DateFormat('EEEE', 'id_ID').format(date); // Hari dalam Bahasa Indonesia
  //   final tanggalLengkap = DateFormat('d MMMM yyyy | HH:mm', 'id_ID').format(date);
  //   return '$hari, $tanggalLengkap';
  // }

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
          'Riwayat Kekeruhan Air',
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
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFA7E9FF), Color(0xFFDCF5FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Background decorations
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

          // Data Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('riwayat_kekeruhan')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada riwayat kekeruhan.',
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
                    final data = snapshot.data!.docs[index];
                    final timestamp = (data['timestamp'] as Timestamp).toDate();
                    DateTime? waktu;
                    if (data['timestamp'] != null) {
                      waktu = (data['timestamp'] as Timestamp).toDate();
                    }

                    final value = data['ntu'];

                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF054B95),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              formatTanggal(timestamp),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          Text(
                            'NTU $value',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
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
