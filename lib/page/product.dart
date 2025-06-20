import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../common/appBar.dart';
import '../common/bottomBar.dart';
import '../page/productView.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isGrid = false;
  List<DocumentSnapshot> productList = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final snap = await FirebaseFirestore.instance.collection('product').get();
    setState(() {
      productList = snap.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
      drawer: const CustomDrawer(),
      backgroundColor: const Color(0xFF1F1F1F),
      bottomNavigationBar: const CustomBottomBar(currentIndex: 1),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔶 상단 타이틀 + 토글 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('판매', style: TextStyle(color: Color(0xFFBEB08B), fontSize: 20, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.view_list, color: !isGrid ? Colors.amber : const Color(0xFFBEB08B)),
                      onPressed: () => setState(() => isGrid = false),
                    ),
                    IconButton(
                      icon: Icon(Icons.grid_view, color: isGrid ? Colors.amber : const Color(0xFFBEB08B)),
                      onPressed: () => setState(() => isGrid = true),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 🔶 리스트 or 그리드 영역
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: isGrid ? _buildGridView() : _buildListView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      itemCount: productList.length,
      separatorBuilder: (_, __) => const Divider(color: Colors.grey),
      itemBuilder: (context, index) {
        final doc = productList[index];
        final data = productList[index].data() as Map<String, dynamic>;
        return ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductViewPage(productId: doc.id),
              ),
            );
          },
          leading: Image.network(data['imgUrl'], width: 50, height: 50, fit: BoxFit.cover),
          title: Text(data['name'], style: const TextStyle(color: Colors.white)),
          subtitle: Text('${_formatPrice(data['price'])}원', style: const TextStyle(color: Color(0xFFE94E2B))),
        );
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      itemCount: productList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 3 / 4,
      ),
      itemBuilder: (context, index) {
        final doc = productList[index];
        final data = productList[index].data() as Map<String, dynamic>;
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductViewPage(productId: doc.id),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black45,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    data['imgUrl'],
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('${_formatPrice(data['price'])}원', style: const TextStyle(color: Color(0xFFE94E2B))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatPrice(dynamic price) {
    final intPrice = price is int ? price : int.tryParse(price.toString()) ?? 0;
    return intPrice.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
  }
}