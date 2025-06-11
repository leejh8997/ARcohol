import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _pwController = TextEditingController();
  final _confirmController = TextEditingController();

  final Color backgroundColor = const Color(0xFF1F1F1F);
  final Color orange = const Color(0xFFE94E2B);

  bool get _isMatch =>
      _pwController.text.trim().isNotEmpty &&
          _pwController.text == _confirmController.text;

  void _resetPassword() {
    // TODO: 실제로는 서버에 비밀번호 변경 요청을 보내야 함
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('비밀번호가 성공적으로 변경되었습니다.')),
    );

    // 로그인 화면으로 되돌아가기 (맨 처음 화면으로)
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  void dispose() {
    _pwController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('비밀번호 재설정', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'ARcohol',
              style: TextStyle(
                color: orange,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Align(
              alignment: Alignment.centerLeft,
              child: const Text('새 비밀번호', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pwController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '새 비밀번호를 입력하세요',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child:
              const Text('비밀번호 확인', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '비밀번호를 다시 입력하세요',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isMatch ? _resetPassword : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isMatch ? orange : Colors.grey,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('비밀번호 변경', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
