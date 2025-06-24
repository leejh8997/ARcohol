import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:async/async.dart';
import 'ingredient_tile.dart';
import 'customIngredientDialog.dart';

class IngredientsView extends StatefulWidget {
  final String category;
  final String? focusName;

  const IngredientsView({super.key, required this.category, this.focusName});

  @override
  State<IngredientsView> createState() => _IngredientsViewState();
}

class _IngredientsViewState extends State<IngredientsView> {
  final uid = FirebaseAuth.instance.currentUser?.uid ?? "guest";
  final ScrollController _scrollController = ScrollController();
  final _tileHeight = 72.0; // ListTile approx height

  Map<String, List<QueryDocumentSnapshot>> _grouped = {};
  List<QueryDocumentSnapshot> _flatList = [];
  Set<String> _inventoryIds = {};

  @override
  void initState() {
    super.initState();
    _loadIngredientsAndInventory();
  }

  Future<void> _loadIngredientsAndInventory() async {
    final ingredientSnap = await FirebaseFirestore.instance
        .collection('ingredients')
        .where('category', isEqualTo: widget.category)
        .get();

    final inventorySnap = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("inventory")
        .get();

    final inventoryIds = inventorySnap.docs.map((e) => e.id).toSet();
    final grouped = _groupBySubcategory(ingredientSnap.docs);

    // 평탄화된 리스트 (스크롤용)
    final flat = grouped.values.expand((list) => list).toList();

    setState(() {
      _inventoryIds = inventoryIds;
      _grouped = grouped;
      _flatList = flat;
    });

    if (widget.focusName != null) {
      final index = _flatList.indexWhere((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['name'].toString().toLowerCase() == widget.focusName!.toLowerCase();
      });

      if (index != -1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            index * _tileHeight,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: () async {
              final added = await showDialog(
                context: context,
                builder: (_) => const CustomIngredientDialog(),
              );
              if (added == true && mounted) {
                _loadIngredientsAndInventory(); // 새로고침
              }
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("커스텀 재료 추가", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1F1F1F),
      body: _grouped.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        controller: _scrollController,
        children: _grouped.entries.expand((entry) {
          final subcategory = entry.key;
          final docs = entry.value;

          return [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
              child: Text(
                subcategory,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...docs.map((ingredient) {
              final data = ingredient.data() as Map<String, dynamic>;
              final name = data["name"] ?? "이름 없음";
              final ingredientId = ingredient.id;
              final alreadyAdded = _inventoryIds.contains(ingredientId);

              final isFocused = widget.focusName != null &&
                  name.toString().toLowerCase() ==
                      widget.focusName!.toLowerCase();

              return IngredientTile(
                title: name,
                tileColor: isFocused ? Colors.white10 : null,
                trailing: Icon(
                  alreadyAdded ? Icons.check : Icons.add,
                  color: alreadyAdded ? Colors.grey : Colors.white,
                ),
                onTap: alreadyAdded
                    ? null
                    : () => _addToPantry(
                  context,
                  uid,
                  data,
                  ingredientId,
                ),
              );
            }).toList(),
          ];
        }).toList(),
      ),
    );
  }

  Map<String, List<QueryDocumentSnapshot>> _groupBySubcategory(List<QueryDocumentSnapshot> docs) {
    final Map<String, List<QueryDocumentSnapshot>> grouped = {};
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final subcategory = (data["subcategory"] ?? "기타").toString();
      grouped.putIfAbsent(subcategory, () => []);
      grouped[subcategory]!.add(doc);
    }
    return grouped;
  }

  Future<void> _addToPantry(
      BuildContext context,
      String uid,
      Map<String, dynamic> ingredient,
      String ingredientId,
      ) async {
    final docRef = FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("inventory")
        .doc(ingredientId);

    final exists = await docRef.get();
    if (exists.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${ingredient["name"]} 은 이미 창고에 있어요.")),
      );
      return;
    }

    await docRef.set({
      "ingredientId": ingredientId,
      "name": ingredient["name"] ?? "이름 없음",
      "category": ingredient["category"] ?? "기타",
      "isAlcoholic": ingredient["isAlcoholic"] ?? false,
      "abv": ingredient["abv"] ?? 0,
      "subcategory": ingredient["subcategory"]?.toString().trim().isNotEmpty == true
          ? ingredient["subcategory"]
          : "기타",
    });

    if (mounted) {
      _loadIngredientsAndInventory();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${ingredient["name"]} 을(를) 창고에 추가했어요!")),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
