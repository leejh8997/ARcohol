import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'page/home.dart';
import 'page/myBar.dart';
import 'page/recipe.dart';
import 'page/arCamera.dart';
import 'page/product.dart';
import 'common/myPage.dart';
import 'common/myRecipe.dart';
import 'common/wishList.dart';
import 'common/buyProduct.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
//test
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/mypage/edit': (context) => const MyPage(),
        '/mypage/recipe': (context) => const MyRecipePage(),
        '/mypage/orders': (context) => const BuyProductPage(),
        '/ar': (context) => const ArPage(),
        '/wishList': (context) => const WishListPage(),
        '/product': (context) => const ProductPage(),
        '/recipe': (context) => const RecipePage(),
        '/mybar': (context) => const MyBarPage(),



      },
    );
  }
}