import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/mypage': (context) => const MyPage(),
        '/mypage/edit': (context) => const ProfileEditPage(),
        '/mypage/recipe': (context) => const MyRecipePage(),
        '/mypage/orders': (context) => const BuyProductPage(),
        '/ar': (context) => const ArPage(),
        '/wishList': (context) => const WishListPage(),
        '/product': (context) => const ProductPage(),
        '/product/view': (context) => const ProductViewPage(),
        '/recipe': (context) => const RecipePage(),
        '/recipe/view': (context) => const RecipeViewPage(),
        '/mybar': (context) => const MyBarPage(),
        '/inventory': (context) => const InventoryPage(),
      },
    );
  }
}