import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadPrivacyPolicyPage extends StatelessWidget {
  const UploadPrivacyPolicyPage({super.key});

  Future<void> uploadPrivacyPolicyFromAsset(BuildContext context) async {
    try {
      // JSON 파일 읽기
      final String jsonString =
      await rootBundle.loadString('assets/privacy_policy.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      // Firestore에 업로드
      await FirebaseFirestore.instance
          .collection('privacy_policy')
          .doc('main')
          .set(jsonData);

      // 성공 알림
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 업로드 성공!')),
        );
      }
    } catch (e) {
      // 실패 알림
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ 업로드 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: AppBar(
        title: const Text("개인정보 처리방침 업로드"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE94E2B),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          onPressed: () => uploadPrivacyPolicyFromAsset(context),
          child: const Text("업로드 실행"),
        ),
      ),
    );
  }
}
