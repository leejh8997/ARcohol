import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../common/appBar.dart';
import '../common/bottomBar.dart';

class MyBarPage extends StatefulWidget {
  const MyBarPage({super.key});

  @override
  State<MyBarPage> createState() => _MyBarPageState();
}

class _MyBarPageState extends State<MyBarPage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              color: Color(0xFF1F1F1F),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Color(0xFFF64F1A),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: '추천레시피'),
                  Tab(text: '재료 창고'),
                  Tab(text: '내 창고'),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const Center(child: Text("추천 가능한 레시피 리스트", style: TextStyle(color: Colors.white))),
                const AllIngredientsTab(),
                const Center(child: Text("내가 추가한 재료들", style: TextStyle(color: Colors.white))),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class AllIngredientsTab extends StatefulWidget {
  const AllIngredientsTab({super.key});

  @override
  State<AllIngredientsTab> createState() => _AllIngredientsTabState();
}

class _AllIngredientsTabState extends State<AllIngredientsTab> with AutomaticKeepAliveClientMixin {
  String? _expandedCategory;
  final Map<String, String?> _expandedSubcategories = {};

  void _addToPantry(String ingredientId, String name) async {
    final userId = "guest"; // 임시 사용자 ID 또는 로그인한 유저 ID 사용

    final docRef = FirebaseFirestore.instance
        .collection("userPantry")
        .doc(userId)
        .collection("ingredients")
        .doc(ingredientId);

    final doc = await docRef.get();
    if (doc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$name 은 이미 창고에 있어요.")),
      );
    } else {
      await docRef.set({"name": name});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$name 을(를) 창고에 추가했어요!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("ingredients").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
              child: Text("데이터를 불러오는 중 오류가 발생했습니다.", style: TextStyle(color: Colors.red)));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final groupedData = _groupIngredients(snapshot.data!.docs);

        return ListView(
          key: const PageStorageKey("ingredientListView"),
          children: groupedData.entries.map((categoryEntry) {
            final String category = categoryEntry.key;
            final subcategories = categoryEntry.value;

            return ExpansionTile(
              key: PageStorageKey("cat_$category"),
              title: Text(category, style: const TextStyle(color: Colors.white)),
              collapsedBackgroundColor: Color(0xFF1F1F1F),
              backgroundColor: Colors.black,
              initiallyExpanded: _expandedCategory == category,
              onExpansionChanged: (expanded) {
                setState(() {
                  _expandedCategory = expanded ? category : null;
                  _expandedSubcategories.clear();
                });
              },
              children: subcategories.length == 1 && subcategories.keys.first == "기타"
                  ? subcategories["기타"]!.map((ingredient) {
                final ingredientId = ingredient["ingredientId"];
                final name = ingredient["name"] ?? "이름 없음";

                return ListTile(
                  title: Text(name, style: const TextStyle(color: Colors.white)),
                  trailing: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () => _addToPantry(ingredientId, name),
                  ),
                );
              }).toList()
                  : subcategories.entries.map((subcategoryEntry) {
                final String subcategory = subcategoryEntry.key;
                final ingredients = subcategoryEntry.value;
                final isExpanded = _expandedSubcategories[category] == subcategory;

                return ExpansionTile(
                  key: PageStorageKey("sub_${category}_$subcategory"),
                  title: Text(subcategory, style: const TextStyle(color: Colors.white70)),
                  collapsedBackgroundColor: Colors.white10,
                  backgroundColor: Colors.white12,
                  initiallyExpanded: isExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _expandedSubcategories[category] = expanded ? subcategory : null;
                    });
                  },
                  children: ingredients.map((ingredient) {
                    final ingredientId = ingredient["ingredientId"];
                    final name = ingredient["name"] ?? "이름 없음";

                    return ListTile(
                      title: Text(name, style: const TextStyle(color: Colors.white)),
                      trailing: IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () => _addToPantry(ingredientId, name),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            );
          }).toList(),
        );
      },
    );
  }

  Map<String, Map<String, List<Map<String, dynamic>>>> _groupIngredients(List<QueryDocumentSnapshot> docs) {
    final Map<String, Map<String, List<Map<String, dynamic>>>> grouped = {};

    // 먼저 데이터 리스트로 변환
    final List<Map<String, dynamic>> allData = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data["ingredientId"] = doc.id; // 혹시 ID 누락될 경우 대비
      return data;
    }).toList();

    // 정렬: 1순위 isAlcoholic, 2순위 category, 3순위 subcategory (있을 경우), 4순위 name
    allData.sort((a, b) {
      final aAlcohol = a["isAlcoholic"] == true ? 0 : 1;
      final bAlcohol = b["isAlcoholic"] == true ? 0 : 1;
      final cmpAlcohol = aAlcohol.compareTo(bAlcohol);
      if (cmpAlcohol != 0) return cmpAlcohol;

      final aCat = (a["category"] ?? "").toString();
      final bCat = (b["category"] ?? "").toString();
      final cmpCat = aCat.compareTo(bCat);
      if (cmpCat != 0) return cmpCat;

      final aSub = (a["subcategory"] ?? "").toString();
      final bSub = (b["subcategory"] ?? "").toString();
      final cmpSub = aSub.compareTo(bSub);
      if (cmpSub != 0) return cmpSub;

      final aName = (a["name"] ?? "").toString();
      final bName = (b["name"] ?? "").toString();
      return aName.compareTo(bName);
    });

    // 그룹핑
    for (var data in allData) {
      final category = data["category"]?.toString() ?? "기타";
      final isAlcohol = data["isAlcoholic"] == true;
      final hasSubcategory = isAlcohol && (data["subcategory"]?.toString().trim().isNotEmpty ?? false);
      final subcategory = hasSubcategory ? data["subcategory"].toString() : "기타";

      grouped.putIfAbsent(category, () => {});
      grouped[category]!.putIfAbsent(subcategory, () => []);
      grouped[category]![subcategory]!.add(data);
    }

    return grouped;
  }

  @override
  bool get wantKeepAlive => true;
}
