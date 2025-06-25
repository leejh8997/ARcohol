import 'package:arcohol/page/productView.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../common/appBar.dart';
import '../common/bottomBar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  List<DocumentSnapshot> bannerList = [];
  List<DocumentSnapshot> recommendedList = [];
  List<DocumentSnapshot> popularList = [];
  List<DocumentSnapshot> productList = [];
  List<DocumentSnapshot> _allPartialMatches = [];

  bool isLoading = true;
  bool hasMoreRecommended = true;
  bool hasMorePopular = true;
  bool hasMoreProduct = true;

  int _recommendedPage = 0;
  final int _recommendedPageSize = 5;
  int totalPopularCount = 0;
  int totalProductsCount = 0;

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    await fetchRecommended(); // 내부에서 전체 필터링 처리
    await fetchPopularTotalCounts();
    await fetchPopular();
    await fetchProductsTotalCounts();
    await fetchProducts();
    await fetchBanner();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchBanner() async {
    final snap = await FirebaseFirestore.instance.collection('recipe').get();
    snap.docs.shuffle();
    setState(() {
      bannerList = snap.docs.take(3).toList();
    });
  }

  Future<void> fetchRecommended() async {
    if (!hasMoreRecommended) return;

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    if (_allPartialMatches.isEmpty) {
      final inventorySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('inventory')
          .get();

      final ownedNames = inventorySnapshot.docs
          .map((doc) => doc['name'] as String)
          .toSet();

      final recipeSnapshot = await FirebaseFirestore.instance
          .collection('recipe')
          .get();

      for (final doc in recipeSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final ingredients = List<Map<String, dynamic>>.from(data['ingredients'] ?? []);
        final recipeNames = ingredients.map((i) => i['name'] as String).toSet();

        final missing = recipeNames.difference(ownedNames);
        if (missing.isNotEmpty && missing.length < recipeNames.length) {
          _allPartialMatches.add(doc);
        }
      }

      _allPartialMatches.shuffle(); // 랜덤 정렬
    }

    // 페이징
    final start = _recommendedPage * _recommendedPageSize;
    final end = start + _recommendedPageSize;
    final nextItems = _allPartialMatches.sublist(
      start,
      end > _allPartialMatches.length ? _allPartialMatches.length : end,
    );

    setState(() {
      recommendedList.addAll(nextItems);
      _recommendedPage++;
      hasMoreRecommended = recommendedList.length < _allPartialMatches.length;
    });
  }

  Future<void> fetchPopularTotalCounts() async {
    final snap = await FirebaseFirestore.instance.collection('recipe').get();
    totalPopularCount = snap.docs.length;
  }

  Future<void> fetchPopular() async {
    Query query = FirebaseFirestore.instance
        .collection('recipe')
        .orderBy('likes', descending: true)
        .limit(5);

    if (popularList.isNotEmpty) {
      query = query.startAfterDocument(popularList.last);
    }

    final snap = await query.get();
    setState(() {
      popularList.addAll(snap.docs);
      if (popularList.length >= totalPopularCount) {
        hasMorePopular = false;
      }
    });
  }

  Future<void> fetchProductsTotalCounts() async {
    final snap = await FirebaseFirestore.instance.collection('product').get();
    totalProductsCount = snap.docs.length;
  }

  Future<void> fetchProducts() async {
    Query query = FirebaseFirestore.instance
        .collection('product')
        .limit(5);

    if (productList.isNotEmpty) {
      query = query.startAfterDocument(productList.last);
    }

    final snap = await query.get();
    setState(() {
      productList.addAll(snap.docs);

      if (productList.length >= totalProductsCount) {
        hasMoreProduct = false;
      }
    });
  }

  Widget buildCard(DocumentSnapshot doc) {
    final name = doc.data().toString().contains('cockName_ko') ? doc['cockName_ko'] : doc['name'];
    final image = doc.data().toString().contains('c_imgUrl') ? doc['c_imgUrl'] : doc['imgUrl'];

    return GestureDetector(
      onTap: () {
        if (doc.reference.parent.id == 'product') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProductViewPage(productId: doc.id)),
          );
        } else if (doc.reference.parent.id == 'recipe') {
          Navigator.pushNamed(context, '/recipe/view', arguments: {
            'recipeId': doc.id,
            'isCustom': false,
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(image, height: 100, width: 100, fit: BoxFit.cover),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 100,
              child: Text(
                name,
                style: const TextStyle(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSection(String title, IconData icon, List<DocumentSnapshot> list, VoidCallback? onMore, bool showMore) {
    final items = list;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.orange),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...items.map(buildCard).toList(),
              if (onMore != null && showMore)
                GestureDetector(
                  onTap: onMore,
                  child: Container(
                    width: 100,
                    height: 126,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF333333),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.add, color: Colors.white, size: 32),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF1F1F1F),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(
                color: Color(0xFFE94E2B),
              ),
              SizedBox(height: 16),
              Text(
                '로딩 중입니다...',
                style: TextStyle(color: Color(0xFFE94E2B), fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }
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
      backgroundColor: const Color(0xFF1F1F1F),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (bannerList.isNotEmpty)
              CarouselSlider(
                options: CarouselOptions(height: 200.0, autoPlay: true),
                items: bannerList.map((doc) {
                  return Builder(
                    builder: (BuildContext context) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(doc['c_imgUrl'], fit: BoxFit.cover, width: double.infinity),
                      );
                    },
                  );
                }).toList(),
              ),
            const SizedBox(height: 20),
            buildSection('추천 레시피', Icons.recommend, recommendedList, () => fetchRecommended(), hasMoreRecommended,),
            const SizedBox(height: 20),
            buildSection(' 인기 레시피', Icons.local_fire_department, popularList, fetchPopular, hasMorePopular,),
            const SizedBox(height: 20),
            buildSection(' 판매 상품', Icons.shopping_bag, productList, fetchProducts, hasMoreProduct,),
          ],
        ),
      ),
    );
  }
}