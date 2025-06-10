import 'package:flutter/material.dart';
import '../common/appBar.dart';
import '../common/bottomBar.dart';

class MyBarPage extends StatefulWidget {
  const MyBarPage({super.key});

  @override
  State<MyBarPage> createState() => _MyBarPageState();
}

class _MyBarPageState extends State<MyBarPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  List<String> list = [];

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
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text("재료 목록", style: TextStyle(color: Colors.white),)),
                ElevatedButton(
                  onPressed: (){},
                  child: Text("마이재료")
                )
              ],
            ),
            ListView.builder(
              itemCount: list.length,
                itemBuilder: (context, index) {

                },
            )
          ],
        ),
      )
    );
  }
}