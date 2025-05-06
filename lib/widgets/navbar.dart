import 'package:flutter/material.dart';
import 'package:aquanest/pages/dashboard_page.dart';
import 'package:aquanest/pages/history/history_page.dart';
import 'package:aquanest/pages/pengurasan_page.dart';
import 'package:aquanest/pages/profile/profile_page.dart';

class Navbar extends StatefulWidget {
  final int selectedIndex;

  const Navbar({super.key, required this.selectedIndex});
  @override
  State<Navbar> createState() => _Navbar();
}

class _Navbar extends State<Navbar> {
  void _onItemTapped(int index) {
    if (index == widget.selectedIndex) return;

    Widget destination;
    switch (index) {
      case 0:
        destination = const DashboardPage();
        break;
      case 1:
        destination = const PengurasanPage();
        break;
      case 2:
        destination = const HistoryPage();
        break;
      case 3:
        destination = const ProfilePage();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = 0.0;
          const end = 1.0;
          const curve = Curves.easeInOut;

          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return FadeTransition(
            opacity: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(5, 78, 149, 0.5).withOpacity(0.4),
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
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
            selectedItemColor: const Color(0xFF054B95),
            unselectedItemColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/images/navbar/Home.png',
                  width: 45,
                  height: 45,
                  color: widget.selectedIndex == 0 ? const Color(0xFF054B95) : Colors.white,
                ),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/images/navbar/pengurasan.png',
                  width: 45,
                  height: 45,
                  color: widget.selectedIndex == 1 ? const Color(0xFF054B95) : Colors.white,
                ),
                label: 'Pengurasan',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/images/navbar/riwayat.png',
                  width: 45,
                  height: 45,
                  color: widget.selectedIndex == 2 ? const Color(0xFF054B95) : Colors.white,
                ),
                label: 'Riwayat',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/images/navbar/profile.png',
                  width: 45,
                  height: 45,
                  color: widget.selectedIndex == 3 ? const Color(0xFF054B95) : Colors.white,
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
