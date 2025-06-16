import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ingredient_tile.dart';

class InventoryTab extends StatefulWidget {
  const InventoryTab({super.key});

  @override
  State<InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<InventoryTab> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _expandedCategory;
  final Map<String, String?> _expandedSubcategories = {};

  Stream<List<String>> _fetchCategoriesStream(String uid) {
    return FirebaseFirestore.instance
        .collection("users").doc(uid).collection("inventory")
        .snapshots()
        .map((snapshot) {
      final allCategories = snapshot.docs
          .map((doc) => doc['category']?.toString() ?? "기타")
          .where((cat) => cat != "custom") // custom 제외
          .toSet()
          .toList();
      allCategories.sort();
      return allCategories;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Center(child: Text("로그인 후 이용 가능합니다", style: TextStyle(color: Colors.white)));
    }

    final uid = user.uid;

    return StreamBuilder<List<String>>(
      stream: _fetchCategoriesStream(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final categories = snapshot.data!;

        return ListView(
          key: const PageStorageKey("inventoryListView"),
          children: [
            ...categories.map((category) => _buildCategoryStream(uid, category)),
            _buildCustomIngredients(uid), // 항상 마지막
            if (categories.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Text("창고에 추가한 재료가 없습니다", style: TextStyle(color: Colors.white70)),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCustomIngredients(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users").doc(uid).collection("custom").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final docs = snapshot.data!.docs;

        return ExpansionTile(
          key: const PageStorageKey("inv_cat_custom"),
          title: const Text("커스텀 재료", style: TextStyle(color: Colors.white)),
          collapsedBackgroundColor: Colors.white10,
          backgroundColor: Colors.white12,
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = data["name"] ?? "이름 없음";

            return IngredientTile(
              title: name,
              description: data["description"],
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection("users").doc(uid)
                      .collection("custom").doc(doc.id).delete();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("$name 을(를) 삭제했습니다")),
                  );
                },
              ),
              compact: true,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCategoryStream(String uid, String category) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users").doc(uid).collection("inventory")
          .where("category", isEqualTo: category)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final docs = snapshot.data!.docs;

        // 알콜 여부 기준 하위 정렬
        final subMap = <String, List<QueryDocumentSnapshot>>{};
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final isAlcohol = data["isAlcoholic"] == true;
          final sub = isAlcohol
              ? (data["subcategory"]?.toString().trim().isNotEmpty == true
              ? data["subcategory"]
              : "기타")
              : "";
          subMap.putIfAbsent(sub, () => []).add(doc);
        }

        if (subMap.length == 1 && subMap.containsKey("")) {
          // 논알콜 단일 리스트
          final list = subMap[""]!;
          return ExpansionTile(
            key: PageStorageKey("inv_cat_$category"),
            title: Text(category, style: const TextStyle(color: Colors.white)),
            collapsedBackgroundColor: const Color(0xFF1F1F1F),
            backgroundColor: Colors.black,
            children: list.map((doc) => _buildIngredientTile(doc, uid)).toList(),
          );
        }

        // 알콜류 - 하위 카테고리 존재
        return ExpansionTile(
          key: PageStorageKey("inv_cat_$category"),
          title: Text(category, style: const TextStyle(color: Colors.white)),
          initiallyExpanded: _expandedCategory == category,
          onExpansionChanged: (expanded) {
            setState(() {
              _expandedCategory = expanded ? category : null;
              _expandedSubcategories.clear();
            });
          },
          collapsedBackgroundColor: const Color(0xFF1F1F1F),
          backgroundColor: Colors.black,
          children: subMap.entries.map((entry) {
            final sub = entry.key;
            final subDocs = entry.value;
            final isExpanded = _expandedSubcategories[category] == sub;

            return ExpansionTile(
              key: PageStorageKey("inv_sub_${category}_$sub"),
              title: Text(sub, style: const TextStyle(color: Colors.white70)),
              initiallyExpanded: isExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  _expandedSubcategories[category] = expanded ? sub : null;
                });
              },
              collapsedBackgroundColor: Colors.white10,
              backgroundColor: Colors.white12,
              children: subDocs.map((doc) => _buildIngredientTile(doc, uid)).toList(),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildIngredientTile(QueryDocumentSnapshot doc, String uid) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data["name"] ?? "이름 없음";

    return IngredientTile(
      title: name,
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.white),
        onPressed: () async {
          await FirebaseFirestore.instance
              .collection("users").doc(uid)
              .collection("inventory").doc(doc.id).delete();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$name 을(를) 삭제했습니다")),
          );
        },
      ),
      compact: true,
    );
  }
}
