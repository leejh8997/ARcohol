import 'package:flutter/material.dart';
import '../common/appBar.dart';
import '../common/bottomBar.dart';
import '../recipe/recipeLikedTab.dart';
import '../recipe/recipeAllTab.dart';
import '../recipe/customRecipe.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({super.key});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          // 탭바
          Container(
            color: Colors.black,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.pinkAccent,
              tabs: const [
                Tab(text: '전체 레시피'),
                Tab(text: '좋아요한 레시피'),
                Tab(text: '커스텀 레시피'),
              ],
            ),
          ),
          // 탭 컨텐츠
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                RecipeAllTab(),
                RecipeLikedTab(),
                CustomRecipePage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
