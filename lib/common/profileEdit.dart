import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../user/login.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          emailController.text = data['email'] ?? '';
          nameController.text = data['name'] ?? '';
          phoneController.text = data['phone'] ?? '';
          addressController.text = data['address'] ?? '';
        });
      }
    }
  }

  Future<void> _saveUserInfo() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('정보가 저장되었습니다.')));
    }
  }

  Future<void> _withdrawUser(User user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
      await user.delete();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원 탈퇴가 완료되었습니다')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('탈퇴 실패: ${e.toString()}')),
      );
    }
  }

  void _showWithdrawDialog() {
    final TextEditingController pwController = TextEditingController();
    final user = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('회원탈퇴'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('정말 탈퇴하시겠습니까?\n계정 정보는 복구되지 않습니다.'),
            const SizedBox(height: 12),
            TextField(
              controller: pwController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              final password = pwController.text.trim();
              if (password.isEmpty || user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('비밀번호를 입력하세요')),
                );
                return;
              }

              try {
                // ✅ 1. 재인증
                final cred = EmailAuthProvider.credential(
                  email: user.email!,
                  password: password,
                );
                await user.reauthenticateWithCredential(cred);

                Navigator.pop(context); // 다이얼로그 닫기
                await _withdrawUser(user); // ✅ 2. 탈퇴 진행
              } on FirebaseAuthException catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('비밀번호가 일치하지 않습니다')),
                );
              }
            },
            child: const Text('확인', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('프로필 수정'),
        leading: BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey,
                  child: Text(
                    nameController.text.isNotEmpty ? nameController.text[0] : '',
                    style: const TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildField('이메일', emailController, readOnly: true),
              _buildField('이름', nameController),
              _buildField('휴대폰 번호', phoneController),
              _buildPasswordChangeButton(),
              _buildField('주소', addressController),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveUserInfo,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE94E2B)),
                child: const Text('저장', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 40),
              TextButton(
                onPressed: _showWithdrawDialog,
                child: const Text('회원탈퇴', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          style: TextStyle( color: readOnly ? Colors.grey : Colors.white,),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black54,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPasswordChangeButton() {
    final currentPwCtrl = TextEditingController();
    final newPwCtrl = TextEditingController();
    final newPwConfirmCtrl = TextEditingController();

    bool isLengthValid(String pw) => pw.length >= 8;
    bool hasSpecialChar(String pw) =>
        RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-\\\/]').hasMatch(pw);

    void showPasswordChangeDialog() {
      bool isAuthSuccess = false;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return StatefulBuilder(builder: (ctx, setState) {
            return AlertDialog(
              title: Text('비밀번호 변경'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    if (!isAuthSuccess) ...[
                      TextField(
                        controller: currentPwCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: '현재 비밀번호',
                        ),
                      ),
                    ] else ...[
                      TextField(
                        controller: newPwCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: '새 비밀번호',
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            isLengthValid(newPwCtrl.text)
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: isLengthValid(newPwCtrl.text)
                                ? Colors.green
                                : Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text('8자 이상'),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            hasSpecialChar(newPwCtrl.text)
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: hasSpecialChar(newPwCtrl.text)
                                ? Colors.green
                                : Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text('특수문자 포함'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: newPwConfirmCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: '새 비밀번호 확인',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;

                    if (!isAuthSuccess) {
                      try {
                        final cred = EmailAuthProvider.credential(
                          email: user!.email!,
                          password: currentPwCtrl.text.trim(),
                        );
                        await user.reauthenticateWithCredential(cred);
                        setState(() {
                          isAuthSuccess = true;
                        });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('현재 비밀번호가 올바르지 않습니다')),
                        );
                      }
                    } else {
                      final newPw = newPwCtrl.text.trim();
                      final confirmPw = newPwConfirmCtrl.text.trim();

                      if (newPw != confirmPw) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('비밀번호가 일치하지 않습니다')),
                        );
                        return;
                      }
                      if (!isLengthValid(newPw) || !hasSpecialChar(newPw)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('비밀번호 조건을 만족하세요')),
                        );
                        return;
                      }

                      try {
                        await user!.updatePassword(newPw);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('비밀번호가 변경되었습니다')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('오류: ${e.toString()}')),
                        );
                      }
                    }
                  },
                  child: Text(isAuthSuccess ? '변경하기' : '확인'),
                ),
              ],
            );
          });
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('비밀번호 변경', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 4),
        ElevatedButton(
          onPressed: showPasswordChangeDialog,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black45),
          child: const Text('변경하기', style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}