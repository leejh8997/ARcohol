// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart'; // ✅ Kakao SDK 추가

import 'page/home.dart';
import 'page/myBar.dart';
import 'page/recipe.dart';
import 'page/arCamera.dart';
import 'page/product.dart';
import 'page/recipeView.dart';
import 'page/productView.dart';
import 'page/inventory.dart';

import 'common/myPage.dart';
import 'common/myRecipe.dart';
import 'common/wishList.dart';
import 'common/buyProduct.dart';
import 'common/profileEdit.dart';
import 'user/login.dart';
import 'user/join.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('ko_KR', null);

  KakaoSdk.init(nativeAppKey: 'deba8198200e85d10e869be36ac90a4a'); // ✅ 카카오 초기화

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1F1F1F),
        primaryColor: const Color(0xFFE94E2B),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE94E2B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIconColor: Colors.white70,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade700),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFE94E2B)),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/login': (context) => const LoginPage(),
        '/join': (context) => const JoinPage(),
        '/home': (context) => const HomePage(),
        '/mypage': (context) => const MyPage(),
        '/mypage/edit': (context) => const ProfileEditPage(),
        '/mypage/recipe': (context) => const MyRecipePage(),
        '/mypage/orders': (context) => const BuyProductPage(),
        '/ar': (context) => const ArPage(),
        '/wishList': (context) => const WishListPage(),
        '/product': (context) => const ProductPage(),
        '/product/view': (context) => const ProductViewPage(productId: ''),
        '/recipe': (context) => const RecipePage(),
        '/recipe/view': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return RecipeViewPage(
            recipeId: args['recipeId'],
            isCustom: args['isCustom'] ?? false,
          );
        },
        '/mybar': (context) => const MyBarPage(),
        '/inventory': (context) => const InventoryPage(),
      },
    );
  }
}
