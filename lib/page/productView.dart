// 🔁 문의 -> 리뷰 기능으로 변경한 ProductViewPage + 컬러 스킴 적용 (#BEB08B, #333333, #1F1F1F, #E94E2B)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProductViewPage extends StatefulWidget {
  final String productId;
  const ProductViewPage({super.key, required this.productId});

  @override
  State<ProductViewPage> createState() => _ProductViewPageState();
}

class _ProductViewPageState extends State<ProductViewPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? productData;
  List<DocumentSnapshot> reviewList = [];
  int quantity = 1;

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
  }

  Future<void> fetchProduct() async {
    final doc = await FirebaseFirestore.instance.collection('product').doc(widget.productId).get();
    if (doc.exists) {
      setState(() {
        productData = doc.data()!;
      });
    }
  }

  Future<void> fetchReviews() async {
    final snap = await FirebaseFirestore.instance
        .collection('review')
        .where('productId', isEqualTo: widget.productId)
        .orderBy('createdAt', descending: true)
        .get();
    setState(() {
      reviewList = snap.docs;
    });
  }

  void _showReviewDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: midBg,
        title: const Text('리뷰 작성', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '리뷰를 입력해주세요',
                hintStyle: const TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryColor)),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '상품 리뷰 작성 시 유의사항\n\n리뷰는 구매자에 한해 작성 가능하며 비방/욕설/개인정보 포함 시 삭제될 수 있습니다.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () async {
              final content = controller.text.trim();
              if (content.isEmpty) return;
              await FirebaseFirestore.instance.collection('review').add({
                'productId': widget.productId,
                'title': content,
                'writer': 'user21***',
                'createdAt': Timestamp.now(),
              });
              fetchReviews();
              Navigator.pop(context);
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
                  Center(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,           // 텍스트 색상
                        side: BorderSide(color: primaryColor),   // 테두리 색상
                      ),
                      child: const Text('옵션 선택하기'),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: _showReviewDialog,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,           // 텍스트 색상
                        side: BorderSide(color: primaryColor),   // 테두리 색상
                      ),
                      child: const Text('리뷰 쓰기'),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: reviewList.length,
                        itemBuilder: (context, index) {
                          final review = reviewList[index].data() as Map<String, dynamic>;
                          final maskedWriter = maskName(review['writer']);
                          final date = DateFormat('yyyy.MM.dd').format(review['createdAt'].toDate());
                          return ExpansionTile(
                            collapsedBackgroundColor: midBg,
                            backgroundColor: midBg,
                            title: Text(review['title'], style: const TextStyle(color: Colors.white)),
                            subtitle: Text('$maskedWriter  $date', style: const TextStyle(color: Colors.grey)),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(review['title'], style: const TextStyle(color: Colors.white)),
                              )
                            ],
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
    );
  }
}