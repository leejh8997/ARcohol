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
  final ScrollController _scrollController = ScrollController();

  List<DocumentSnapshot> _rawDocs = [];
  List<Map<String, dynamic>> _recipes = [];
  List<bool> _likedStates = [];

  DocumentSnapshot? _lastDoc;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    Query query = _firestore.collection('recipe').orderBy('cockName').limit(10);
    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isEmpty) {
      setState(() {
        _hasMore = false;
        _isLoading = false;
      });
      return;
    }

    List<DocumentSnapshot> newDocs = snapshot.docs;
    List<Map<String, dynamic>> newRecipes = [];
    List<bool> newLikes = [];

    for (var doc in newDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final likes = List<String>.from(data['likes'] ?? []);
      newRecipes.add(Map<String, dynamic>.from(data));
      newLikes.add(likes.contains(_uid));
    }

    setState(() {
      _rawDocs.addAll(newDocs);
      _recipes.addAll(newRecipes);
      _likedStates.addAll(newLikes);
      _lastDoc = newDocs.last;
      _isLoading = false;
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadRecipes();
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
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      itemCount: _recipes.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _recipes.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

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
                  arguments: _rawDocs[index].id,
                );

                if (result == true) {
                  // 상세 페이지에서 좋아요 상태가 바뀐 경우 해당 항목만 다시 불러오기
                  final doc = await _firestore.collection('recipe').doc(_rawDocs[index].id).get();
                  if (doc.exists) {
                    final data = doc.data()!;
                    final likes = List<String>.from(data['likes'] ?? []);

                    setState(() {
                      _recipes[index] = Map<String, dynamic>.from(data);
                      _likedStates[index] = likes.contains(_uid);
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
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  recipe['cockName_ko'] ?? 'No Name',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
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
                      onPressed: () => _toggleLike(index),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
