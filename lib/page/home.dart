import 'package:flutter/material.dart';
import '../common/appBar.dart';
import '../common/bottomBar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          '메인 콘텐츠 영역 (추천, 인기, 판매 상품 등)',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}