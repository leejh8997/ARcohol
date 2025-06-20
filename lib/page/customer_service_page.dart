import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerServicePage extends StatelessWidget {
  const CustomerServicePage({super.key});

  Future<void> _callPhoneNumber() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '15771234');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw '전화 연결에 실패했습니다.';
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF1F1F1F);
    const Color orange = Color(0xFFE94E2B);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("고객센터"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 🔹 상단 고정 텍스트
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 140, 20, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "문의 사항이 있으신가요?",
                style: TextStyle(
                  color: orange,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // 🔹 중간 공간 (Fixed height로 적당히 밀어냄)
          const SizedBox(height: 40),

          // 🔹 안내 텍스트들
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "무엇을 도와드릴까요?\n앱 이용 중 궁금한 점이 있다면,\n",
                          style: TextStyle(color: Colors.white, height: 1.5),
                        ),
                        TextSpan(
                          text: "1577-1234",
                          style: TextStyle(
                            color: orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: " 고객센터로 연락주세요.\n항상 최선을 다해 안내해드릴게요.",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "고객센터 문의 전 유의사항",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "문의 시 정확한 정보를 전달해주시면 보다 신속하고 빠른 안내가 가능합니다.\n"
                      "서비스 운영 시간 외에는 전화 연결이 어려울 수 있으며, 게시글 남겨주시면 빠르게 답변드릴 수 있도록 하겠습니다.",
                  style: TextStyle(color: Colors.white70, height: 1.4),
                ),
              ],
            ),
          ),

          // 🔹 여유 공간 (본문과 버튼 사이 띄우기)
          const SizedBox(height: 80),

          // 🔹 하단 버튼
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _callPhoneNumber,
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '전화 걸기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
