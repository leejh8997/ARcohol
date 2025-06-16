import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordPage extends StatelessWidget {
  final String email;
  const ResetPasswordPage({super.key, required this.email});

  final Color backgroundColor = const Color(0xFF1F1F1F);
  final Color orange = const Color(0xFFE94E2B);

  Future<void> _sendResetLink(BuildContext context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호 재설정 링크가\n$email 으로 전송되었습니다.')),
      );
      Navigator.popUntil(context, (route) => route.isFirst); // 홈으로 이동
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('전송 실패: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('알 수 없는 오류: $e')),
      );
    }
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'ARcohol',
              style: TextStyle(
                color: Color(0xFFE94E2B),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              '$email\n으로 비밀번호 재설정 메일을 전송하시겠습니까?',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => _sendResetLink(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('재설정 링크 전송', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
