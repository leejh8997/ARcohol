import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BuyProductViewPage extends StatefulWidget {
  final Map<String, dynamic> orderData;
  const BuyProductViewPage({super.key, required this.orderData});

  @override
  State<BuyProductViewPage> createState() => _BuyProductViewPageState();
}

class _BuyProductViewPageState extends State<BuyProductViewPage> {
  final Color primaryColor = const Color(0xFFE94E2B);
  final Color darkBg = const Color(0xFF1F1F1F);
  final Color midBg = const Color(0xFF333333);
  final Color accent = const Color(0xFFBEB08B);

  bool showGuide = false;

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
    final data = widget.orderData;
    final List<dynamic> items = data['items'];
    final Map<String, dynamic> item = items.first;
    final Map<String, dynamic> delivery = data['delivery'];
    final Map<String, dynamic> payment = data['payment'];
    final date = (payment['paidAt'] as Timestamp).toDate();
    final dateStr = DateFormat('yyyy.MM.dd - a hh:mm', 'ko_KR').format(date);
    final String guideText = '''
      • 배송 안내  
      결제 완료 후 평균 1~3일 이내 출고됩니다.  
      주말 및 공휴일 주문은 다음 영업일에 순차 발송됩니다.  
      도서산간/제주 지역은 추가 배송비가 발생할 수 있습니다.
      
      • 교환 및 반품 안내  
      상품 수령 후 7일 이내 교환/반품 신청이 가능합니다.  
      상품 불량 및 오배송의 경우, 배송비는 판매자가 부담합니다.  
      단순 변심에 의한 교환/반품 시, 왕복 배송비는 고객님 부담입니다.  
      교환/반품이 어려운 경우:  
       - 포장이 훼손된 경우  
       - 사용 또는 세탁한 경우  
       - 시간이 경과되어 상품 가치가 상실된 경우
      
      • 문의 안내  
      상품 및 배송 관련 문의는 고객센터를 통해 접수해주세요.  
      보다 빠른 처리를 위해 주문번호를 함께 남겨주세요.
      ''';

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        leading: BackButton(color: Colors.white),
        title: const Text('주문상세', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('주문번호 ${data['orderId']}', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('결제 날짜: $dateStr', style: const TextStyle(color: Colors.white60)),
                const SizedBox(height: 12),
                const Divider(color: Colors.white24),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showGuide = !showGuide;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('배송 / 교환 / 반품 안내', style: TextStyle(color: Colors.white)),
                      Icon(showGuide ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.white)
                    ],
                  ),
                ),
                if (showGuide)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: midBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      guideText,
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                const Divider(color: Colors.white38, thickness: 1.2),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: midBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(data['userName'] ?? '고객명', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Text(mapStatus(delivery['status']), style: TextStyle(color: primaryColor)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${data['address']} ${data['addressDetail']}', style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item['imgUrl'],
                              width: 90,
                              height: 90,
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
                                      child: Text(payment['method'] == 'card' ? '카드결제' : payment['method'], style: TextStyle(color: primaryColor, fontSize: 12)),
                                    ),
                                    Text('${item['quantity']}개', style: const TextStyle(color: Colors.white))
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(item['pName'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('용량: ${item['capacity']}, 사이즈: ${item['size']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                const SizedBox(height: 4),
                                if (item['memo'] != null)
                                  Text(item['memo'], style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: primaryColor),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text('총 주문금액: ${data['totalPrice']}원', style: TextStyle(color: primaryColor)),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {},
              child: const Text('주문 취소', style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}