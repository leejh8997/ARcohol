import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'bottomBar.dart';
import '../page/productView.dart';
import 'myPage.dart';

class WishListPage extends StatefulWidget {
  const WishListPage({super.key});

  @override
  State<WishListPage> createState() => _WishListPageState();
}

class _WishListPageState extends State<WishListPage> {
  final user = FirebaseAuth.instance.currentUser;

  final Color primaryColor = const Color(0xFFE94E2B);
  final Color darkBg = const Color(0xFF1F1F1F);
  final Color midBg = const Color(0xFF333333);
  final Color accent = const Color(0xFFBEB08B);

  List<String> selectedProductIds = [];
  bool selectAll = false;

  Future<void> updateCart(List<Map<String, dynamic>> newCart) async {
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'cartitem': newCart,
    });
  }

  Future<void> deleteSelectedItems(List<Map<String, dynamic>> cart) async {
    final updated = cart.where((item) => !selectedProductIds.contains(item['productId'])).toList();
    await updateCart(updated);
    setState(() {
      selectedProductIds.clear();
      selectAll = false;
    });
  }

  void toggleSelectAll(bool? value, List<Map<String, dynamic>> cartItems) {
    setState(() {
      selectAll = value ?? false;
      selectedProductIds = selectAll ? cartItems.map((e) => e['productId'] as String).toList() : [];
    });
  }

  void handleIndividualCheck(bool? value, String productId, List<Map<String, dynamic>> cartItems) {
    setState(() {
      value == true ? selectedProductIds.add(productId) : selectedProductIds.remove(productId);
      selectAll = selectedProductIds.length == cartItems.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        title: const Text('장바구니', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const MyPage(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final cartItems = List<Map<String, dynamic>>.from(data['cartitem'] ?? []);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: selectAll,
                          onChanged: (val) => toggleSelectAll(val, cartItems),
                          activeColor: primaryColor,
                        ),
                        const Text('전체 선택', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => deleteSelectedItems(cartItems),
                      child: const Text('선택삭제',
                          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white30),

              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    final productId = item['productId'];

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('product').doc(productId).get(),
                      builder: (context, productSnap) {
                        if (!productSnap.hasData) return const SizedBox();
                        final product = productSnap.data!.data() as Map<String, dynamic>;
                        final isSelected = selectedProductIds.contains(productId);
                        final createdAt = item['w_createdAt']?.toDate();
                        final dateStr = createdAt != null
                            ? '${createdAt.year}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.day.toString().padLeft(2, '0')}'
                            : '';
                        final totalPrice = item['price'] * item['quantity'];

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: midBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: isSelected,
                                    onChanged: (val) => handleIndividualCheck(val, productId, cartItems),
                                    activeColor: primaryColor,
                                  ),
                                  Text(dateStr, style: const TextStyle(color: Colors.white)),
                                ],
                              ),
                              const SizedBox(height: 5),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      product['imgUrl'],
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(product['name'],
                                            style: const TextStyle(
                                                color: Colors.white, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text('${totalPrice}원',
                                            style: TextStyle(
                                                color: primaryColor, fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 4),

                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(color: primaryColor),
                                            color: midBg,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.remove, size: 16, color: Colors.white),
                                                onPressed: () {
                                                  if (item['quantity'] > 1) {
                                                    setState(() {
                                                      item['quantity']--;
                                                      updateCart(cartItems);
                                                    });
                                                  }
                                                },
                                              ),
                                              Text('${item['quantity']}',
                                                  style: const TextStyle(color: Colors.white)),
                                              IconButton(
                                                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                                                onPressed: () {
                                                  setState(() {
                                                    item['quantity']++;
                                                    updateCart(cartItems);
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ProductViewPage(productId: productId),
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.arrow_forward_ios, color: accent),
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
          );
        },
      ),
      bottomNavigationBar: const CustomBottomBar(currentIndex: 3),
    );
  }
}