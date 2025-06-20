import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:async/async.dart';
import 'ingredient_tile.dart';
import 'customIngredientDialog.dart';

class IngredientsView extends StatefulWidget {
  final String category;
  const IngredientsView({super.key, required this.category});

  @override
  State<IngredientsView> createState() => _IngredientsViewState();
}

class _IngredientsViewState extends State<IngredientsView> {
  final uid = FirebaseAuth.instance.currentUser?.uid ?? "guest";

  @override
  Widget build(BuildContext context) {
    final ingredientStream = FirebaseFirestore.instance
        .collection('ingredients')
        .where('category', isEqualTo: widget.category)
        .snapshots();

    final inventoryStream = FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("inventory")
        .snapshots();

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
                setState(() {}); // 리빌드
              }
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("커스텀 재료 추가", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1F1F1F),

      body: StreamBuilder<List<QuerySnapshot>>(
        stream: StreamZip([ingredientStream, inventoryStream]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final ingredientDocs = snapshot.data![0].docs;
          final inventoryIds = snapshot.data![1].docs.map((e) => e.id).toSet();
          final grouped = _groupBySubcategory(ingredientDocs);

          return ListView(
            children: grouped.entries.expand((entry) {
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
                  final alreadyAdded = inventoryIds.contains(ingredientId);

                  return IngredientTile(
                    title: name,
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
          );
        },
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

    // 여기서 강제 리빌드
    if (mounted) setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${ingredient["name"]} 을(를) 창고에 추가했어요!")),
    );
  }
}
