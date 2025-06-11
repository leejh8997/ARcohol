import 'package:flutter/material.dart';
import '../page/arCamera.dart';
import '../page/home.dart';
import '../page/myBar.dart';
import '../page/product.dart';
import 'appBar.dart';
import 'bottomBar.dart';
import 'profileEdit.dart';
import 'buyProduct.dart';
import 'wishList.dart';
import '../page/recipe.dart';
import '../page/recipeView.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    final recentRecipes = [
      {'imgUrl': 'https://masileng-bucket.s3.ap-northeast-2.amazonaws.com/TB_COCK_MASTER/07.%EB%B8%94%EB%A3%A8%ED%95%98%EC%99%80%EC%9D%B4.jpg', 'id': 'r1'},
      {'imgUrl': 'https://img.daily.co.kr/@files/www.daily.co.kr/content/food/2017/20170829/994eb0ffd02773ad0fed1d3a3fa09612.png', 'id': 'r2'},
      {'imgUrl': 'https://www.hakushika.co.jp/kr/enjoy/images/sp_img01_autumn_moon.jpg', 'id': 'r3'},
    ];

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
                _navigateWithoutAnimation(context, '/mypage/edit');
              },
              child: const Text('홍길동님 >', style: TextStyle(color: Color(0xFFFCD19C), fontSize: 18)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildIconButton(context, Icons.receipt, '주문내역', '/mypage/orders'),
              _buildIconButton(context, Icons.shopping_cart, '장바구니', '/wishList'),
              _buildIconButton(context, Icons.favorite, '좋아요', '/recipe'),
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
                    // 예시: 상세 레시피 페이지로 이동 (레시피 ID 넘기기 필요)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RecipeViewPage(), // 필요시 id 넘기기
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
          _buildTextButton(context, '취소 · 반품 · 교환 내역'),
          const Divider(color: Colors.grey),
          _buildTextButton(context, '고객센터'),
          const Divider(color: Colors.grey),
          _buildTextButton(context, '개인정보 처리방침'),
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

// ✅ 기존과 동일한 함수 활용
void _navigateWithoutAnimation(BuildContext context, String routeName) {
  final routeWidgets = {
    '/home': const HomePage(),
    '/mypage': const MyPage(),
    '/mypage/edit': const ProfileEditPage(),
    '/mypage/orders': const BuyProductPage(),
    '/wishList': const WishListPage(),
    '/recipe': const RecipePage(),
    '/ar': const ArPage(),
    '/product': const ProductPage(),
    '/mybar': const MyBarPage(),
  };

  final widget = routeWidgets[routeName] ?? const HomePage();

  // ✅ 특정 페이지는 push로 이동 (되돌아올 수 있게)
  if ([
    '/mypage/edit',
    '/mypage/orders',
    '/mybar',
  ].contains(routeName)) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => widget));
  } else {
    // ✅ 나머지는 기존 방식 유지
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (_, __, ___) => widget,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ));
  }
}