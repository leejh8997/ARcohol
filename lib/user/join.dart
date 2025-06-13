import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:portone_flutter/model/certification_data.dart';
import 'package:portone_flutter/portone_flutter.dart';
import 'address_search_page.dart';
import 'login.dart';

class JoinPage extends StatefulWidget {
  const JoinPage({Key? key}) : super(key: key);

  @override
  State<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  final _formKey = GlobalKey<FormState>();
  final List<String> termsTitles = [
    '[필수] 만 19세 이상',
    '[필수] ARcohol 개인정보 수집 및 이용',
    '[필수] ARcohol 제 3자 정보제공',
    '[필수] 마켓 개인정보 수집 및 이용',
  ];

  final List<String> termsDetails = [
    '''
만 19세 이상이어야 서비스를 이용할 수 있습니다.
회원가입 시 생년월일을 기준으로 성인 여부를 확인하며,
만 19세 미만은 본 서비스를 이용하실 수 없습니다.
''',
    '''
ARcohol은 서비스 제공을 위해 다음과 같은 개인정보를 수집합니다:
- 수집 항목: 이름, 이메일, 전화번호, 생년월일 등
- 수집 목적: 회원 관리, 본인 인증, 맞춤 서비스 제공 등
- 보유 기간: 회원 탈퇴 시까지 또는 법정 보유기간

자세한 사항은 개인정보처리방침을 참고해주세요.
''',
    '''
ARcohol은 서비스 제공을 위해 아래와 같은 제3자에게 정보를 제공합니다:
- 제공 대상: 결제 대행사, 배송 업체 등
- 제공 항목: 이름, 연락처, 주소, 주문 정보 등
- 제공 목적: 결제 처리 및 상품 배송

제공되는 정보는 최소한으로 제한되며, 동의 없이 사용되지 않습니다.
''',
    '''
마켓 이용 시 다음과 같은 개인정보가 수집 및 이용됩니다:
- 목적: 상품 주문 및 배송, 고객 지원
- 항목: 수취인 이름, 전화번호, 주소 등
- 보유 기간: 관련 법령에 따른 보관 기한 후 즉시 파기

보다 안전한 서비스 이용을 위해 ARcohol은 개인정보 보호에 최선을 다합니다.
''',
  ];

  List<bool> checkedList = [false, false, false, false];
  bool allChecked = false;

  final _emailController = TextEditingController();
  final _pwController = TextEditingController();
  final _pwConfirmController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _addressDetailController = TextEditingController();

  bool isEmailUnique = true;
  bool emailChecked = false;
  bool isPhoneVerified = false;
  bool isAdultValid = false;
  bool isBirthValid = true;
  bool isCertified = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _verificationId;

  @override
  void initState() {
    super.initState();
    _birthController.addListener(() {
      final text = _birthController.text.trim();
      if (text.length == 8) {
        final year = int.tryParse(text.substring(0, 4));
        final month = int.tryParse(text.substring(4, 6));
        final day = int.tryParse(text.substring(6, 8));

        if (year == null || month == null || day == null) {
          setState(() {
            isAdultValid = false;
            isBirthValid = false;
          });
          return;
        }

        try {
          final birth = DateTime(year, month, day);
          if (birth.year != year || birth.month != month || birth.day != day) {
            setState(() {
              isAdultValid = false;
              isBirthValid = false;
            });
            return;
          }

          if (birth.isAfter(DateTime.now())) {
            setState(() {
              isAdultValid = false;
              isBirthValid = false;
            });
          } else {
            setState(() {
              isAdultValid = _isAdult(text);
              isBirthValid = true;
            });
          }
        } catch (_) {
          setState(() {
            isAdultValid = false;
            isBirthValid = false;
          });
        }
      } else {
        setState(() {
          isAdultValid = false;
          isBirthValid = true;
        });
      }
    });
  }

  bool _isAdult(String birthString) {
    try {
      final birthDate = DateTime.parse(birthString);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age >= 19;
    } catch (_) {
      return false;
    }
  }

