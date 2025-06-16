import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FindIdPage extends StatefulWidget {
  const FindIdPage({super.key});

  @override
  State<FindIdPage> createState() => _FindIdPageState();
}

class _FindIdPageState extends State<FindIdPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  final Color backgroundColor = const Color(0xFF1F1F1F);
  final Color orange = const Color(0xFFE94E2B);

  bool get _isFilled =>
      _nameController.text.trim().isNotEmpty &&
          _phoneController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
    _phoneController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _findId() async {
    final name = _nameController.text.trim();
    final phoneInput = _phoneController.text.trim();
    final normalizedPhone = normalizePhone(phoneInput);

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: name)
          .where('phone', isEqualTo: normalizedPhone)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        final email = userDoc['email'] ?? '';
        final masked = _maskEmail(email);

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('이메일 찾기 결과'),
            content: Text('가입된 이메일은\n$masked 입니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // 먼저 dialog 닫고
                  Navigator.pushReplacementNamed(context, '/login'); // 로그인 페이지로 이동
                },
                child: const Text('확인'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('일치하는 회원 정보를 찾을 수 없습니다.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('오류가 발생했습니다. 다시 시도해주세요.')),
      );
    }
  }

  String normalizePhone(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), ''); // 숫자만 추출
    if (digits.length == 11 && digits.startsWith('010')) {
      final part1 = digits.substring(3, 7);
      final part2 = digits.substring(7);
      return '+82 10-$part1-$part2';
    }
    return input;
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final local = parts[0];
    final domain = parts[1];

    if (local.length < 3) {
      return '*@$domain';
    } else {
      final visible = local.substring(0, local.length - 3);
      return '$visible***@$domain';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('이메일 찾기', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
              child: const Text('이름', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '가입 시 등록한 이름을 입력해주세요',
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
              const Text('휴대폰 번호', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '-를 제외하고 입력해주세요',
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
              onPressed: _isFilled ? _findId : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFilled ? orange : Colors.grey,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('확인', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
