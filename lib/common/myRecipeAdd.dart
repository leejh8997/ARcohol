import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyRecipeAddPage extends StatefulWidget {
  const MyRecipeAddPage({super.key});

  @override
  State<MyRecipeAddPage> createState() => _MyRecipeAddPageState();
}

class _MyRecipeAddPageState extends State<MyRecipeAddPage> {
  final TextEditingController inputController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();
  final TextEditingController memoController = TextEditingController();
  final List<Map<String, String>> ingredients = [];

  void _addIngredient() {
    final input = inputController.text.trim();
    if (input.isEmpty || !input.contains(' ')) return;
    final parts = input.split(' ');
    setState(() {
      ingredients.add({'name': parts[0], 'amount': parts.sublist(1).join(' ')});
      inputController.clear();
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      ingredients.removeAt(index);
    });
  }

  Future<void> _saveRecipe() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || nameController.text.trim().isEmpty) return;

    final docRef = FirebaseFirestore.instance.collection('customRecipes').doc();
    await docRef.set({
      'customRecipeId': docRef.id,
      'cockName': nameController.text.trim(),
      'ingredients': ingredients
          .map((e) => {'이름': e['name'], '용량': e['amount']})
          .toList(),
      'instructions': instructionsController.text.trim(),
      'memo': memoController.text.trim(),
      'c_imgUrl': 'https://example.com/custom.png',
      'writer': uid,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('레시피가 저장되었습니다!')),
    );
    setState(() {
      inputController.clear();
      nameController.clear();
      instructionsController.clear();
      memoController.clear();
      ingredients.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1F1F1F),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('당신만의 한 잔을 완성해보세요.\n레시피를 직접 등록할 수 있어요.',
              style: TextStyle(color: Colors.white)),
          const Divider(color: Color(0xFFBEB08B)),
          const SizedBox(height: 12),

          // 재료 입력
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: inputController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: '등록할 레시피를 입력해주세요',
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Color(0xFF333333),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Color(0xFFE94E2B)),
                onPressed: _addIngredient,
              )
            ],
          ),
          const SizedBox(height: 16),

          // 카드 영역
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFE94E2B)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: '칵테일 이름을 입력해주세요',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
                const Divider(color: Colors.grey),
                ...ingredients.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final ing = entry.value;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${ing['name']} ${ing['amount']}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => _removeIngredient(idx),
                    ),
                  );
                })
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text('제조법', style: TextStyle(color: Color(0xFFBEB08B))),
          const SizedBox(height: 8),
          TextField(
            controller: instructionsController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: '제조법을 입력하세요',
              hintStyle: TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Color(0xFF333333),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),
          const Text('메모', style: TextStyle(color: Color(0xFFBEB08B))),
          const SizedBox(height: 8),
          TextField(
            controller: memoController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: '메모를 입력하세요',
              hintStyle: TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Color(0xFF333333),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveRecipe,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE94E2B),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Center(child: Text('저장하기')),
          ),
        ],
      ),
    );
  }
}