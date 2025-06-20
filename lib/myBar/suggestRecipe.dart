import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ai/firebase_ai.dart';

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
  String? _aiRecommendation;
  bool _isLoading = true;
  bool _showAll = false;
  bool _showAllPartial = false;

  @override
  void initState() {
    super.initState();
    _fetchSuggestedRecipes();
  }

  Future<void> _fetchSuggestedRecipes() async {
    if (_uid.isEmpty) return;

    try {
      final inventorySnapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('inventory')
          .get();

      final ownedNames = inventorySnapshot.docs
          .map((doc) => doc['name'] as String)
          .toSet();

      final recipeSnapshot = await _firestore.collection('recipe').get();

      List<Map<String, dynamic>> exact = [];
      List<Map<String, dynamic>> partial = [];

      for (final doc in recipeSnapshot.docs) {
        final data = doc.data();
        final ingredients = List<Map<String, dynamic>>.from(data['ingredients'] ?? []);
        final recipeNames = ingredients.map((i) => i['name'] as String).toSet();

        final missingList = recipeNames.difference(ownedNames).toList();

        if (missingList.isEmpty) {
          exact.add({...data, 'id': doc.id});
        } else if (missingList.length < recipeNames.length) {
          partial.add({...data, 'id': doc.id, 'missing': missingList});
        }
      }

      await _fetchAIRecommendation(ownedNames);

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

  Future<void> _fetchAIRecommendation(Set<String> ownedNames) async {
    try {
      final model = FirebaseAI.googleAI().generativeModel(model: 'gemini-1.5-flash');

      final prompt = [
        Content.text(
            '''내가 가진 재료는 다음과 같아: ${ownedNames.join(", ")}.
            이 재료들을 기반으로 만들 수 있는 칵테일을 하나 추천해줘.
            레시피 데이터에 없더라도 창의적으로 제안해도 돼.
        가능하다면 유사한 재료로 대체 가능한 예도 설명해줘.'''
        )
      ];

      final response = await model.generateContent(prompt);
      _aiRecommendation = response.text ?? 'AI 응답 없음';
    } catch (e) {
      _aiRecommendation = 'AI 추천 실패: $e';
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
                Navigator.pushNamed(context, '/recipe/view', arguments: recipe['id']);
              },
            ),
            if (showMissing && missingList.isNotEmpty)
              Padding(
                padding:
                const EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 4),
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
                          border: Border.all(color: Colors.grey[600]! ),
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

    final limitedExact = _showAll ? _exactMatches : _exactMatches.take(3).toList();
    final limitedPartial = _showAllPartial ? _partialMatches : _partialMatches.take(3).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "🍸 지금 만들 수 있는 레시피",
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (limitedExact.isEmpty)
          const Text("해당 없음", style: TextStyle(color: Colors.grey)),
        ...limitedExact.map((r) => _buildRecipeCard(r)),
        if (_exactMatches.length > 3 && !_showAll)
          GestureDetector(
            onTap: () => setState(() => _showAll = true),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[850],
              ),
              child: const Center(
                child: Text("+ 더 보기", style: TextStyle(color: Colors.lightBlueAccent)),
              ),
            ),
          ),

        const SizedBox(height: 24),
        const Text(
          "🧂 재료만 더 있으면 만들 수 있는 레시피",
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (limitedPartial.isEmpty)
          const Text("해당 없음", style: TextStyle(color: Colors.grey)),
        ...limitedPartial.map((r) => _buildRecipeCard(r, showMissing: true)),
        if (_partialMatches.length > 3 && !_showAllPartial)
          GestureDetector(
            onTap: () => setState(() => _showAllPartial = true),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[850],
              ),
              child: const Center(
                child: Text("+ 더 보기", style: TextStyle(color: Colors.lightBlueAccent)),
              ),
            ),
          ),

        const SizedBox(height: 24),
        const Text(
          "🤖 AI가 제안하는 칵테일",
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_aiRecommendation != null)
          Text(_aiRecommendation!, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
