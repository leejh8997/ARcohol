import 'package:flutter/material.dart';
import '../common/appBar.dart';
import '../common/bottomBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
      drawer: const CustomDrawer(),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      backgroundColor: Color(0xFF1F1F1F),
      body: Center(
        child: ElevatedButton(
          onPressed: uploadSampleProducts,
          child: Text('샘플 상품 업로드'),
        ),
      ),
    );
  }
}

void uploadSampleProducts() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final List<Map<String, dynamic>> sampleProducts = List.generate(10, (index) {
    return {
      'productId': 'cup${index + 1}', // 고유 ID
      'name': 'Cocktail Glass ${index + 1}',
      'count': 1,
      'description': '고급 칵테일을 위한 스타일리시한 유리잔 ${index + 1}번.',
      'imgUrl': 'https://example.com/images/cup${index + 1}.jpg',
      'stock': 50 - index * 3, // 50부터 줄어드는 재고
      'price': 8900 + index * 1000,
      'capacity': '${150 + index * 10}ml',
      'size': '${5 + index * 0.5}cm x ${12 + index * 0.5}cm',
      'category': 'glassware',
      'createdAt': FieldValue.serverTimestamp(),
    };
  });

  for (final product in sampleProducts) {
    await firestore.collection('products').doc(product['productId']).set(product);
  }

  print('✅ 샘플 칵테일 컵 10개 업로드 완료!');
}