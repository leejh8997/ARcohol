import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductOrderPage extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductOrderPage({super.key, required this.product});

  @override
  State<ProductOrderPage> createState() => _ProductOrderPageState();
}

class _ProductOrderPageState extends State<ProductOrderPage> {
  final Color primaryColor = const Color(0xFFE94E2B);
  final Color darkBg = const Color(0xFF1F1F1F);
  final Color midBg = const Color(0xFF333333);
  final Color accent = const Color(0xFFBEB08B);

  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;

  String selectedMemo = '선택 안함';
  final List<String> memoOptions = [
    '선택 안함',
    '직접 입력하기',
    '문 앞에 놔주세요',
    '부재 시 택배 박스에요',
    '배송 전 미리 연락해주세요'
  ];
  final TextEditingController customMemoController = TextEditingController();

  int quantity = 1;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (doc.exists) {
        setState(() {
          userData = doc.data();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final totalPrice = product['price'] * quantity;

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        title: const Text('결제', style: TextStyle(color: Colors.white)),
        leading: BackButton(color: Colors.white),
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 배송지 박스
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: midBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(userData!['name'] ?? '',
                          style: TextStyle(color: accent, fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {}, // 변경 기능 미구현
                        child: const Text('변경', style: TextStyle(color: Colors.white)),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(userData!['phone'] ?? '', style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 2),
                  Text('${userData!['address'] ?? ''}, ${userData!['addressDetail'] ?? ''}',
                      style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 12),

                  // 배송 메모 선택
                  DropdownButtonFormField<String>(
                    value: selectedMemo,
                    dropdownColor: midBg,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: darkBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: accent),
                      ),
                    ),
                    iconEnabledColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    items: memoOptions
                        .map((label) => DropdownMenuItem(
                      value: label,
                      child: Text(label, style: const TextStyle(color: Colors.white)),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMemo = value!;
                      });
                    },
                  ),
                  if (selectedMemo == '직접 입력하기') ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: customMemoController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: '여기에 입력해주세요',
                        hintStyle: const TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: darkBg,
                      ),
                    )
                  ]
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 주문 상품
            Text('주문상품', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: midBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(product['imgUrl'], width: 80, height: 80, fit: BoxFit.cover),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(product['name'] ?? '',
                                      style: const TextStyle(color: Colors.white)),
                                ),
                                Text('$quantity개', style: const TextStyle(color: Colors.white)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(product['category'] ?? '',
                                style: const TextStyle(color: Colors.white70)),
                            const SizedBox(height: 4),
                            Text(product['description'] ?? '',
                                style: const TextStyle(color: Colors.white70)),
                            const SizedBox(height: 4),
                            Text('용량: ${product['capacity']}, 사이즈: ${product['size']}',
                                style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: primaryColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('총 주문금액: $totalPrice원',
                          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 버튼
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryColor),
                    ),
                    child: Text('취소', style: TextStyle(color: primaryColor)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // 결제 처리 로직
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                    child: const Text('결제하기'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}