import 'package:flutter/material.dart';
import 'page/home.dart';
import 'page/myBar.dart';
import 'page/recipe.dart';
import 'page/arCamera.dart';
import 'page/product.dart';
import 'common/myPage.dart';
import 'common/myRecipe.dart';
import 'common/wishList.dart';
import 'common/buyProduct.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/product': (context) => const ProductPage(),
        '/ar': (context) => const ArPage(),
        '/recipe': (context) => const RecipePage(),
        '/mybar': (context) => const MyBarPage(),
        '/mypage': (context) => const MyPage(),
        '/myRecipe': (context) => const MyPage(),
        '/wishList': (context) => const MyPage(),
        '/buyProduct': (context) => const MyPage(),
      },
    );
  }
}