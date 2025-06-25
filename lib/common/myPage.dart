import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'appBar.dart';
import 'bottomBar.dart';
import 'profileEdit.dart';
import 'buyProduct.dart';
import 'wishList.dart';
import 'myRecipe.dart';
import 'orderIssueLog.dart';

import '../page/arCamera.dart';
import '../page/home.dart';
import '../page/myBar.dart';
import '../page/product.dart';
import '../page/recipe.dart';
import '../page/recipeView.dart';
import '../page/privacy_policy_page.dart';
import '../page/terms_of_service_page.dart';
import '../page/customer_service_page.dart';
import '../page/noticePage.dart';


class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? userName;
  List<Map<String, dynamic>> recentRecipes = [];
  int viewCount = 5;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchRecentRecipes();
  }

  Future<void> _fetchRecentRecipes() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();

    if (data != null && data['recentRecipes'] != null) {
      List<dynamic> rawList = data['recentRecipes'];
      rawList.sort((a, b) => b['viewedAt'].compareTo(a['viewedAt'])); // 최신순 정렬
      setState(() {
        recentRecipes = rawList.cast<Map<String, dynamic>>();
        viewCount = 5;
      });
    }
  }

  Future<void> _fetchUserName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
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
                    .push(
                      MaterialPageRoute(
                        builder: (_) => const ProfileEditPage(),
                      ),
                    )
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
              _buildIconButton(
                context,
                Icons.receipt,
                '주문내역',
                '/mypage/orders',
              ),
              _buildIconButton(
                context,
                Icons.shopping_cart,
                '장바구니',
                '/mypage/wish',
              ),
              _buildIconButton(context, Icons.book, '마이레시피', '/mypage/recipe'),
              _buildIconButton(context, Icons.local_bar, '마이바', '/mybar'),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            '최근 본 레시피',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          if (recentRecipes.isEmpty)
            const Text("최근 본 레시피가 없습니다.", style: TextStyle(color: Colors.grey)),

          if (recentRecipes.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 130,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: recentRecipes.length > viewCount
                        ? viewCount + 1 // ➕ 카드 포함
                        : recentRecipes.length,
                    itemBuilder: (context, index) {
                      // 🔹➕ 카드 위치
                      if (index == viewCount && recentRecipes.length > viewCount) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              viewCount += 5;
                            });
                          },
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF333333),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(Icons.add, color: Colors.white),
                            ),
                          ),
                        );
                      }

                      // 🔹일반 레시피 카드
                      final recipe = recentRecipes[index];
                      final recipeId = recipe['id'];
                      final isCustom = recipe['isCustom'] ?? false;
                      final imgUrl = recipe['imgUrl'] ?? '';
                      final cockNameKo = recipe['cockName_ko'] ?? '';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecipeViewPage(
                                recipeId: recipeId,
                                isCustom: isCustom,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 100,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imgUrl,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cockNameKo,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          const SizedBox(height: 14),
          const Divider(color: Colors.grey),
          _buildTextButton(context, '주문 내역', '/mypage/orders'),
          const Divider(color: Colors.grey),
          _buildTextButton(context, '취소 · 반품 · 교환 내역', '/mypage/issue'),
          const Divider(color: Colors.grey),
          _buildTextButton(context, '고객센터', '/mypage/service'),
          const Divider(color: Colors.grey),
          _buildTextButton(context, '공지사항', '/mypage/notice'),
          const Divider(color: Colors.grey),
          _buildTextButton(context, '개인정보 처리방침', '/mypage/policy'),
          const Divider(color: Colors.grey),
          _buildTextButton(context, '서비스 이용약관', '/mypage/terms'),
          const Divider(color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildIconButton(BuildContext context, IconData icon, String label, String routeName) {

    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: const Color(0xFFE94E2B)),
          onPressed: () => _navigateWithoutAnimation(context, routeName),
        ),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
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
    '/mypage/wish': const WishListPage(),
    '/mypage/recipe': const MyRecipePage(),
    '/mypage/issue': const OrderIssueLogPage(),
    '/mypage/service': const CustomerServicePage(),
    '/mypage/notice': const NoticePage(),
    '/mypage/policy': const PrivacyPolicyPage(),
    '/mypage/terms': const TermsOfServicePage(),
    '/recipe': const RecipePage(),
    '/ar': const ArPage(),
    '/product': const ProductPage(),
    '/mybar': const MyBarPage(),
  };

  final widget = routeWidgets[routeName] ?? const HomePage();

  if ([
    '/mypage/edit',
    '/mypage/orders',
    '/mypage/wish',
    '/mypage/issue',
    '/mypage/service',
    '/mypage/notice',
    '/mypage/policy',
    '/mypage/terms',
    '/mypage/recipe',
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