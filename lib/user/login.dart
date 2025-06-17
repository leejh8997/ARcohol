import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';

import 'join.dart';
import '/page/home.dart';
import 'find_Id.dart';
import 'find_Pw.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  bool _rememberId = false;
  bool _autoLogin = false;

  final Color orange = const Color(0xFFE94E2B);
  final Color backgroundColor = const Color(0xFF333333);
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
    _loadSavedEmail();
  }

  void _checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final autoLogin = prefs.getBool('auto_login') ?? false;
    final currentUser = FirebaseAuth.instance.currentUser;

    if (autoLogin && currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      });
    }
  }

  void _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email') ?? '';
    final remember = prefs.getBool('remember_email') ?? false;

    setState(() {
      _rememberId = remember;
      if (remember) {
        _emailController.text = savedEmail;
      }
    });
  }

  void _login() async {
    final email = _emailController.text.trim();
    final pw = _pwController.text.trim();

    if (email.isEmpty || pw.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이메일과 비밀번호를 모두 입력하세요')));
      return;
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: pw);

      final prefs = await SharedPreferences.getInstance();
      if (_rememberId) {
        await prefs.setString('saved_email', email);
        await prefs.setBool('remember_email', true);
      } else {
        await prefs.remove('saved_email');
        await prefs.setBool('remember_email', false);
      }

      await prefs.setBool('auto_login', _autoLogin);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('로그인 실패: $e')));
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final firestore = FirebaseFirestore.instance;

        final existCheck = await firestore
            .collection('users')
            .where('email', isEqualTo: firebaseUser.email)
            .get();

        if (existCheck.docs.isEmpty) {
          final snapshot = await firestore
              .collection('users')
              .orderBy('uid', descending: true)
              .limit(1)
              .get();

          String newUid = 'user1';
          if (snapshot.docs.isNotEmpty) {
            final lastUid = snapshot.docs.first['uid'];
            final number = int.tryParse(lastUid.replaceAll('user', '')) ?? 0;
            newUid = 'user${number + 1}';
          }

          await firestore.collection('users').doc(firebaseUser.uid).set({
            'uid': newUid,
            'email': firebaseUser.email,
            'name': firebaseUser.displayName ?? '',
            'address': '부평 스테이션타워',
            'addressDetail': '7층',
            'brith': '19940609',
            'loginType': 'google',
            'password': 'test1234!',
            'createdAt': Timestamp.now(),
          });
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('auto_login', _autoLogin);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google 로그인 실패: $e')));
    }
  }

  Future<void> _signInWithKakao() async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();
      OAuthToken token = isInstalled
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();

      final user = await UserApi.instance.me();
      String email =
          user.kakaoAccount?.email ?? 'kakao_${user.id}@placeholder.com';
      String name = user.kakaoAccount?.profile?.nickname ?? 'ARcohol 관리자';

      final firestore = FirebaseFirestore.instance;
      final existCheck = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (existCheck.docs.isEmpty) {
        final snapshot = await firestore
            .collection('users')
            .orderBy('uid', descending: true)
            .limit(1)
            .get();

        String newUid = 'user1';
        if (snapshot.docs.isNotEmpty) {
          final lastUid = snapshot.docs.first['uid'];
          final number = int.tryParse(lastUid.replaceAll('user', '')) ?? 0;
          newUid = 'user${number + 1}';
        }

        await firestore.collection('users').doc(user.id.toString()).set({
          'uid': newUid,
          'email': email,
          'name': name,
          'address': '부평 스테이션타워',
          'addressDetail': '7층',
          'brith': '19940609',
          'loginType': 'kakao',
          'password': 'test1234!',
          'createdAt': Timestamp.now(),
        });
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auto_login', _autoLogin);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Kakao 로그인 실패: $e')));
    }
  }

  Future<void> _signInWithNaver() async {
    try {
      final result = await FlutterNaverLogin.logIn();

      if (result.status == 'loggedIn') {
        final account = result.account;

        final email = account?.email ?? 'naver_${account?.id}@placeholder.com';
        final name = account?.name ?? account?.nickname ?? '네이버 사용자';

        final firestore = FirebaseFirestore.instance;

        final existCheck = await firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        if (existCheck.docs.isEmpty) {
          final snapshot = await firestore
              .collection('users')
              .orderBy('uid', descending: true)
              .limit(1)
              .get();

          String newUid = 'user1';
          if (snapshot.docs.isNotEmpty) {
            final lastUid = snapshot.docs.first['uid'];
            final number = int.tryParse(lastUid.replaceAll('user', '')) ?? 0;
            newUid = 'user${number + 1}';
          }

          await firestore
              .collection('users')
              .doc(account?.id ?? email)
              .set({
            'uid': newUid,
            'email': email,
            'name': name,
            'address': '부평 스테이션타워',
            'addressDetail': '7층',
            'brith': '19940609',
            'loginType': 'naver',
            'password': 'test1234!',
            'createdAt': Timestamp.now(),
          });
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('auto_login', _autoLogin);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('네이버 로그인 실패: ${result.errorMessage}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네이버 로그인 중 에러 발생: $e')),
      );
    }
  }


  Widget buildSocialLoginButton({
    required String assetPath,
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
    Color? borderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: borderColor != null ? Border.all(color: borderColor) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(assetPath, width: 24, height: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/ARcohol4.png',
                height: 250, // 필요에 따라 조절 가능
              ),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: '이메일을 입력하세요',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pwController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '비밀번호를 입력하세요',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: _autoLogin,
                    onChanged: (val) => setState(() => _autoLogin = val!),
                    checkColor: Colors.black,
                    activeColor: Colors.white,
                  ),
                  const Text('자동 로그인', style: TextStyle(color: Colors.white70)),
                  const SizedBox(width: 24), // 간격 조절
                  Checkbox(
                    value: _rememberId,
                    onChanged: (val) => setState(() => _rememberId = val!),
                    checkColor: Colors.black,
                    activeColor: Colors.white,
                  ),
                  const Text('이메일 저장', style: TextStyle(color: Colors.white70)),
                ],
              ),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '로그인',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FindIdPage()),
                    ),
                    child: const Text(
                      '이메일 찾기',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const Text('|', style: TextStyle(color: Colors.white38)),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FindPwPage()),
                    ),
                    child: const Text(
                      '비밀번호 찾기',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const Text('|', style: TextStyle(color: Colors.white38)),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const JoinPage()),
                    ),
                    child: const Text(
                      '회원가입',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: const [
                  Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '간편 로그인',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                ],
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _signInWithGoogle,
                child: Container(
                  height: 48,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/google_login.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _signInWithKakao,
                child: Container(
                  height: 48,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/kakao_login.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // GestureDetector(
              //   onTap: _signInWithNaver,
              //   child: Container(
              //     height: 48,
              //     width: double.infinity,
              //     margin: const EdgeInsets.only(bottom: 12),
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(8),
              //     ),
              //     child: ClipRRect(
              //       borderRadius: BorderRadius.circular(8),
              //       child: Image.asset(
              //         'assets/naver_login.png',
              //         fit: BoxFit.cover,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
