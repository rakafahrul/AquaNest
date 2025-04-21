import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Riwayat Kekeruhan Air", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            onPressed: _pickDate,
            tooltip: "Pilih Tanggal",
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blueGrey, Colors.teal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _getFilteredStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
            }

            final documents = snapshot.data?.docs ?? [];

            if (documents.isEmpty) {
              return const Center(
                child: Text(
                  'Tidak ada data untuk tanggal ini.',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
              itemCount: documents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final data = documents[index];
                final value = data['value'];
                final timestamp = (data['timestamp'] as Timestamp).toDate();
                final formattedDate = DateFormat("dd/MM/yyyy • HH:mm").format(timestamp);

                return Card(
                  color: Colors.white10,
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: const Icon(Icons.opacity, color: Colors.cyanAccent),
                    title: Text(
                      "Kekeruhan: $value NTU",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Waktu: $formattedDate",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getFilteredStream() {
    final collection = FirebaseFirestore.instance
        .collection('water_quality_history')
        .where('pin', isEqualTo: 'v0');

    if (_selectedDate != null) {
      final start = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
      final end = start.add(const Duration(days: 1));
      return collection
          .where('timestamp', isGreaterThanOrEqualTo: start)
          .where('timestamp', isLessThan: end)
          .orderBy('timestamp', descending: true)
          .snapshots();
    }

    return collection.orderBy('timestamp', descending: true).snapshots();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.cyan,
              onPrimary: Colors.black,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.blueGrey[900],
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}























































































































// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class HistoryPage extends StatefulWidget {
//   const HistoryPage({super.key});

//   @override
//   State<HistoryPage> createState() => _HistoryPageState();
// }

// class _HistoryPageState extends State<HistoryPage> {
//   DateTime? _selectedDate;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Riwayat Kekeruhan Air"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.calendar_today),
//             onPressed: _pickDate,
//           )
//         ],
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _getFilteredStream(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           final documents = snapshot.data?.docs ?? [];

//           if (documents.isEmpty) {
//             return const Center(child: Text('Tidak ada data untuk tanggal ini.'));
//           }

//           return ListView.separated(
//             padding: const EdgeInsets.all(16),
//             itemCount: documents.length,
//             separatorBuilder: (_, __) => const Divider(),
//             itemBuilder: (context, index) {
//               final data = documents[index];
//               final value = data['value'];
//               final timestamp = (data['timestamp'] as Timestamp).toDate();
//               final formattedDate = DateFormat("dd/MM/yyyy HH:mm").format(timestamp);

//               return Card(
//                 elevation: 2,
//                 child: ListTile(
//                   leading: const Icon(Icons.water_drop),
//                   title: Text("Kekeruhan: $value NTU"),
//                   subtitle: Text("Waktu: $formattedDate"),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Stream<QuerySnapshot> _getFilteredStream() {
//     final collection = FirebaseFirestore.instance
//         .collection('water_quality_history')
//         .where('pin', isEqualTo: 'v0');

//     if (_selectedDate != null) {
//       final start = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
//       final end = start.add(const Duration(days: 1));
//       return collection
//           .where('timestamp', isGreaterThanOrEqualTo: start)
//           .where('timestamp', isLessThan: end)
//           .orderBy('timestamp', descending: true)
//           .snapshots();
//     }

//     return collection.orderBy('timestamp', descending: true).snapshots();
//   }

//   void _pickDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now(),
//       firstDate: DateTime(2024),
//       lastDate: DateTime.now(),
//     );

//     if (picked != null) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }
// }
