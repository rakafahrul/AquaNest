// import 'package:flutter/material.dart';

// class RiwayatPengurasanPage extends StatelessWidget {
//   const RiwayatPengurasanPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Riwayat Pengurasan Air'),
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
//       )
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RiwayatPengurasanPage extends StatelessWidget {
  const RiwayatPengurasanPage({super.key});

  String formatTanggal(DateTime date) {
    final hari = DateFormat('EEEE', 'id_ID').format(date);
    final tanggalLengkap = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(date);
    return '$hari, $tanggalLengkap';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pengurasan Air')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('drain_history')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada riwayat pengurasan.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final data = snapshot.data!.docs[index];
              final timestamp = (data['timestamp'] as Timestamp).toDate();

              return ListTile(
                leading: const Icon(Icons.water),
                title: const Text('Pengurasan dilakukan'),
                subtitle: Text(formatTanggal(timestamp)),
              );
            },
          );
        },
      ),
    );
  }
}
