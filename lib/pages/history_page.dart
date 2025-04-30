

// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';

// // class HistoryPage extends StatefulWidget {
// //   const HistoryPage({super.key});

// //   @override
// //   State<HistoryPage> createState() => _HistoryPageState();
// // }

// // class _HistoryPageState extends State<HistoryPage> {
// //   DateTime? _selectedDate;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text("Riwayat Kekeruhan Air"),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.calendar_today),
// //             onPressed: _pickDate,
// //           )
// //         ],
// //       ),
// //       body: StreamBuilder<QuerySnapshot>(
// //         stream: _getFilteredStream(),
// //         builder: (context, snapshot) {
// //           if (snapshot.connectionState == ConnectionState.waiting) {
// //             return const Center(child: CircularProgressIndicator());
// //           }

// //           if (snapshot.hasError) {
// //             return Center(child: Text('Error: ${snapshot.error}'));
// //           }

// //           final documents = snapshot.data?.docs ?? [];

// //           if (documents.isEmpty) {
// //             return const Center(child: Text('Tidak ada data untuk tanggal ini.'));
// //           }

// //           return ListView.separated(
// //             padding: const EdgeInsets.all(16),
// //             itemCount: documents.length,
// //             separatorBuilder: (_, __) => const Divider(),
// //             itemBuilder: (context, index) {
// //               final data = documents[index];
// //               final value = data['value'];
// //               final timestamp = (data['timestamp'] as Timestamp).toDate();
// //               final formattedDate = DateFormat("dd/MM/yyyy HH:mm").format(timestamp);

// //               return Card(
// //                 elevation: 2,
// //                 child: ListTile(
// //                   leading: const Icon(Icons.water_drop),
// //                   title: Text("Kekeruhan: $value NTU"),
// //                   subtitle: Text("Waktu: $formattedDate"),
// //                 ),
// //               );
// //             },
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   Stream<QuerySnapshot> _getFilteredStream() {
// //     final collection = FirebaseFirestore.instance
// //         .collection('water_quality_history')
// //         .where('pin', isEqualTo: 'v0');

// //     if (_selectedDate != null) {
// //       final start = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
// //       final end = start.add(const Duration(days: 1));
// //       return collection
// //           .where('timestamp', isGreaterThanOrEqualTo: start)
// //           .where('timestamp', isLessThan: end)
// //           .orderBy('timestamp', descending: true)
// //           .snapshots();
// //     }

// //     return collection.orderBy('timestamp', descending: true).snapshots();
// //   }

// //   void _pickDate() async {
// //     final picked = await showDatePicker(
// //       context: context,
// //       initialDate: _selectedDate ?? DateTime.now(),
// //       firstDate: DateTime(2024),
// //       lastDate: DateTime.now(),
// //     );

// //     if (picked != null) {
// //       setState(() {
// //         _selectedDate = picked;
// //       });
// //     }
// //   }
// // }



// =========================================================================================================
// import 'package:flutter/material.dart';
// import 'riwayat_kekeruhan.dart'; // Halaman riwayat kekeruhan
// import 'riwayat_pengurasan.dart'; // Halaman riwayat pengurasan
// import '../widgets/navbar.dart'; // Navbar kita

// class HistoryPage extends StatelessWidget {
//   const HistoryPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Riwayat'),
//         backgroundColor: Colors.black,
//       ),
//       body: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.black, Colors.blueAccent, Colors.greenAccent],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Tombol untuk Riwayat Kekeruhan
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const RiwayatKekeruhanPage()),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blueAccent, // Mengganti 'primary' dengan 'backgroundColor'
//               ),
//               child: const Text('Riwayat Kekeruhan', style: TextStyle(fontSize: 18)),
//             ),
//             const SizedBox(height: 20),
//             // Tombol untuk Riwayat Pengurasan
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const RiwayatPengurasanPage()),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.greenAccent, // Mengganti 'primary' dengan 'backgroundColor'
//               ),
//               child: const Text('Riwayat Pengurasan', style: TextStyle(fontSize: 18)),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: const Navbar(selectedIndex: 3),
//     );
//   }
// }

// pages/history_page.dart
// import 'package:aquanest/pages/Riwayat_kekeruhan.dart';
import 'package:aquanest/pages/riwayat_pengurasan.dart';
import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import 'package:aquanest/pages/riwayat_kekeruhan.dart';
// import 'package:aquanest/pages/pengurasan_page.dart';
// import 'riwayat_kekeruhan.dart';
// import 'riwayat_pengurasan.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat')), 
      bottomNavigationBar: const Navbar(selectedIndex: 3),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RiwayatKekeruhanPage()),
                  );
                },
                child: const Text('Riwayat Kekeruhan Air'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RiwayatPengurasanPage()),
                  );
                },
                child: const Text('Riwayat Pengurasan Air'),
              ),
            ],
          ),
        )
      ),
    );
  }
}
