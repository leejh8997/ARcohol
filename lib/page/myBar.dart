// MyBarPage.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../common/appBar.dart';
import '../common/bottomBar.dart';
import '../myBar/ingredientsList.dart';
import '../myBar/ingredientsView.dart';
import '../myBar/inventory_tab.dart';

final GlobalKey<NavigatorState> _nestedNavigatorKey = GlobalKey<NavigatorState>();

class MyBarPage extends StatefulWidget {
  const MyBarPage({super.key});

  @override
  State<MyBarPage> createState() => _MyBarPageState();
}

class _MyBarPageState extends State<MyBarPage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
      drawer: const CustomDrawer(),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      backgroundColor: const Color(0xFF1F1F1F),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              color: const Color(0xFF1F1F1F),
              child: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFFF64F1A),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: '추천레시피'),
                  Tab(text: '재료 창고'),
                  Tab(text: '내 창고'),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const Center(child: Text("추천 가능한 레시피 리스트", style: TextStyle(color: Colors.white))),
                Navigator(
                  key: _nestedNavigatorKey,
                  onGenerateRoute: (settings) {
                    if (settings.name == '/view') {
                      final args = settings.arguments as IngredientsViewArgs;
                      return MaterialPageRoute(
                        builder: (_) => IngredientsView(category: args.category),
                      );
                    }
                    return MaterialPageRoute(
                      builder: (_) => IngredientsList(navigatorKey: _nestedNavigatorKey),
                    );
                  },
                ),
                const InventoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class IngredientsViewArgs {
  final String category;
  final List<QueryDocumentSnapshot> docs;

  IngredientsViewArgs(this.category, this.docs);
}
