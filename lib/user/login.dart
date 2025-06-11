import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 추가
import 'join.dart';
import '/page/home.dart';
import 'find_Id.dart';
import 'find_Pw.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  bool _rememberId = false;

  final Color orange = const Color(0xFFE94E2B);
  final Color backgroundColor = const Color(0xFF1F1F1F);
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _login() async {
    final email = _emailController.text.trim();
    final pw = _pwController.text.trim();

    if (email.isEmpty || pw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일과 비밀번호를 모두 입력하세요')),
      );
      return;
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: pw);

      // ✅ 이메일 저장 여부 처리
      final prefs = await SharedPreferences.getInstance();
      if (_rememberId) {
        await prefs.setString('saved_email', email);
        await prefs.setBool('remember_email', true);
      } else {
        await prefs.remove('saved_email');
        await prefs.setBool('remember_email', false);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      String msg = '로그인 실패';
      if (e.code == 'user-not-found') {
        msg = '존재하지 않는 이메일입니다';
      } else if (e.code == 'wrong-password') {
        msg = '비밀번호가 틀렸습니다';
      } else if (e.code == 'invalid-email') {
        msg = '이메일 형식이 올바르지 않습니다';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('에러 발생: $e')),
      );
    }
  }

  Widget _buildSocialButton(Color color, String text, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {
        // 소셜 로그인 로직 추가 예정
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon, color: Colors.black),
      label: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
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
              const SizedBox(height: 40),
              Text(
                'ARcohol',
                style: TextStyle(
                  color: orange,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 40),
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
                    value: _rememberId,
                    onChanged: (val) {
                      setState(() {
                        _rememberId = val!;
                      });
                    },
                    checkColor: Colors.black,
                    activeColor: Colors.white,
                  ),
                  const Text('이메일 저장', style: TextStyle(color: Colors.white70)),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('로그인', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FindIdPage()),
                      );
                    },
                    child: const Text('이메일 찾기', style: TextStyle(color: Colors.white70)),
                  ),
                  const Text('|', style: TextStyle(color: Colors.white38)),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FindPwPage()),
                      );
                    },
                    child: const Text('비밀번호 찾기', style: TextStyle(color: Colors.white70)),
                  ),
                  const Text('|', style: TextStyle(color: Colors.white38)),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const JoinPage()),
                      );
                    },
                    child: const Text('회원가입', style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('간편 로그인', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              _buildSocialButton(Colors.white, 'Sign in with Google', Icons.g_mobiledata),
              const SizedBox(height: 8),
              _buildSocialButton(Colors.green, '네이버 로그인', Icons.nature),
              const SizedBox(height: 8),
              _buildSocialButton(Colors.yellow, '카카오 로그인', Icons.chat_bubble),
            ],
          ),
        ),
      ),
    );
  }
}
