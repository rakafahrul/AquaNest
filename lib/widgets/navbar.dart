import 'package:flutter/material.dart';
import 'package:aquanest/pages/dashboard_page.dart';
import 'package:aquanest/pages/history_page.dart';
// import 'package:aquanest/pages/pengisian_page.dart';
import 'package:aquanest/pages/pengurasan_page.dart';
import 'package:aquanest/pages/profile_page.dart';

class Navbar extends StatefulWidget {
  final int selectedIndex;

  const Navbar({super.key, required this.selectedIndex});
  @override
  State<Navbar> createState() => _Navbar();
}

class _Navbar extends State<Navbar> {
  void _onItemTapped(int index) {
    if (index == widget.selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PengurasanPage()),
        );
        break;
      // case 2:
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(builder: (_) => const PengisianPage()),
      //   );
      //   break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HistoryPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      // bottom: 50,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(5, 78, 149, 0.5).withOpacity(0.4),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: widget.selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: const Color.fromARGB(255, 247, 248, 249),
            unselectedItemColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Image.asset('assets/images/navbar/Home.png',width: 45,height: 45,color: Colors.white,),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Image.asset('assets/images/navbar/pengurasan.png',width: 45,height: 45, color: Colors.white,),
                label: 'Pengurasan',
              ),
              // BottomNavigationBarItem(
              //   icon: Image.asset('assets/images/navbar/pengurasan.png',width: 45,height: 45,),
              //    label: 'Pengisian'
              // ),
              BottomNavigationBarItem(               
                icon: Image.asset('assets/images/navbar/riwayat.png',width: 45,height: 45, color: Colors.white,),
                 label: 'Riwayat'
              ),
              BottomNavigationBarItem(
                icon: Image.asset('assets/images/navbar/profile.png',width: 45,height: 45,color: Colors.white,),
                 label: 'Profile'
              ),
            ],
          ),
        ),
      ),
    );
  }
}
