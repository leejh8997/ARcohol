import 'package:firebase_auth/firebase_auth.dart';
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
  Map<String, dynamic>? productInfo;
  String? userName;

  final Color primaryColor = const Color(0xFFE94E2B);
  final Color darkBg = const Color(0xFF1F1F1F);
  final Color midBg = const Color(0xFF333333);
  final Color accent = const Color(0xFFBEB08B);

  bool showGuide = false;
  bool hasReview = false;

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
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final itemId = widget.orderData['items'].first['itemId'];
      final userId = widget.orderData['userId'];

      await checkReviewStatus(itemId);
      await fetchProductInfo(itemId);
      await fetchUserName(userId);
    });
  }

  Future<void> checkReviewStatus(String itemId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final reviewSnap = await FirebaseFirestore.instance
        .collection('review')
        .where('productId', isEqualTo: itemId)
        .where('writer', isEqualTo: user.uid)
        .limit(1)
        .get();

    setState(() {
      hasReview = reviewSnap.docs.isNotEmpty;
    });
  }

  Future<void> fetchProductInfo(String itemId) async {
    final productSnap = await FirebaseFirestore.instance
        .collection('product')
        .doc(itemId)
        .get();

    if (productSnap.exists) {
      setState(() {
        productInfo = productSnap.data();
      });
    }
  }

  Future<void> fetchUserName(String userId) async {
    final userSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (userSnap.exists) {
      setState(() {
        userName = userSnap.data()!['name'] ?? '고객';
      });
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

    final List<String> cancelReasons = [
      '단순 변심으로 인한 취소',
      '상품 문제(색상/사이즈 등) 잘못 선택',
      '배송 지연으로 인한 취소',
      '중복 주문',
      '결제 오류 또는 결제 수단 변경 희망',
      '직접 입력',
    ];

    bool isDelivered = delivery['status'] == 'delivered';
    // bool isCancelable = delivery['status'] == 'preparing' || delivery['status'] == 'shipped';

    void _showReviewDialog({Map<String, dynamic>? existingReview}) {
      final titleCtrl = TextEditingController(text: existingReview?['title'] ?? '');
      final contentCtrl = TextEditingController(text: existingReview?['content'] ?? '');
      int selectedRating = existingReview?['rating'] ?? 0;
      final user = FirebaseAuth.instance.currentUser;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: midBg,
          title: Text(existingReview != null ? '리뷰 수정' : '리뷰 작성', style: const TextStyle(color: Colors.white)),
          content: StatefulBuilder(
            builder: (_, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: '제목',
                    labelStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: '내용',
                    labelStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(5, (i) => IconButton(
                    onPressed: () => setState(() => selectedRating = i + 1),
                    icon: Icon(
                      i < selectedRating ? Icons.star : Icons.star_border,
                      color: primaryColor,
                    ),
                  )),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: () async {
                final title = titleCtrl.text.trim();
                final content = contentCtrl.text.trim();
                if (title.isEmpty || content.isEmpty || selectedRating == 0 || user == null) return;

                final reviewRef = FirebaseFirestore.instance.collection('review');
                if (existingReview == null) {
                  await reviewRef.add({
                    'productId': item['itemId'],
                    'writer': user.uid,
                    'title': title,
                    'content': content,
                    'rating': selectedRating,
                    'createdAt': Timestamp.now(),
                  });
                } else {
                  await reviewRef.doc(existingReview['id']).update({
                    'title': title,
                    'content': content,
                    'rating': selectedRating,
                  });
                }

                await checkReviewStatus(item['itemId']);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(existingReview == null ? '리뷰가 등록되었습니다' : '리뷰가 수정되었습니다')),
                );
                setState(() {});
              },
              child: const Text('등록'),
            ),
          ],
        ),
      );
    }

    void _showCancelReasonDialog(String orderId) {
      String selectedReason = '';
      bool isDropdownExpanded = false;
      bool isCustomInput = false;
      final TextEditingController customReasonController = TextEditingController();
      final cancelReasons = [
        '단순 변심으로 인한 취소',
        '상품 문제(색상/사이즈 등) 잘못 선택',
        '배송 지연으로 인한 취소',
        '중복 주문',
        '결제 오류 또는 결제 수단 변경 희망',
        '직접 입력',
      ];

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              backgroundColor: midBg,
              contentPadding: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('주문을 취소 하시겠습니까?', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => isDropdownExpanded = !isDropdownExpanded),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: darkBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              selectedReason.isEmpty ? '취소 사유를 선택해주세요' : selectedReason,
                              style: const TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            isDropdownExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ✅ 애니메이션은 사유 목록만
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 200),
                    firstChild: const SizedBox.shrink(),
                    secondChild: Column(
                      children: cancelReasons.map((reason) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedReason = reason;
                              isDropdownExpanded = false;
                              isCustomInput = reason == '직접 입력';
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            alignment: Alignment.centerLeft,
                            color: darkBg,
                            child: Text(reason, style: const TextStyle(color: Colors.white70)),
                          ),
                        );
                      }).toList(),
                    ),
                    crossFadeState:
                    isDropdownExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  ),

                  // ✅ 직접 입력 텍스트 필드는 바로 보여줌
                  if (isCustomInput)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: TextField(
                        controller: customReasonController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: '취소 사유를 입력해주세요',
                          hintStyle: const TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('닫기', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  onPressed: () async {
                    final reason = isCustomInput
                        ? customReasonController.text.trim()
                        : selectedReason;
                    if (reason.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('취소 사유를 선택하거나 입력해주세요')),
                      );
                      return;
                    }

                    await FirebaseFirestore.instance
                        .collection('orders')
                        .doc(orderId)
                        .update({
                      'status': 'cancelled',
                      'reason': reason,
                    });

                    if (mounted) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('주문이 취소되었습니다')),
                      );
                    }
                  },
                  child: const Text('취소하기'),
                ),
              ],
            ),
          );
        },
      );
    }

    void _showNotCancelableDialog() {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: midBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '배송 중인 상품은 취소가 불가능 합니다.\n고객센터를 통해 문의해주세요.\n1577-1234',
                style: TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('돌아가기', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    void _showExchangeReturnDialog(String orderId) {
      String selectedReason = '';
      bool isDropdownExpanded = false;
      bool isCustomInput = false;
      final TextEditingController customReasonController = TextEditingController();

      final reasons = [
        '상품이 불량이거나 하자가 있음',
        '주문한 상품과 다른 상품이 도착함 (오배송)',
        '사이즈 / 색상 등이 맞지 않음',
        '단순 변심 (마음에 들지 않음)',
        '배송 중 상품이 파손됨',
        '직접 입력',
      ];

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              backgroundColor: midBg,
              contentPadding: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('제품에 문제가 있나요?', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => isDropdownExpanded = !isDropdownExpanded),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: darkBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              selectedReason.isEmpty ? '반품 / 교환 사유를 선택해주세요' : selectedReason,
                              style: const TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            isDropdownExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isDropdownExpanded)
                    Column(
                      children: reasons.map((reason) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedReason = reason;
                              isDropdownExpanded = false;
                              isCustomInput = reason == '직접 입력';
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            alignment: Alignment.centerLeft,
                            color: darkBg,
                            child: Text(reason, style: const TextStyle(color: Colors.white70)),
                          ),
                        );
                      }).toList(),
                    ),
                  if (isCustomInput)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: TextField(
                        controller: customReasonController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: '반품 / 교환 사유를 입력해주세요',
                          hintStyle: const TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('닫기', style: TextStyle(color: Colors.white)),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryColor),
                    foregroundColor: primaryColor,
                  ),
                  onPressed: () async {
                    final reason = isCustomInput ? customReasonController.text.trim() : selectedReason;
                    if (reason.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('반품 사유를 선택하거나 입력해주세요')),
                      );
                      return;
                    }

                    await FirebaseFirestore.instance
                        .collection('orders')
                        .doc(orderId)
                        .update({
                      'status': 'return',
                      'reason': reason,
                    });

                    if (mounted) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('반품 요청이 접수되었습니다')),
                      );
                    }
                  },
                  child: const Text('반품하기'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  onPressed: () async {
                    final reason = isCustomInput ? customReasonController.text.trim() : selectedReason;
                    if (reason.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('교환 사유를 선택하거나 입력해주세요')),
                      );
                      return;
                    }

                    await FirebaseFirestore.instance
                        .collection('orders')
                        .doc(orderId)
                        .update({
                      'status': 'exchange',
                      'reason': reason,
                    });

                    if (mounted) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('교환 요청이 접수되었습니다')),
                      );
                    }
                  },
                  child: const Text('교환하기'),
                ),
              ],
            ),
          );
        },
      );
    }

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
                          Text(userName ?? '고객명', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                                      child: Text(payment['method'] == 'card' ? '카드결제' : payment['method'], style: TextStyle(color: primaryColor, fontSize: 12)),
                                    ),
                                    Text('${item['quantity']}개', style: const TextStyle(color: Colors.white))
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(item['pName'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('용량: ${productInfo?['capacity'] ?? '-'}, 사이즈: ${productInfo?['size'] ?? '-'}',
                                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20,),
                      if (isDelivered)
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            margin: const EdgeInsets.only(top: 16),
                            width: 120, // 버튼 크기 고정 (선택)
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: primaryColor),
                                foregroundColor: primaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () async {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user == null) return;

                                final reviewSnap = await FirebaseFirestore.instance
                                    .collection('review')
                                    .where('productId', isEqualTo: item['itemId'])
                                    .where('writer', isEqualTo: user.uid)
                                    .limit(1)
                                    .get();

                                if (reviewSnap.docs.isNotEmpty) {
                                  final existingReview = reviewSnap.docs.first.data();
                                  existingReview['id'] = reviewSnap.docs.first.id;
                                  _showReviewDialog(existingReview: existingReview);
                                } else {
                                  _showReviewDialog();
                                }
                              },
                              child: Text(hasReview ? '리뷰 수정' : '리뷰 쓰기'),
                            ),
                          ),
                        ),
                      SizedBox(height: 20,),
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
              onPressed: () {
                if (delivery['status'] == 'preparing') {
                  _showCancelReasonDialog(data['orderId']);  // 🔽 직접 사유 선택
                } else if (delivery['status'] == 'shipped') {
                  _showNotCancelableDialog(); // 🔒 안내만 띄우기
                } else if (isDelivered) {
                  _showExchangeReturnDialog(data['orderId']);
                }
              },
              child: Text(
                isDelivered ? '교환 / 반품' : '주문 취소',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}