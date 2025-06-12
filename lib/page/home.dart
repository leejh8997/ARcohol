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

  bool hasMoreRecommended = true;
  bool hasMorePopular = true;
  bool hasMoreProduct = true;

  int totalRecommendedCount = 0;
  int totalPopularCount = 0;
  int totalProductsCount = 0;

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    await fetchRecommendedTotalCounts();
    await fetchPopularTotalCounts();
    await fetchProductsTotalCounts();

    fetchBanner();
    fetchRecommended();
    fetchPopular();
    fetchProducts();
  }

  Future<void> fetchBanner() async {
    final snap = await FirebaseFirestore.instance.collection('recipe').get();
    snap.docs.shuffle();
    setState(() {
      bannerList = snap.docs.take(3).toList();
    });
  }

  Future<void> fetchRecommendedTotalCounts() async {
    final snap = await FirebaseFirestore.instance.collection('recipe').get();
    totalRecommendedCount = snap.docs.length;
  }

  Future<void> fetchRecommended() async {
    // TODO: 마이바 재료 기반 필터링 로직 추가
    Query query = FirebaseFirestore.instance
        .collection('recipe')
        .limit(5);

    if (recommendedList.isNotEmpty) {
      query = query.startAfterDocument(recommendedList.last);
    }

    final snap = await query.get();
    setState(() {
      recommendedList.addAll(snap.docs);
      if (recommendedList.length >= totalRecommendedCount) {
        hasMoreRecommended = false;
      }
    });
  }

  Future<void> fetchPopularTotalCounts() async {
    final snap = await FirebaseFirestore.instance.collection('recipe').get();
    totalPopularCount = snap.docs.length;
  }

  Future<void> fetchPopular() async {
    Query query = FirebaseFirestore.instance
        .collection('recipe')
        .orderBy('likeCount', descending: true)
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
    final name = doc.data().toString().contains('cockName') ? doc['cockName'] : doc['name'];
    final image = doc.data().toString().contains('c_imgUrl') ? doc['c_imgUrl'] : doc['imgUrl'];

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(image, height: 100, width: 100, fit: BoxFit.cover),
          ),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(color: Colors.white)),
        ],
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
                    height: 100,
                    color: Colors.grey[800],
                    child: const Center(child: Text('More', style: TextStyle(color: Colors.white))),
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
            buildSection('추천 상품', Icons.recommend, recommendedList, () => fetchRecommended(), hasMoreRecommended,),
            const SizedBox(height: 20),
            buildSection('🔥 인기 상품', Icons.local_fire_department, popularList, fetchPopular, hasMorePopular,),
            const SizedBox(height: 20),
            buildSection('🛒 판매 상품', Icons.shopping_bag, productList, fetchProducts, hasMoreProduct,),
          ],
        ),
      ),
    );
  }
}