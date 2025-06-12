import 'package:flutter/material.dart';
import '../page/home.dart';
import '../page/myBar.dart';
import '../page/recipe.dart';
import '../page/arCamera.dart';
import '../page/product.dart';
import 'myPage.dart';
import 'myRecipe.dart';
import 'buyProduct.dart';
import 'wishList.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const CustomAppBar({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF1F1F1F),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Color(0xFFBEB08B)),
        onPressed: () => scaffoldKey.currentState?.openDrawer(),
      ),
      title: GestureDetector(
        onTap: () {
          _navigateWithoutAnimation(context, '/home');
        },
        child: const Text(
          'ARcohol',
          style: TextStyle(color: Color(0xFFE94E2B)),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_cart, color: Color(0xFFBEB08B)),
          onPressed: () {
            _navigateWithoutAnimation(context, '/product');
          },
        ),
        IconButton(
          icon: const Icon(Icons.account_circle, color: Color(0xFFBEB08B)),
          onPressed: () {
            _navigateWithoutAnimation(context, '/mypage');
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final bool isLoggedIn = false;
  bool _isMyPageExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF333333),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 80,
            margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    isLoggedIn ? "홍길동님 환영합니다." : "로그인 후 이용해주세요.",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isLoggedIn ? Icons.logout : Icons.login,
                    color: const Color(0xFFFCD19C),
                  ),
                  onPressed: () {
                    // 로그인/로그아웃 처리
                  },
                ),
              ],
            ),
          ),
          const Divider(color: Colors.grey),

          // ▶ 마이페이지 + 하위 메뉴
          ListTile(
            leading: Icon(_isMyPageExpanded ? Icons.remove : Icons.add, color: const Color(0xFFFCD19C)),
            title: const Text('마이페이지', style: TextStyle(color: Color(0xFFFCD19C))),
            onTap: () {
              setState(() {
                _isMyPageExpanded = !_isMyPageExpanded;
              });
            },
          ),
          if (_isMyPageExpanded)
            Column(
              children: [
                _buildSubItem(context, Icons.edit, '내정보수정', '/mypage/edit'),
                _buildSubItem(context, Icons.receipt_long, '마이 레시피', '/mypage/recipe'),
                _buildSubItem(context, Icons.local_shipping, '구매내역 / 배송조회', '/mypage/orders'),
              ],
            ),

          // ▶ 기타 메뉴
          _buildDrawerItem(context, Icons.qr_code, 'AR제조법', '/ar'),
          _buildDrawerItem(context, Icons.shopping_cart, '장바구니', '/product'),
          _buildDrawerItem(context, Icons.sell, '판매', '/product'),
          _buildDrawerItem(context, Icons.book, '레시피', '/recipe'),
          _buildDrawerItem(context, Icons.local_bar, '마이바', '/mybar'),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String label, String routeName) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFFCD19C)),
      title: Text(label, style: const TextStyle(color: Color(0xFFFCD19C))),
      onTap: () {
        Navigator.of(context).pop();
        _navigateWithoutAnimation(context, routeName);
      },
    );
  }

  Widget _buildSubItem(BuildContext context, IconData icon, String label, String routeName) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 48, right: 16),
      leading: Icon(icon, color: const Color(0xFFFCD19C)),
      title: Text(label, style: const TextStyle(color: Color(0xFFFCD19C))),
      onTap: () {
        Navigator.of(context).pop();
        _navigateWithoutAnimation(context, routeName);
      },
    );
  }
}

void _navigateWithoutAnimation(BuildContext context, String routeName) {
  final routeWidgets = {
    '/home': const HomePage(),
    '/mypage/edit': const MyPage(),
    '/mypage/recipe': const MyRecipePage(),         // ← 구현 필요
    '/mypage/orders': const BuyProductPage(),       // ← 구현 필요
    '/ar': const ArPage(),
    '/wishList': const WishListPage(),
    '/product': const ProductPage(),
    '/recipe': const RecipePage(),
    '/mybar': const MyBarPage(),
  };

  final widget = routeWidgets[routeName] ?? const HomePage();

  Navigator.of(context).pushReplacement(PageRouteBuilder(
    pageBuilder: (_, __, ___) => widget,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  ));
}