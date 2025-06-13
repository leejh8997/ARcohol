import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import '../common/appBar.dart';
import '../common/bottomBar.dart';

class ArPage extends StatefulWidget {
  const ArPage({super.key});

  @override
  State<ArPage> createState() => _ArPageState();
}

class _ArPageState extends State<ArPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  UnityWidgetController? _unityWidgetController;

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
      body: SafeArea(
        bottom: false,
        child: WillPopScope(
          onWillPop: () async {
            // Android 뒤로 가기 버튼 처리
            return true;
          },
          child: Container(
            color: const Color(0xFF1F1F1F),
            child: Center(
              child: UnityWidget(
                onUnityCreated: onUnityCreated,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Unity 컨트롤러 생성 콜백
  void onUnityCreated(controller) {
    _unityWidgetController = controller;
  }
}