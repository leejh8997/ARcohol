import 'package:flutter/material.dart';
import '../common/appBar.dart';
import '../common/bottomBar.dart';

class RecipeViewPage extends StatefulWidget {
  const RecipeViewPage({super.key});

  @override
  State<RecipeViewPage> createState() => _RecipeViewPageState();
}

class _RecipeViewPageState extends State<RecipeViewPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

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
      backgroundColor: Color(0xFF1F1F1F),
      body: Center(
        child: Text(
          'RecipeView 페이지 입니다.',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}