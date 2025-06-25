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

  final TextEditingController _searchController = TextEditingController(); // ✅
  String _searchText = ''; // ✅

  Stream<List<String>> _fetchCategoriesStream(String uid) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("inventory")
        .snapshots()
        .map((snapshot) {
      final allCategories = snapshot.docs
          .map((doc) => doc['category']?.toString() ?? "기타")
          .where((cat) => cat != "custom")
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
      return const Center(
        child: Text("로그인 후 이용 가능합니다", style: TextStyle(color: Colors.white)),
      );
    }

    final uid = user.uid;

    return Column(
      children: [
        // ✅ 검색창 추가
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchText = value),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "창고 내 재료 검색",
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF3A3A3A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(uid)
                .collection("inventory")
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              // ✅ 검색 중일 때 평면 리스트 출력
              if (_searchText.trim().isNotEmpty) {
                final filtered = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  return name.contains(_searchText.toLowerCase());
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text("검색 결과가 없습니다", style: TextStyle(color: Colors.white70)),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final doc = filtered[index];
                    return _buildIngredientTile(doc, uid);
                  },
                );
              }

              // ✅ 기본 분류 출력 (카테고리/서브카테고리별)
              return StreamBuilder<List<String>>(
                stream: _fetchCategoriesStream(uid),
                builder: (context, catSnap) {
                  if (!catSnap.hasData) return const SizedBox.shrink();

                  final categories = catSnap.data!;
                  return ListView(
                    key: const PageStorageKey("inventoryListView"),
                    children: [
                      ...categories.map((category) => _buildCategoryStream(uid, category)),
                      _buildCustomIngredients(uid),
                      if (categories.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Center(
                            child: Text("창고에 추가한 재료가 없습니다",
                                style: TextStyle(color: Colors.white70)),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomIngredients(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("custom")
          .snapshots(),
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
                      .collection("users")
                      .doc(uid)
                      .collection("custom")
                      .doc(doc.id)
                      .delete();

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
          .collection("users")
          .doc(uid)
          .collection("inventory")
          .where("category", isEqualTo: category)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final docs = snapshot.data!.docs;

        final subMap = <String, List<QueryDocumentSnapshot>>{};
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final rawSub = data["subcategory"]?.toString().trim();
          final sub = (rawSub != null && rawSub.isNotEmpty) ? rawSub : "기타";
          subMap.putIfAbsent(sub, () => []).add(doc);
        }

        return ExpansionTile(
          key: PageStorageKey("inv_cat_$category"),
          title: Text(category, style: const TextStyle(color: Colors.white)),
          initiallyExpanded: _expandedCategory == category,
          onExpansionChanged: (expanded) {
            setState(() {
              _expandedCategory = expanded ? category : null;
            });
          },
          collapsedBackgroundColor: const Color(0xFF1F1F1F),
          backgroundColor: Colors.black,
          children: subMap.entries.map((entry) {
            final sub = entry.key;
            final subDocs = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(
                    sub,
                    style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                ),
                ...subDocs.map((doc) => _buildIngredientTile(doc, uid)),
                const Divider(color: Colors.white12, height: 16),
              ],
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
              .collection("users")
              .doc(uid)
              .collection("inventory")
              .doc(doc.id)
              .delete();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$name 을(를) 삭제했습니다")),
          );
        },
      ),
      compact: true,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
