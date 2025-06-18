import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SuggestRecipe extends StatefulWidget {
  const SuggestRecipe({super.key});

  @override
  State<SuggestRecipe> createState() => _SuggestRecipeState();
}

class _SuggestRecipeState extends State<SuggestRecipe> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  List<Map<String, dynamic>> _exactMatches = [];
  List<Map<String, dynamic>> _partialMatches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSuggestedRecipes();
  }

  Future<void> _fetchSuggestedRecipes() async {
    if (_uid.isEmpty) return;

    try {
      // 1. 내 재료 목록 가져오기
      final inventorySnapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('inventory')
          .get();

      final ownedNames = inventorySnapshot.docs
          .map((doc) => doc['name'] as String)
          .toList();

      // 2. 전체 레시피 불러오기
      final recipeSnapshot = await _firestore.collection('recipe').get();

      List<Map<String, dynamic>> exact = [];
      List<Map<String, dynamic>> partial = [];

      for (final doc in recipeSnapshot.docs) {
        final data = doc.data();
        final ingredients = List<Map<String, dynamic>>.from(data['ingredients'] ?? []);
        final recipeNames = ingredients.map((i) => i['name'] as String).toList();

        final missingList = recipeNames
            .where((name) => !ownedNames.contains(name))
            .toList();
        final missingCount = missingList.length;

        if (missingCount == 0) {
          exact.add({...data, 'id': doc.id});
        } else if (missingCount > 0 &&
            ownedNames.any((name) => recipeNames.contains(name))) {
          partial.add({...data, 'id': doc.id, 'missing': missingList});
        }
      }

      setState(() {
        _exactMatches = exact;
        _partialMatches = partial;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("🔥 추천 레시피 오류: $e");
      setState(() => _isLoading = false);
    }
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe, {bool showMissing = false}) {
    final missingList = (recipe['missing'] as List?)?.cast<String>() ?? [];

    return Card(
      color: const Color(0xFF2B2B2B),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              leading: recipe['c_imgUrl'] != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  recipe['c_imgUrl'],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              )
                  : const SizedBox(width: 60, height: 60),
              title: Text(
                recipe['cockName_ko'] ?? '',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                recipe['cockName'] ?? '',
                style: const TextStyle(color: Colors.grey),
              ),
              trailing: showMissing && missingList.isNotEmpty
                  ? Text("+${missingList.length}개",
                  style: const TextStyle(color: Colors.orangeAccent))
                  : null,
              onTap: () {
                Navigator.pushNamed(context, '/recipe/view',
                    arguments: recipe['id']);
              },
            ),
            if (showMissing && missingList.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(
                    left: 12, right: 12, bottom: 12, top: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 8,
                    runSpacing: 6,
                    children: missingList.map((name) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          border: Border.all(color: Colors.grey[600]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          name,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "🍸 지금 만들 수 있는 레시피",
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_exactMatches.isEmpty)
          const Text("해당 없음", style: TextStyle(color: Colors.grey)),
        ..._exactMatches.map((r) => _buildRecipeCard(r)),

        const SizedBox(height: 24),
        const Text(
          "🧂 재료만 더 있으면 만들 수 있는 레시피",
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_partialMatches.isEmpty)
          const Text("해당 없음", style: TextStyle(color: Colors.grey)),
        ..._partialMatches.map((r) => _buildRecipeCard(r, showMissing: true)),
      ],
    );
  }
}
