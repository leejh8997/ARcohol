import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../page/arCamera.dart';
import '../page/home.dart';
import '../page/myBar.dart';
import '../page/product.dart';
import 'appBar.dart';
import 'bottomBar.dart';
import 'profileEdit.dart';
import 'buyProduct.dart';
import 'wishList.dart';
import 'myRecipe.dart';
import 'orderIssueLog.dart';
import '../page/recipe.dart';
import '../page/recipeView.dart';
import '../page/privacy_policy_page.dart'; // ✅ 개인정보 처리방침 페이지

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? userName;

  final recentRecipes = [
    {
      'imgUrl': 'https://masileng-bucket.s3.ap-northeast-2.amazonaws.com/TB_COCK_MASTER/07.%EB%B8%94%EB%A3%A8%ED%95%98%EC%99%80%EC%9D%B4.jpg',
      'id': 'r1'
    },
    {
      'imgUrl': 'https://img.daily.co.kr/@files/www.daily.co.kr/content/food/2017/20170829/994eb0ffd02773ad0fed1d3a3fa09612.png',
      'id': 'r2'
    },
    {
      'imgUrl': 'https://www.hakushika.co.jp/kr/enjoy/images/sp_img01_autumn_moon.jpg',
      'id': 'r3'
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        setState(() {
          userName = doc.data()?['name'] ?? '사용자';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
      drawer: const CustomDrawer(),
      bottomNavigationBar: const CustomBottomBar(currentIndex: 4),
      backgroundColor: const Color(0xFF1F1F1F),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const ProfileEditPage()))
                    .then((_) => _fetchUserName());
              },
              child: Text(
                '${userName ?? '...'}님 >',
                style: const TextStyle(color: Color(0xFFFCD19C), fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildIconButton(context, Icons.receipt, '주문내역', '/mypage/orders'),
              _buildIconButton(context, Icons.shopping_cart, '장바구니', '/wishList'),
              _buildIconButton(context, Icons.book, '마이레시피', '/mypage/recipe'),
              _buildIconButton(context, Icons.local_bar, '마이바', '/mybar'),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.grey),
          const SizedBox(height: 16),
          const Text('최근 본 상품', style: TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recentRecipes.length,
              itemBuilder: (context, index) {
                final recipe = recentRecipes[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecipeViewPage(recipeId: recipe['id']!),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(recipe['imgUrl']!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.grey),
          _buildTextButton(context, '주문 내역', '/mypage/orders'),
          const Divider(color: Colors.grey),
          _buildTextButton(context, '취소 · 반품 · 교환 내역', '/mypage/issue'),
          const Divider(color: Colors.grey),
          _buildTextButton(context, '고객센터'),
          const Divider(color: Colors.grey),
          _buildTextButton(context, '개인정보 처리방침'),
        ],
      ),
    );
  }

  Widget _buildTextButton(BuildContext context, String label, [String? routeName]) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.centerLeft,
      ),
      onPressed: () {
        if (label == '개인정보 처리방침') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
          );
        } else if (routeName != null) {
          _navigateWithoutAnimation(context, routeName);
        }
      },
      child: Text(label, style: const TextStyle(color: Color(0xFFFCD19C))),
    );
  }

  Widget _buildIconButton(BuildContext context, IconData icon, String label, String route) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.white),
          onPressed: () => _navigateWithoutAnimation(context, route),
        ),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }


  Widget _buildTextButton(BuildContext context, String label, [String? routeName]) {
    return TextButton(
      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), alignment: Alignment.centerLeft),
      onPressed: routeName != null ? () => _navigateWithoutAnimation(context, routeName) : null,
      child: Text(label, style: const TextStyle(color: Color(0xFFFCD19C))),
    );
  }
}

void _navigateWithoutAnimation(BuildContext context, String routeName) {
  final routeWidgets = {
    '/home': const HomePage(),
    '/mypage': const MyPage(),
    '/mypage/edit': const ProfileEditPage(),
    '/mypage/orders': const BuyProductPage(),
    '/mypage/recipe': const MyRecipePage(),
    '/mypage/issue': const OrderIssueLogPage(),
    '/wishList': const WishListPage(),
    '/recipe': const RecipePage(),
    '/ar': const ArPage(),
    '/product': const ProductPage(),
    '/mybar': const MyBarPage(),
  };


    final widget = routeWidgets[routeName] ?? const HomePage();

    if ([
      '/mypage/edit',
      '/mypage/orders',
      '/mybar',
    ].contains(routeName)) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => widget));
    } else {
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (_, __, ___) => widget,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ));
    }
  }
}
