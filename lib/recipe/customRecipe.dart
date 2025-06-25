import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomRecipePage extends StatefulWidget {
  const CustomRecipePage({Key? key}) : super(key: key);

  @override
  State<CustomRecipePage> createState() => _CustomRecipePageState();
}

class _CustomRecipePageState extends State<CustomRecipePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();

  List<DocumentSnapshot> _rawDocs = [];
  List<Map<String, dynamic>> _recipes = [];

  DocumentSnapshot? _lastDoc;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadCustomRecipes();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomRecipes() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    Query query = _firestore.collection('customRecipes').orderBy('cockName').limit(10);
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

    for (var doc in newDocs) {
      final data = doc.data() as Map<String, dynamic>;
      newRecipes.add(Map<String, dynamic>.from(data));
    }

    setState(() {
      _rawDocs.addAll(newDocs);
      _recipes.addAll(newRecipes);
      _lastDoc = newDocs.last;
      _isLoading = false;
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadCustomRecipes();
    }
  }

  String _buildIngredientsPreview(dynamic ingredients) {
    if (ingredients is List) {
      final preview = ingredients
          .map((item) => item['name'] ?? '')
          .where((name) => name.toString().isNotEmpty)
          .take(3)
          .join(', ');
      return preview.isNotEmpty ? preview : '재료 정보 없음';
    }
    return '재료 정보 없음';
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
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

        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: const Color(0xFF2B2B2B),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/recipe/view',
                  arguments: {
                    'recipeId': _rawDocs[index].id,
                    'isCustom': true,
                  },
                );
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
                            recipe['cockName'] ?? 'No Name',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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