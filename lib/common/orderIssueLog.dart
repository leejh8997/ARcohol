import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderIssueLogPage extends StatefulWidget {
  const OrderIssueLogPage({super.key});

  @override
  State<OrderIssueLogPage> createState() => _OrderIssueLogPageState();
}

class _OrderIssueLogPageState extends State<OrderIssueLogPage>
    with SingleTickerProviderStateMixin {
  final Color primaryColor = const Color(0xFFE94E2B);
  final Color darkBg = const Color(0xFF1F1F1F);
  final Color midBg = const Color(0xFF333333);
  final Color accent = const Color(0xFFBEB08B);

  late TabController _tabController;
  List<String> tabs = ['취소', '교환', '반품'];
  String currentStatus = 'cancelled';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          currentStatus = ['cancelled', 'exchange', 'return'][_tabController.index];
        });
      }
    });
  }

  String formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('yyyy.MM.dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        leading: BackButton(color: Colors.white),
        title: const Text('취소 반품 교환내역', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Container(
            color: midBg,
            child: TabBar(
              controller: _tabController,
              indicatorColor: primaryColor,
              labelColor: primaryColor,
              unselectedLabelColor: Colors.white54,
              tabs: tabs.map((tab) => Tab(text: tab)).toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('userId', isEqualTo: userId)
                  .where('status', isEqualTo: currentStatus)
                  .orderBy('issue_createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final orders = snapshot.data!.docs;
                if (orders.isEmpty) {
                  return const Center(
                    child: Text('내역이 없습니다', style: TextStyle(color: Colors.white70)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final data = orders[index].data() as Map<String, dynamic>;
                    final item = (data['items'] as List).first;
                    final productName = item['pName'] ?? '-';
                    final imgUrl = item['imgUrl'] ?? '';
                    final quantity = item['quantity'] ?? 1;
                    final reason = data['reason'] ?? '-';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
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
                              Text(formatDate(data['o_createdAt']),
                                  style: const TextStyle(color: Colors.white)),
                              Text(
                                currentStatus == 'cancelled'
                                    ? '취소 완료'
                                    : currentStatus == 'exchange'
                                    ? '교환 완료'
                                    : '반품 완료',
                                style: TextStyle(color: primaryColor),
                              ),
                              Text(formatDate(data['issue_createdAt']),
                                  style: const TextStyle(color: Colors.white70)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('${data['address']} ${data['addressDetail']}',
                              style: const TextStyle(color: Colors.white70)),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imgUrl,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(productName,
                                        style: const TextStyle(
                                            color: Colors.white, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '용량: ${item['capacity'] ?? '-'}, 사이즈: ${item['size'] ?? '-'}',
                                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('사유: $reason',
                                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(color: primaryColor),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '총 주문금액: ${data['totalPrice']}원',
                                style: TextStyle(color: primaryColor),
                              ),
                            ),
                          )
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