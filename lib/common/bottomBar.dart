import 'package:flutter/material.dart';
import '../page/home.dart';
import '../page/product.dart';
import '../page/arCamera.dart';
import '../page/recipe.dart';
import '../page/myBar.dart';
import 'myPage.dart';

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int)? onTap;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = [
      {'icon': Icons.home, 'label': '홈', 'route': '/home'},
      {'icon': Icons.shopping_cart, 'label': '판매', 'route': '/product'},
      {'icon': Icons.qr_code, 'label': 'AR제조', 'route': '/ar'},
      {'icon': Icons.book, 'label': '레시피', 'route': '/recipe'},
      {'icon': Icons.local_bar, 'label': '마이바', 'route': '/mybar'},
    ];

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF333333),
      selectedItemColor: const Color(0xFFA9986E),
      unselectedItemColor: const Color(0xFFBEB08B),
      currentIndex: currentIndex,
      onTap: (index) {
        final currentRoute = ModalRoute.of(context)?.settings.name;
        final targetRoute = navItems[index]['route'] as String;

        if (currentRoute != targetRoute) {
          _navigateWithoutAnimation(context, targetRoute);
        }

        if (onTap != null) {
          onTap!(index);
        }
      },
      items: navItems
          .map((item) => BottomNavigationBarItem(
        icon: Icon(item['icon'] as IconData),
        label: item['label'] as String,
      ))
          .toList(),
    );
  }
}

void _navigateWithoutAnimation(BuildContext context, String routeName) {
  final routeWidgets = {
    '/home': const HomePage(),
    '/product': const ProductPage(),
    '/ar': const ArPage(),
    '/recipe': const RecipePage(),
    '/mybar': const MyBarPage(),
    '/mypage': const MyPage(),
  };

  final widget = routeWidgets[routeName] ?? const HomePage();

  Navigator.of(context).pushReplacement(PageRouteBuilder(
    pageBuilder: (_, __, ___) => widget,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  ));
}
