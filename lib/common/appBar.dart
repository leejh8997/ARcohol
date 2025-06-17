import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../page/home.dart';
import '../page/myBar.dart';
import '../page/recipe.dart';
import '../page/arCamera.dart';
import '../page/product.dart';
import 'myPage.dart';
import 'profileEdit.dart';
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
            _navigateWithoutAnimation(context, '/wishList');
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
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final loginType = prefs.getString('login_type') ?? 'firebase';

    try {
      if (loginType == 'kakao') {
        final kakaoUid = prefs.getString('kakao_uid');
        if (kakaoUid != null) {
          final doc = await FirebaseFirestore.instance.collection('users').doc(kakaoUid).get();
          final fetchedName = doc.data()?['name'];
          setState(() {
            userName = fetchedName ?? '카카오 사용자';
          });
        }
      } else {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
          final fetchedName = doc.data()?['name'];
          setState(() {
            userName = fetchedName ?? '사용자';
          });
        }
      }
    } catch (e) {
      print('❌ 사용자 이름 로딩 실패: $e');
    }
  }

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
                    "${userName ?? '...'}님 환영합니다.",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Color(0xFFFCD19C)),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final loginType = prefs.getString('login_type') ?? 'firebase';

                    try {
                      if (loginType == 'kakao') {
                        await UserApi.instance.logout();
                        await prefs.remove('kakao_uid');
                      } else {
                        await FirebaseAuth.instance.signOut();
                      }
                      await prefs.remove('login_type');
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                      }
                    } catch (e) {
                      print('로그아웃 실패: $e');
                    }
                  },
                ),
              ],
            ),
          ),
          const Divider(color: Colors.grey),
          _buildDrawerItem(context, Icons.person, '마이페이지', '/mypage'),
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
}

void _navigateWithoutAnimation(BuildContext context, String routeName) {
  final routeWidgets = {
    '/home': const HomePage(),
    '/mypage': const MyPage(),
    '/mypage/edit': const ProfileEditPage(),
    '/mypage/recipe': const MyRecipePage(),
    '/mypage/orders': const BuyProductPage(),
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
