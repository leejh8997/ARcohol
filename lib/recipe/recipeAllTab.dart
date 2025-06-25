import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecipeAllTab extends StatefulWidget {
  const RecipeAllTab({Key? key}) : super(key: key);

  @override
  State<RecipeAllTab> createState() => _RecipeAllTabState();
}

class _RecipeAllTabState extends State<RecipeAllTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  final TextEditingController _searchController = TextEditingController();

  List<DocumentSnapshot> _rawDocs = [];
  List<Map<String, dynamic>> _recipes = [];
  List<bool> _likedStates = [];
  String _searchText = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAllRecipes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllRecipes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await _firestore.collection('recipe').orderBy('cockName').get();

      final docs = snapshot.docs;
      final newRecipes = <Map<String, dynamic>>[];
      final newLikes = <bool>[];

      for (var doc in docs) {
        final data = doc.data() as Map<String, dynamic>;
        final likes = List<String>.from(data['likes'] ?? []);
        newRecipes.add(Map<String, dynamic>.from(data));
        newLikes.add(likes.contains(_uid));
      }

      setState(() {
        _rawDocs = docs;
        _recipes = newRecipes;
        _likedStates = newLikes;
        _isLoading = false;
      });
    } catch (e) {
      print('🔥 Error loading recipes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleLike(int index) async {
    final recipeId = _rawDocs[index].id;
    final data = _recipes[index];
    List<String> likes = List<String>.from(data['likes'] ?? []);
    final isLiked = likes.contains(_uid);

    await _firestore.collection('recipe').doc(recipeId).update({
      'likes': isLiked ? FieldValue.arrayRemove([_uid]) : FieldValue.arrayUnion([_uid]),
    });

    await _firestore.collection('users').doc(_uid).update({
      'likes': isLiked ? FieldValue.arrayRemove([recipeId]) : FieldValue.arrayUnion([recipeId]),
    });

    setState(() {
      _likedStates[index] = !isLiked;
      if (isLiked) {
        likes.remove(_uid);
      } else {
        likes.add(_uid);
      }
      _recipes[index]['likes'] = likes;
    });
  }

  List<Map<String, dynamic>> get _filteredRecipes {
    if (_searchText.isEmpty) return _recipes;

    return _recipes.where((recipe) {
      final ko = (recipe['cockName_ko'] ?? '').toString().toLowerCase();
      final en = (recipe['cockName'] ?? '').toString().toLowerCase();
      return ko.contains(_searchText.toLowerCase()) || en.contains(_searchText.toLowerCase());
    }).toList();
  }

  String _buildIngredientsPreview(dynamic ingredients) {
    if (ingredients is List) {
      final preview = ingredients.take(3).map((item) {
        if (item is Map && item.containsKey('name')) {
          return item['name'];
        } else if (item is String) {
          return item;
        }
        return '';
      }).where((name) => name != '').join(', ');
      return preview.isNotEmpty ? preview : '재료 정보 없음';
    }
    return '재료 정보 없음';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: '레시피 검색 (한글 또는 영어)',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF3A3A3A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            ),
          ),
        ),
        if (_isLoading)
          const Expanded(
            child: Center(child: CircularProgressIndicator()),
          )
        else
          Expanded(
            child: _filteredRecipes.isEmpty
                ? const Center(
              child: Text(
                '검색 결과가 없습니다.',
                style: TextStyle(color: Colors.white54),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
              itemCount: _filteredRecipes.length,
              itemBuilder: (context, index) {
                final recipe = _filteredRecipes[index];
                final rawIndex = _recipes.indexOf(recipe);
                final isLiked = _likedStates[rawIndex];
                final recipe = _recipes[index];
                final isLiked = _likedStates[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: const Color(0xFF2B2B2B),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          '/recipe/view',
                          arguments: {
                            'recipeId': _rawDocs[index].id,
                            'isCustom': false, // 일반 레시피 탭이므로 false
                          },
                        );
                        if (result == true) {
                          final doc = await _firestore.collection('recipe').doc(_rawDocs[rawIndex].id).get();
                          if (doc.exists) {
                            final data = doc.data()!;
                            final likes = List<String>.from(data['likes'] ?? []);
                            setState(() {
                              _recipes[rawIndex] = Map<String, dynamic>.from(data);
                              _likedStates[rawIndex] = likes.contains(_uid);
                            });
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: recipe['c_imgUrl'] != null
                                  ? Image.network(recipe['c_imgUrl'], width: 100, height: 100, fit: BoxFit.cover)
                                  : const SizedBox(width: 100, height: 100),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recipe['cockName_ko'] ?? 'No Name',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (recipe['cockName'] != null)
                                    Text(
                                      '(${recipe['cockName']})',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _buildIngredientsPreview(recipe['ingredients']),
                                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border_outlined,
                                color: isLiked ? Colors.redAccent : Colors.grey[400],
                              ),
                              onPressed: () => _toggleLike(rawIndex),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
