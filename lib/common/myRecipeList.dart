import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'myRecipeEdit.dart';

class MyRecipeListPage extends StatelessWidget {
  const MyRecipeListPage({super.key});

  Future<String?> _getCurrentUserId() async {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getCurrentUserId(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final uid = snapshot.data!;
        return Scaffold(
          backgroundColor: const Color(0xFF1F1F1F),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('customRecipes')
                .where('writer', isEqualTo: uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return const Center(
                  child: Text(
                    '작성한 레시피가 없습니다.',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  return _buildRecipeCard(context, data);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildRecipeCard(BuildContext context, Map<String, dynamic> data) {
    final name = data['cockName'] ?? '';
    final memo = data['memo'] ?? '';
    final ingredients = data['ingredients'] as List<dynamic>? ?? [];
    final ingredientSummary = ingredients.map((e) => e['name']).join(', ');
    final imageUrl = (data['c_imgUrl'] != null && data['c_imgUrl'].toString().isNotEmpty)
        ? data['c_imgUrl']
        : 'https://firebasestorage.googleapis.com/v0/b/arcohol-20250609.firebasestorage.app/o/recipe%2Fcustom.png?alt=media';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover),
        ),
        title: Text(
          name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          ingredientSummary,
          style: const TextStyle(color: Colors.grey),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.edit, color: Color(0xFFE94E2B)),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MyRecipeEditPage(
                recipeData: data,
                docId: data['recipeId'],
              ),
            ),
          );
        },
      ),
    );
  }
}