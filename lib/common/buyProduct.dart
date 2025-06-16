import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BuyProductPage extends StatefulWidget {
  const BuyProductPage({Key? key}) : super(key: key);

  @override
  State<BuyProductPage> createState() => _BuyProductPageState();
}

class _BuyProductPageState extends State<BuyProductPage> {
  final Color primaryColor = const Color(0xFFE94E2B);
  final Color darkBg = const Color(0xFF1F1F1F);
  final Color midBg = const Color(0xFF333333);
  final Color accent = const Color(0xFFBEB08B);

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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text('주문상품', style: TextStyle(color: Colors.white, fontSize: 18)),
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
                    final items = List.from(data['items'] as List);
                    final item = items.first as Map<String, dynamic>;
                    final payment = Map.from(data['payment'] as Map);
                    final delivery = Map.from(data['delivery'] as Map);
                    final date = (data['o_createdAt'] as Timestamp).toDate();
                    final dateStr = '${date.year}.${date.month.toString().padLeft(2,'0')}.${date.day.toString().padLeft(2,'0')}';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
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
                              Text(dateStr, style: const TextStyle(color: Colors.white)),
                              const SizedBox(width: 8),
                              Text(
                                mapStatus(delivery['status']),
                                style: TextStyle(color: accent, fontSize: 12),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                                onPressed: () {
                                  // 상세페이지로 네비게이션
                                },
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white30),
                          const SizedBox(height: 8),
                          // 주소
                          Text(
                            '${data['address']}, ${data['addressDetail']}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 12),
                          // 상품 정보
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                item['imgUrl'],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 결제수단
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: darkBg,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        payment['method'] == 'card' ? '카드결제' : payment['method'],
                                        style: TextStyle(color: primaryColor, fontSize: 12),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item['pName'],
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    if (data['memo'] != null)
                                      Text(
                                        data['memo'],
                                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                                      ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('${item['quantity']}개', style: const TextStyle(color: Colors.white)),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: primaryColor),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '총 주문금액: ${data['totalPrice']}원',
                                      style: TextStyle(color: primaryColor, fontSize: 12),
                                    ),
                                  ),
                                ],
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