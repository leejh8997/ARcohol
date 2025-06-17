import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RecipeViewPage extends StatefulWidget {
  final String recipeId;

  const RecipeViewPage({super.key, required this.recipeId});

  @override
  State<RecipeViewPage> createState() => _RecipeViewPageState();
}

class _RecipeViewPageState extends State<RecipeViewPage> {
  bool isLoading = true;
  Map<String, dynamic>? recipe;
  bool isLiked = false;
  bool _didLikeChange = false; // ✅ 여기에 선언해야 함 (State 클래스 내부)

  @override
  void initState() {
    super.initState();
    _fetchRecipe();
  }

  Future<void> _fetchRecipe() async {
    final doc = await FirebaseFirestore.instance.collection("recipe").doc(widget.recipeId).get();

    if (doc.exists) {
      final data = doc.data()!;
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final likedList = List<String>.from(data['likes'] ?? []);
      setState(() {
        recipe = data;
        isLiked = likedList.contains(uid);
        isLoading = false;
      });
    }
  }

  Future<void> _toggleLike() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || recipe == null) return;

    final recipeRef = FirebaseFirestore.instance.collection("recipe").doc(widget.recipeId);
    final userRef = FirebaseFirestore.instance.collection("users").doc(uid);

    List<String> likedList = List<String>.from(recipe!['likes'] ?? []);
    List<String> userLikes = [];

    final userDoc = await userRef.get();
    if (userDoc.exists) {
      userLikes = List<String>.from(userDoc['likes'] ?? []);
    }

    if (isLiked) {
      likedList.remove(uid);
      userLikes.remove(widget.recipeId);
    } else {
      likedList.add(uid);
      userLikes.add(widget.recipeId);
    }

    await Future.wait([
      recipeRef.update({'likes': likedList}),
      userRef.update({'likes': userLikes}),
    ]);

    setState(() {
      isLiked = !isLiked;
      _didLikeChange = true; // ✅ 변경 표시
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || recipe == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF1F1F1F),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _didLikeChange); // ✅ 좋아요 변경 여부 전달
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("레시피 상세"),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        backgroundColor: const Color(0xFF1F1F1F),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이미지
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  recipe!['c_imgUrl'] ?? '',
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),

              // 칵테일 이름 + 좋아요
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "${recipe!['cockName_ko'] ?? ''} (${recipe!['cockName'] ?? ''})",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.redAccent : Colors.grey,
                    ),
                    onPressed: _toggleLike,
                  )
                ],
              ),
              const SizedBox(height: 8),

              // 작성자
              if ((recipe!['writer'] ?? '').isNotEmpty)
                Text(
                  "by ${recipe!['writer']}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),

              const SizedBox(height: 16),

              // 설명
              Text(
                recipe!['description'] ?? '',
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),

              const SizedBox(height: 24),

              // 재료
              const Text("재료", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              ...List<Widget>.from((recipe!['ingredients'] as List).map((ing) {
                final Map<String, dynamic> i = Map<String, dynamic>.from(ing);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    "- ${i['name']} : ${i['amount']}",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                );
              })),

              const SizedBox(height: 24),

              // 제조 방법
              const Text("제조 방법", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Text(
                recipe!['instructions'] ?? '',
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
