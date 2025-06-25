import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RecipeLikedTab extends StatefulWidget {
  const RecipeLikedTab({super.key});

  @override
  State<RecipeLikedTab> createState() => _RecipeLikedTabState();
}

class _RecipeLikedTabState extends State<RecipeLikedTab> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final int _limitIncrement = 20;
  int _limit = 20;
  bool _isLoading = false;

  List<DocumentSnapshot> _likedRecipes = [];
  String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadLikedRecipes();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        setState(() => _limit += _limitIncrement);
        _loadLikedRecipes();
      }
    });
  }

  Future<void> _loadLikedRecipes() async {
    if (_isLoading || _uid.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final query = await FirebaseFirestore.instance
          .collection('recipe')
          .where('likes', arrayContains: _uid)
          .limit(_limit)
          .get();

      setState(() => _likedRecipes = query.docs);
    } catch (e) {
      print('Error loading liked recipes: $e');
    }

    setState(() => _isLoading = false);
  }

  void _toggleLike(DocumentSnapshot recipe) async {
    final docRef = recipe.reference;
    final likes = List<String>.from(recipe['likes'] ?? []);

    if (likes.contains(_uid)) {
      likes.remove(_uid);
    } else {
      likes.add(_uid);
    }

    await docRef.update({'likes': likes});
    _loadLikedRecipes();
  }

  List<DocumentSnapshot> get _filteredRecipes {
    if (_searchText.isEmpty) return _likedRecipes;

    return _likedRecipes.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final nameKo = (data['cockName_ko'] ?? '').toString().toLowerCase();
      final nameEn = (data['cockName'] ?? '').toString().toLowerCase();
      return nameKo.contains(_searchText.toLowerCase()) || nameEn.contains(_searchText.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() => _searchText = value);
            },
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: '좋아요 한 레시피 검색',
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
          child: _isLoading && _likedRecipes.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _filteredRecipes.isEmpty
              ? const Center(
            child: Text(
              '검색 결과가 없습니다.',
              style: TextStyle(color: Colors.white54),
            ),
          )
              : ListView.builder(
            controller: _scrollController,
            itemCount: _filteredRecipes.length + (_isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _filteredRecipes.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final doc = _filteredRecipes[index];
              final recipe = doc.data() as Map<String, dynamic>;

              return GestureDetector(
                onTap: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/recipe/view',
                    arguments: {
                      'recipeId': doc.id,
                      'isCustom': false, // 일반 레시피
                    },
                child: Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        child: Image.network(
                          recipe['c_imgUrl'],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recipe['cockName_ko'] ?? '',
                              style: const TextStyle(fontSize: 16, color: Colors.white),
                            ),
                            Text(
                              "(${recipe['cockName'] ?? ''})",
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.redAccent),
                        onPressed: () => _toggleLike(doc),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
