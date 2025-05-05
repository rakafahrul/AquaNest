// import 'package:flutter/material.dart';
// import '../widgets/navbar.dart'; // Navbar

// class ProfilePage extends StatelessWidget {
//   const ProfilePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profil Saya'),
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
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const CircleAvatar(
//               radius: 50,
//               backgroundImage: AssetImage('assets/images/profile.png'), // Ganti sesuai gambar
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Nama Pengguna',
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
//             ),
//             const Text(
//               'email@example.com',
//               style: TextStyle(fontSize: 16, color: Colors.white70),
//             ),
//             const SizedBox(height: 30),
//             ListTile(
//               leading: const Icon(Icons.edit, color: Colors.white),
//               title: const Text('Edit Profil', style: TextStyle(color: Colors.white)),
//               onTap: () {
//                 // Arahkan ke halaman edit profil jika ada
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.lock, color: Colors.white),
//               title: const Text('Ganti Password', style: TextStyle(color: Colors.white)),
//               onTap: () {
//                 // Arahkan ke halaman ganti password jika ada
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.logout, color: Colors.white),
//               title: const Text('Keluar', style: TextStyle(color: Colors.white)),
//               onTap: () {
//                 // Logika logout, misalnya: hapus token, arahkan ke login page
//                 Navigator.pushReplacementNamed(context, '/login');
//               },
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: const Navbar(selectedIndex: 4),
//     );
//   }
// }


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import 'package:aquanest/widgets/navbar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Tidak diketahui';

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Foto profil
              CircleAvatar(
                radius: 60,
                backgroundImage: const AssetImage('assets/images/profile.png'),
                backgroundColor: Colors.blue[100],
              ),
              const SizedBox(height: 20),

              // Email pengguna
              Text(
                email,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Tombol Logout
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ],
          ),
        )
      ),
      bottomNavigationBar: const Navbar(selectedIndex: 3),

    );
  }
}
