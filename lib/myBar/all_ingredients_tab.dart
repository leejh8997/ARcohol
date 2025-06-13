import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AllIngredientsTab extends StatefulWidget {
  const AllIngredientsTab({super.key});

  @override
  State<AllIngredientsTab> createState() => _AllIngredientsTabState();
}

class _AllIngredientsTabState extends State<AllIngredientsTab> with AutomaticKeepAliveClientMixin {
  String? _expandedCategory;
  final Map<String, String?> _expandedSubcategories = {};

  void _addToPantry(Map<String, dynamic> ingredient) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? "guest";
    final ingredientId = ingredient["ingredientId"];

    final docRef = FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("inventory")
        .doc(ingredientId);

    final doc = await docRef.get();
    if (doc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${ingredient["name"]} 은 이미 창고에 있어요.")),
      );
      return;
    }

    // 공통 필드
    final data = {
      "ingredientId": ingredientId,
      "name": ingredient["name"] ?? "이름 없음",
      "category": ingredient["category"] ?? "기타",
      "isAlcoholic": ingredient["isAlcoholic"] ?? false,
      "abv": ingredient["abv"] ?? 0,
    };

    // 알콜 재료일 경우만 subcategory 추가
    if (ingredient["isAlcoholic"] == true &&
        (ingredient["subcategory"]?.toString().trim().isNotEmpty ?? false)) {
      data["subcategory"] = ingredient["subcategory"];
    }

    await docRef.set(data);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${ingredient["name"]} 을(를) 창고에 추가했어요!")),
    );
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
              collapsedBackgroundColor: const Color(0xFF1F1F1F),
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
                    icon: const Icon(Icons.inventory, color: Colors.white),
                    onPressed: () => _addToPantry(ingredient),
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
                        icon: const Icon(Icons.inventory, color: Colors.white),
                        onPressed: () => _addToPantry(ingredient),
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

    final List<Map<String, dynamic>> allData = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data["ingredientId"] = doc.id;
      return data;
    }).toList();

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
