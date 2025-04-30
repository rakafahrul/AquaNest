import 'package:flutter/material.dart';
import 'package:aquanest/pages/dashboard_page.dart';
import 'package:aquanest/pages/history_page.dart';
import 'package:aquanest/pages/pengisian_page.dart';
import 'package:aquanest/pages/pengurasan_page.dart';
import 'package:aquanest/pages/profile_page.dart';

class Navbar extends StatefulWidget {
  final int selectedIndex;

  const Navbar({super.key, required this.selectedIndex});
  @override
  State<Navbar>createState() => _Navbar();
}


class _Navbar extends State<Navbar> {
  void _onItemTapped(int index) {
    if (index == widget.selectedIndex) return;

    switch(index){
      case 0:
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardPage()));
      break;
      case 1:
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PengurasanPage()));
      break;
      case 2:
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PengisianPage()));
      break;
      case 3:
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HistoryPage()));
      break;
      case 4:
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: Colors.teal[700],
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'), 
        BottomNavigationBarItem(icon: Icon(Icons.water_drop), label: 'Pengurasan'), 
        BottomNavigationBarItem(icon: Icon(Icons.water), label: 'Pengisian'), 
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'), 
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'), 
      ],
    );
  }

}
