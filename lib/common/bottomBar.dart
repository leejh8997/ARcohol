import 'package:flutter/material.dart';

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const CustomBottomBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.white54,
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: '판매'),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'AR제조'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: '레시피'),
        BottomNavigationBarItem(icon: Icon(Icons.local_bar), label: '마이바'),
      ],
    );
  }
}