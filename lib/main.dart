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
import 'common/profileEdit.dart ';
import 'user/login.dart';

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
      home: const LoginPage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/mypage': (context) => const MyPage(),
        '/mypage/edit': (context) => const ProfileEditPage(),
        '/mypage/recipe': (context) => const MyRecipePage(),
        '/mypage/orders': (context) => const BuyProductPage(),
        '/ar': (context) => const ArPage(),
        '/wishList': (context) => const WishListPage(),
        '/product': (context) => const ProductPage(),
        '/product/view': (context) => const ProductViewPage(productId: '',),
        '/recipe': (context) => const RecipePage(),
        '/recipe/view': (context) => const RecipeViewPage(),
        '/mybar': (context) => const MyBarPage(),
        '/inventory': (context) => const InventoryPage(),
      },
    );
  }
}
