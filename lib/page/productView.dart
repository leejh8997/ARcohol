// 🔁 문의 -> 리뷰 기능으로 변경한 ProductViewPage + 컬러 스킴 적용

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductViewPage extends StatefulWidget {
  final String productId;
  const ProductViewPage({super.key, required this.productId});

  @override
  State<ProductViewPage> createState() => _ProductViewPageState();
}

class _ProductViewPageState extends State<ProductViewPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? productData;
  List<Map<String, dynamic>> reviewList = [];
  int quantity = 1;

  bool hasPurchased = false;
  bool hasWrittenReview = false;
  String? myUid = FirebaseAuth.instance.currentUser?.uid;

  final Color primaryColor = const Color(0xFFE94E2B);
  final Color darkBg = const Color(0xFF1F1F1F);
  final Color midBg = const Color(0xFF333333);
  final Color accent = const Color(0xFFBEB08B);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchProduct();
    fetchReviews();
    checkPurchaseStatus();
  }

  Future<void> fetchProduct() async {
    final doc = await FirebaseFirestore.instance.collection('product').doc(widget.productId).get();
    if (doc.exists) {
      setState(() {
        productData = doc.data()!;
      });
    }
  }

  Future<void> checkPurchaseStatus() async {
    if (myUid == null) return;

    final orders = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: myUid)
        .get();

    for (final order in orders.docs) {
      final items = List.from(order['items']);
      if (items.any((e) => e['itemId'] == widget.productId)) {
        hasPurchased = true;
        break;
      }
    }

    final existingReview = await FirebaseFirestore.instance
        .collection('review')
        .where('productId', isEqualTo: widget.productId)
        .where('writer', isEqualTo: myUid)
        .get();

    setState(() {
      hasWrittenReview = existingReview.docs.isNotEmpty;
    });
  }

  Future<void> fetchReviews() async {

    try {
      final snap = await FirebaseFirestore.instance
          .collection('review')
          .where('productId', isEqualTo: widget.productId)
          .orderBy('createdAt', descending: true)
          .get();

      final List<Map<String, dynamic>> loadedReviews = [];

      for (final doc in snap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        final writerId = data['writer'];
        final userSnap = await FirebaseFirestore.instance.collection('users').doc(writerId).get();
        data['writerName'] = userSnap.exists ? userSnap['name'] : '알 수 없음';
        loadedReviews.add(data);
      }

      setState(() {
        reviewList = loadedReviews;
      });
    } catch (e) {
      print('❌ 리뷰 불러오기 실패: $e');
    }
  }

  void _showReviewDialog({Map<String, dynamic>? review}) {
    final titleCtrl = TextEditingController(text: review?['title'] ?? '');
    final contentCtrl = TextEditingController(text: review?['content'] ?? '');
    int selectedRating = review?['rating'] ?? 0;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: midBg,
        title: const Text('리뷰 작성', style: TextStyle(color: Colors.white)),
        content: StatefulBuilder(
          builder: (_, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: '제목',
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentCtrl,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: '내용',
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(5, (i) => IconButton(
                  onPressed: () => setState(() => selectedRating = i + 1),
                  icon: Icon(i < selectedRating ? Icons.star : Icons.star_border, color: primaryColor),
                )),
              )
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () async {
              print("리뷰 ID: ${review?['id']}");
              final title = titleCtrl.text.trim();
              final content = contentCtrl.text.trim();
              final writer = myUid;
              if (title.isEmpty || content.isEmpty || selectedRating == 0 || writer == null) return;

              if (review == null) {
                await FirebaseFirestore.instance.collection('review').add({
                  'productId': widget.productId,
                  'title': title,
                  'content': content,
                  'rating': selectedRating,
                  'writer': writer,
                  'createdAt': Timestamp.now(),
                });
              } else {
                print("🔍 ------------------------리뷰 수정 ID: ${review?['id']}");
                await FirebaseFirestore.instance.collection('review').doc(review['id']).update({
                  'title': title,
                  'content': content,
                  'rating': selectedRating,
                });
              }

              Navigator.pop(context);
              fetchReviews();
              checkPurchaseStatus();
            },
            child: const Text('등록'),
          ),
        ],
      ),
    );
  }

  void _showPurchaseSheet() {
    if (productData == null) return;
    final price = productData!['price'] ?? 0;
    showModalBottomSheet(
      context: context,
      backgroundColor: midBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(productData!['name'], style: const TextStyle(color: Colors.white)),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.white),
                        onPressed: () {
                          if (quantity > 1) setSheetState(() => quantity--);
                        },
                      ),
                      Text('$quantity', style: const TextStyle(color: Colors.white)),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () => setSheetState(() => quantity++),
                      ),
                      const Spacer(),
                      // Text('10%', style: TextStyle(color: primaryColor)),
                      // const SizedBox(width: 6),
                      Text('${_formatPrice(price)}원', style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                  const Divider(color: Colors.grey),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('총 $quantity개 상품', style: const TextStyle(color: Colors.white)),
                      Text('${_formatPrice(quantity * price )}원', style: TextStyle(color: primaryColor)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,           // 텍스트 색상
                            side: BorderSide(color: primaryColor),   // 테두리 색상
                          ),
                          child: const Text('장바구니'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                          child: const Text('바로 구매'),
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
    );
  }

  String maskName(String name) {
    if (name.length <= 2) return name;
    return '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}';
  }

  String _formatPrice(dynamic price) {
    final intPrice = price is int ? price : int.tryParse(price.toString()) ?? 0;
    return intPrice.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
  }

  @override
  Widget build(BuildContext context) {
    if (productData == null) {
      return Scaffold(
        backgroundColor: darkBg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final data = productData!;

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: midBg,
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              data['name'],
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: accent),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                data['imgUrl'],
                height: 320,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['name'], style: const TextStyle(fontSize: 18, color: Colors.white)),
                const SizedBox(height: 4),
                Text('${_formatPrice(data['price'])}원', style: TextStyle(color: primaryColor)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '상품 정보'),
              Tab(text: '리뷰'),
            ],
            labelColor: primaryColor,
            unselectedLabelColor: Colors.white,
            indicatorColor: primaryColor,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: midBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('상품명: ${data['name']}', style: const TextStyle(color: Colors.white)),
                        Text('카테고리: ${data['category']}', style: const TextStyle(color: Colors.white)),
                        Text('설명: ${data['description']}', style: const TextStyle(color: Colors.white)),
                        Text('용량: ${data['capacity']}', style: const TextStyle(color: Colors.white)),
                        Text('크기: ${data['size']}', style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    if (hasPurchased && !hasWrittenReview)
                      OutlinedButton(
                        onPressed: () => _showReviewDialog(),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: BorderSide(color: primaryColor)),
                        child: const Text('리뷰 쓰기'),
                      ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: reviewList.length,
                        itemBuilder: (_, i) {
                          final r = reviewList[i];
                          final isMine = r['writer'] == myUid;
                          return Container(
                            margin: const EdgeInsets.all(10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: midBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(r['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    Text(DateFormat('yyyy.MM.dd').format(r['createdAt'].toDate()), style: const TextStyle(color: Colors.grey))
                                  ],
                                ),
                                Text(r['writerName'], style: const TextStyle(color: Colors.grey)),
                                Row(
                                  children: List.generate(5, (i) => Icon(
                                    i < (r['rating'] ?? 0) ? Icons.star : Icons.star_border,
                                    color: primaryColor, size: 18,
                                  )),
                                ),
                                const SizedBox(height: 6),
                                Text(r['content'], style: const TextStyle(color: Colors.white)),
                                if (isMine)
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextButton(
                                          onPressed: () => _showReviewDialog(review: r),
                                          child: const Text('수정', style: TextStyle(color: Colors.orange)),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await FirebaseFirestore.instance.collection('review').doc(r['id']).delete();
                                            fetchReviews();
                                            checkPurchaseStatus();
                                          },
                                          child: const Text('삭제', style: TextStyle(color: Colors.redAccent)),
                                        )
                                      ],
                                    ),
                                  )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: midBg,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showPurchaseSheet(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,           // 텍스트 색상
                  side: BorderSide(color: primaryColor),   // 테두리 색상
                ),
                child: const Text('장바구니'),
              ),
            ),
            SizedBox(width: 16,),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showPurchaseSheet(),
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                child: const Text('바로 구매'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}