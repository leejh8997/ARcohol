import 'package:flutter/material.dart';
import 'appBar.dart';
import 'bottomBar.dart';

class buyProductPage extends StatefulWidget {
  const buyProductPage({super.key});

  @override
  State<buyProductPage> createState() => _buyProductPageState();
}

class _buyProductPageState extends State<buyProductPage> {
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
          'buyProduct 페이지 입니다.',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}