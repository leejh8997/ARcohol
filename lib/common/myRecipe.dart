import 'package:flutter/material.dart';
import 'myRecipeAdd.dart';
import 'myRecipeList.dart';


class MyRecipePage extends StatefulWidget {
  const MyRecipePage({super.key});

  @override
  State<MyRecipePage> createState() => _MyRecipePageState();
}

class _MyRecipePageState extends State<MyRecipePage> {
  int selectedIndex = 0;

  final List<Widget> tabs = [
    MyRecipeAddPage(),
    MyRecipeListPage(), // 구현되어 있어야 함
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        foregroundColor: Colors.white,
        title: const Text('마이레시피'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 상단 탭
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _tabButton('등록', 0),
              _tabButton('목록', 1),
            ],
          ),
          Expanded(child: tabs[selectedIndex]),
        ],
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Color(0xFFE94E2B) : Color(0xFFBEB08B),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}