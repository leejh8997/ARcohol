import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'address_search_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARcohol',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1F1F1F),
        primaryColor: const Color(0xFFE94E2B),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade700),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFE94E2B)),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      home: const JoinPage(),
    );
  }
}

class JoinPage extends StatefulWidget {
  const JoinPage({Key? key}) : super(key: key);

  @override
  State<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  final _formKey = GlobalKey<FormState>();

  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  final _pwConfirmController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthController = TextEditingController();
  final _addressController = TextEditingController();

  bool isAdult = false;
  bool isBirthValid = true;

  void _checkAdult() {
    final raw = _birthController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (raw.length != 8) {
      setState(() {
        isAdult = false;
        isBirthValid = false;
      });
      return;
    }

    try {
      final birth = DateFormat('yyyyMMdd').parseStrict(raw);
      final now = DateTime.now();
      int age = now.year - birth.year;
      if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) {
        age--;
      }

      setState(() {
        isAdult = age >= 19;
        isBirthValid = true;
      });
    } catch (e) {
      setState(() {
        isAdult = false;
        isBirthValid = false;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (!isAdult) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('성인만 가입할 수 있습니다 (만 19세 이상)')),
        );
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('회원가입 완료!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFE94E2B);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('회원가입'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'ARcohol',
                style: TextStyle(
                  color: orange,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField('아이디', Icons.person, _idController),
                  _buildTextField('비밀번호', Icons.lock, _pwController, isPassword: true),
                  _buildTextField('비밀번호 확인', Icons.lock_outline, _pwConfirmController, isPassword: true),
                  _buildTextField('이름', Icons.account_circle, _nameController),
                  _buildTextField('휴대폰 번호', Icons.phone_android, _phoneController, inputType: TextInputType.phone),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('인증번호 전송')),
                      );
                    },
                    icon: const Icon(Icons.sms),
                    label: const Text('인증번호 받기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    '생년월일 (예: 20001128)',
                    Icons.cake,
                    _birthController,
                    inputType: TextInputType.number,
                    onChanged: (_) => _checkAdult(),
                  ),
                  if (!isBirthValid)
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '생년월일 형식이 잘못되었습니다 (예: 20001128)',
                        style: TextStyle(color: Colors.redAccent, fontSize: 13),
                      ),
                    ),
                  if (isBirthValid && !isAdult && _birthController.text.isNotEmpty)
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '성인 인증 실패 (만 19세 이상)',
                        style: TextStyle(color: Colors.redAccent, fontSize: 13),
                      ),
                    ),
                  // 주소 검색 텍스트필드
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextFormField(
                      controller: _addressController,
                      readOnly: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: '주소',
                        prefixIcon: const Icon(Icons.home, color: Colors.white),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search, color: Colors.white),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AddressSearchPage()),
                            );
                            if (result != null) {
                              setState(() {
                                _addressController.text = result;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('가입하기', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      IconData icon,
      TextEditingController controller, {
        bool isPassword = false,
        TextInputType inputType = TextInputType.text,
        void Function(String)? onChanged,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: inputType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.white),
        ),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label 입력하세요';
          }
          if (label == '비밀번호 확인' && value != _pwController.text) {
            return '비밀번호가 일치하지 않습니다';
          }
          if (label == '비밀번호' && value.length < 6) {
            return '6자 이상 입력하세요';
          }
          return null;
        },
      ),
    );
  }
}
