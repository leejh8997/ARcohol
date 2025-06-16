import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'buyProductView.dart';
// 동일 import 유지

class BuyProductPage extends StatefulWidget {
  const BuyProductPage({Key? key}) : super(key: key);

  @override
  State<BuyProductPage> createState() => _BuyProductPageState();
}

class _BuyProductPageState extends State<BuyProductPage> {
  final Color primaryColor = const Color(0xFFE94E2B); // 주황
  final Color darkBg = const Color(0xFF1F1F1F); // 전체 배경
  final Color midBg = const Color(0xFF333333); // 카드 배경
  final Color accent = const Color(0xFFBEB08B); // 강조 텍스트

  final user = FirebaseAuth.instance.currentUser;

  String mapStatus(String status) {
    switch (status) {
      case 'preparing': return '배송 준비 중';
      case 'shipped': return '배송 중';
      case 'delivered': return '배송 완료';
      case 'cancelled': return '배송 취소';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        leading: BackButton(color: Colors.white),
        title: const Text('주문내역', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text('주문상품',
                style: TextStyle(color: primaryColor, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('userId', isEqualTo: user?.uid)
                  .orderBy('o_createdAt', descending: true)
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('주문 내역이 없습니다.', style: TextStyle(color: Colors.white54)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    final List<dynamic> items = data['items'];
                    final Map<String, dynamic> item = items.first as Map<String, dynamic>;
                    final payment = Map<String, dynamic>.from(data['payment']);
                    final delivery = Map<String, dynamic>.from(data['delivery']);
                    final date = (data['o_createdAt'] as Timestamp).toDate();
                    final dateStr = '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16), // ✅ 더 넓은 padding
                      decoration: BoxDecoration(
                        color: midBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 날짜 · 배송 상태 · 상세 버튼
                          Row(
                            children: [
                              Text(
                                dateStr,
                                style: TextStyle(color: accent, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                mapStatus(delivery['status']),
                                style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BuyProductViewPage(orderData: data), // ← 전달할 주문 데이터
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white30),

                          Text(
                            '${data['address']}, ${data['addressDetail']}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 12),
                          // 상품 정보
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item['imgUrl'],
                                  width: 120,
                                  height: 130,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: primaryColor),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            payment['method'] == 'card' ? '카드결제' : payment['method'],
                                            style: TextStyle(
                                              color: primaryColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Text('${item['quantity']}개',
                                            style: const TextStyle(color: Colors.white, fontSize: 14)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item['pName'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (data['memo'] != null)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Text(
                                          data['memo'],
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: primaryColor),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '총 주문금액: ${data['totalPrice']}원',
                                          style: TextStyle(
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}