  void _searchAddress() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const AddressSearchPage()),
    );

    if (!mounted) return;

    if (result != null && result.isNotEmpty) {
      setState(() {
        _addressController.text = result;
      });
    } else {
      print("❌ 주소 검색 결과가 null이거나 빈 값입니다.");
    }
  }

  Future<void> startCertification() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IamportCertification(
          userCode: "imp10391904",
          data: CertificationData(
            merchantUid: "mid_${DateTime.now().millisecondsSinceEpoch}",
            mRedirectUrl: "https://www.your-service.com/cert",
          ),
          callback: (Map<String, String> result) {
            print('인증 콜백 결과: $result');
            Navigator.pop(context, result); // 인증 결과 돌려보냄
          },
        ),
      ),
    );

    if (result != null && result['success'] == 'true') {
      try {
        final birthStr = result['response']?['birth']?.toString();
        print("✅ birthStr: $birthStr");

        if (birthStr == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('생년월일 정보 없음')));
          return;
        }

        final birthInt = int.tryParse(birthStr);
        if (birthInt == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('생년월일 파싱 실패')));
          return;
        }

        final birthDate = DateTime.fromMillisecondsSinceEpoch(birthInt * 1000);
        final formattedBirth =
            "${birthDate.year.toString().padLeft(4, '0')}"
            "${birthDate.month.toString().padLeft(2, '0')}"
            "${birthDate.day.toString().padLeft(2, '0')}";
        _birthController.text = formattedBirth;

        setState(() => isCertified = true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('본인인증 성공')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('인증 처리 중 오류: $e')));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('본인인증 실패')));
    }
  }

  Future<void> checkEmailDuplicate() async {
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (email.isEmpty || !emailRegex.hasMatch(email)) {
      setState(() {
        emailChecked = true;
        isEmailUnique = false;
      });
      return;
    }

    final result = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    setState(() {
      isEmailUnique = result.docs.isEmpty;
      emailChecked = true;
    });
  }

  bool get isLengthValid => _pwController.text.length >= 8;

  bool get hasSpecialChar =>
      RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-\\\/]').hasMatch(_pwController.text);

  bool get isPasswordConfirmed =>
      _pwController.text == _pwConfirmController.text &&
      _pwConfirmController.text.isNotEmpty;

  Future<void> sendSmsCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('휴대폰 번호를 입력하세요')));
      return;
    }
    if (isPhoneVerified) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이미 인증된 번호입니다')));
      return;
    }

    final formattedPhone = phone.startsWith('+')
        ? phone
        : '+82${phone.substring(1)}';

    if (formattedPhone == '+821012345678') {
      try {
        final testCredential = PhoneAuthProvider.credential(
          verificationId: 'test-verification-id',
          smsCode: '123456',
        );
        await _auth.signInWithCredential(testCredential);
        setState(() => isPhoneVerified = true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('에뮬레이터 테스트 인증 완료')));
        return;
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('에뮬레이터 인증 실패: $e')));
        return;
      }
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: formattedPhone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        setState(() => isPhoneVerified = true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('자동 인증 완료')));
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('인증 실패: ${e.message}')));
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('인증번호가 발송되었습니다')));
        showSmsCodeDialog();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  void showSmsCodeDialog() {
    final _codeController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('인증번호 입력'),
          content: TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: '인증번호 6자리 입력'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                final code = _codeController.text.trim();
                if (code.length != 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('6자리 인증번호를 입력하세요')),
                  );
                  return;
                }
                try {
                  // 인증 성공 처리만 진행 (로그인하지 않음)
                  setState(() => isPhoneVerified = true);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('휴대폰 인증 완료')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('인증번호가 올바르지 않습니다')),
                  );
                }
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future<String> getNextUserId() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('uid', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return 'user1';

    final lastUid = snapshot.docs.first['uid']; // 예: user12
    final lastNumber = int.tryParse(lastUid.replaceAll('user', '')) ?? 0;
    return 'user${lastNumber + 1}';
  }

  void showTermDetailModal(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                children: [
                  // ✅ 닫기 버튼 영역
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        termsTitles[index],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context), // ✅ 모달 닫기
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ✅ 본문 내용 (스크롤)
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Text(
                        termsDetails[index],
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (checkedList.contains(false)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('모든 약관에 동의해주세요')));
      return;
    }
    if (!emailChecked || !isEmailUnique) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이메일 중복 확인을 해주세요')));
      return;
    }
    if (!isLengthValid || !hasSpecialChar) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('비밀번호 조건을 만족하세요')));
      return;
    }
    if (!isPasswordConfirmed) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('비밀번호가 일치하지 않습니다')));
      return;
    }
    if (!isAdultValid) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('만 19세 이상만 가입할 수 있습니다')));
      return;
    }
    if (!isPhoneVerified) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('휴대폰 인증을 완료해주세요')));
      return;
    }

    final email = _emailController.text.trim();
    final password = _pwController.text.trim();
    final phone = _phoneController.text.trim();
    final birth = _birthController.text.trim();

    try {
      // ✅ Firebase Auth에 회원 계정 생성
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user!.uid;
      final userDocId = await getNextUserId();

      // ✅ Firestore에 회원 정보 저장
      await _firestore.collection('users').doc(uid).set({
        'uid': userDocId,
        'email': email,
        'phone': phone,
        'birth': birth,
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'addressDetail': _addressDetailController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('회원가입 성공!')));

      // ✅ 로그인 화면으로 이동
      if (mounted) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      String msg = '회원가입 실패';
      if (e.code == 'email-already-in-use') {
        msg = '이미 사용 중인 이메일입니다';
      } else if (e.code == 'invalid-email') {
        msg = '유효하지 않은 이메일입니다';
      } else if (e.code == 'weak-password') {
        msg = '비밀번호가 너무 약합니다';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('오류: $e')));
    }
  }

  Widget _conditionRow(bool conditionMet, String text) {
    return Row(
      children: [
        Icon(
          conditionMet ? Icons.check_circle : Icons.radio_button_unchecked,
          color: conditionMet ? Colors.lightGreenAccent : Colors.grey,
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: conditionMet ? Colors.lightGreenAccent : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
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
          filled: true, // ✅ 추가
          border: OutlineInputBorder(),
        ),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) return '$label 입력하세요';
          if (label == '이메일') {
            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(value)) return '유효한 이메일 형식이 아닙니다';
          }
          if (label == '비밀번호 확인' && value != _pwController.text)
            return '비밀번호가 일치하지 않습니다';
          if (label == '비밀번호') {
            if (value.length < 8) return '최소 8자 이상 입력하세요';
            if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-\\\/]').hasMatch(value)) {
              return '특수문자 1개 이상 포함해야 합니다';
            }
          }
          if (label == '휴대폰 번호' && value.length < 10)
            return '올바른 휴대폰 번호를 입력하세요';
          if (label.contains('생년월일')) {
            if (value.length != 8) return '생년월일은 8자리로 입력하세요 (YYYYMMDD)';
            final year = int.tryParse(value.substring(0, 4));
            final month = int.tryParse(value.substring(4, 6));
            final day = int.tryParse(value.substring(6, 8));
            if (year == null || month == null || day == null)
              return '존재하지 않는 날짜입니다';
            try {
              final birth = DateTime(year, month, day);
              if (birth.year != year ||
                  birth.month != month ||
                  birth.day != day)
                return '존재하지 않는 날짜입니다';
              if (birth.isAfter(DateTime.now())) return '존재하지 않는 날짜입니다';
            } catch (_) {
              return '존재하지 않는 날짜입니다';
            }
          }
          return null;
        },
      ),
    );
  }

  Widget buildTermsSection() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            value: allChecked,
            title: const Text('모두 동의합니다'),
            onChanged: (value) {
              setState(() {
                allChecked = value ?? false;
                for (int i = 0; i < checkedList.length; i++) {
                  checkedList[i] = allChecked;
                }
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const Divider(color: Colors.grey),
          ...List.generate(termsTitles.length, (index) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: checkedList[index],
                            onChanged: (val) {
                              setState(() {
                                checkedList[index] = val ?? false;
                                allChecked = checkedList.every((v) => v);
                              });
                            },
                          ),
                          Expanded(
                            child: Text(
                              termsTitles[index],
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  onPressed: () => showTermDetailModal(index),
                ),
              ],
            );
          }),
        ],
      ),
    );
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField('이름', Icons.person, _nameController),
              _buildTextField(
                '이메일',
                Icons.email,
                _emailController,
                inputType: TextInputType.emailAddress,
                onChanged: (_) => checkEmailDuplicate(),
              ),
              if (emailChecked)
                if (emailChecked)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      isEmailUnique &&
                              _emailController.text.trim().contains('@')
                          ? '사용할 수 있는 이메일입니다'
                          : '이메일 형식이 올바르지 않거나 이미 사용 중입니다',
                      style: TextStyle(
                        color:
                            isEmailUnique &&
                                _emailController.text.trim().contains('@')
                            ? Colors.lightGreenAccent
                            : Colors.redAccent,
                        fontSize: 13,
                      ),
                    ),
                  ),
              const SizedBox(height: 20),
              _buildTextField(
                '비밀번호',
                Icons.lock,
                _pwController,
                isPassword: true,
                onChanged: (_) => setState(() {}),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _conditionRow(isLengthValid, '최소 8자 이상'),
                    _conditionRow(hasSpecialChar, '특수문자 1개 이상 포함'),
                  ],
                ),
              ),
              _buildTextField(
                '비밀번호 확인',
                Icons.lock_outline,
                _pwConfirmController,
                isPassword: true,
                onChanged: (_) => setState(() {}),
              ),
              if (_pwConfirmController.text.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isPasswordConfirmed ? '비밀번호가 일치합니다' : '비밀번호가 일치하지 않습니다',
                    style: TextStyle(
                      color: isPasswordConfirmed
                          ? Colors.lightGreenAccent
                          : Colors.redAccent,
                      fontSize: 13,
                    ),
                  ),
                ),
              _buildTextField(
                '휴대폰 번호',
                Icons.phone_android,
                _phoneController,
                inputType: TextInputType.phone,
              ),
              ElevatedButton.icon(
                onPressed: startCertification,
                icon: const Icon(Icons.verified_user),
                label: const Text('본인인증 하기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: sendSmsCode,
                icon: const Icon(Icons.sms),
                label: Text(isPhoneVerified ? '인증 완료' : '인증번호 받기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPhoneVerified ? Colors.grey : orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                '생년월일 (YYYYMMDD)',
                Icons.calendar_today,
                _birthController,
                inputType: TextInputType.number,
              ),
              if (_birthController.text.length == 8)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    !isBirthValid
                        ? '존재하지 않는 날짜입니다'
                        : isAdultValid
                        ? '성인입니다'
                        : '만 19세 미만은 가입할 수 없습니다',
                    style: TextStyle(
                      color: !isBirthValid
                          ? Colors.redAccent
                          : isAdultValid
                          ? Colors.lightGreenAccent
                          : Colors.redAccent,
                      fontSize: 13,
                    ),
                  ),
                ),
              SizedBox(height: 24),
              _buildTextField(
                '주소',
                Icons.home,
                _addressController,
                inputType: TextInputType.text,
              ),
              ElevatedButton.icon(
                onPressed: _searchAddress,
                icon: const Icon(Icons.search),
                label: const Text('주소 검색'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                '상세주소 (동/호수 등)',
                Icons.location_on,
                _addressDetailController,
                inputType: TextInputType.text,
              ),
              const SizedBox(height: 24),
              buildTermsSection(),
              SizedBox(height: 24),
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
      ),
    );
  }
}
