import 'package:flutter/material.dart';

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const CustomBottomBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF333333),
      selectedItemColor: const Color(0xFFA9986E),    // ← 진한 색상
      unselectedItemColor: const Color(0xFFBEB08B),  // ← 기본 색상
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