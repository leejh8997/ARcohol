import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyRecipeAddPage extends StatefulWidget {
  const MyRecipeAddPage({super.key});

  @override
  State<MyRecipeAddPage> createState() => _MyRecipeAddPageState();
}

class _MyRecipeAddPageState extends State<MyRecipeAddPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();
  final TextEditingController memoController = TextEditingController();

  List<Map<String, TextEditingController>> ingredientControllers = [
    {
      'name': TextEditingController(),
      'amount': TextEditingController(),
    }
  ];

  List<Map<String, dynamic>> getParsedIngredients() {
    List<Map<String, dynamic>> parsed = [];
    double total = 0;

    for (var map in ingredientControllers) {
      final name = map['name']!.text.trim();
      final amountText = map['amount']!.text.trim();

      final numeric = double.tryParse(amountText.replaceAll(RegExp(r'[^0-9.]'), ''));

      if (name.isNotEmpty && amountText.isNotEmpty && numeric != null && numeric > 0) {
        parsed.add({'name': name, 'amount': amountText});
        total += numeric;
      }
    }

    for (var item in parsed) {
      final numeric = double.tryParse(item['amount'].toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      item['ratio'] = total > 0 ? double.parse((numeric / total).toStringAsFixed(3)) : 0.0;
    }

    return parsed;
  }

  void _addIngredientField() {
    setState(() {
      ingredientControllers.add({
        'name': TextEditingController(),
        'amount': TextEditingController(),
      });
    });
  }

  void _removeIngredientField(int index) {
    setState(() {
      ingredientControllers.removeAt(index);
    });
  }

  Future<void> _saveRecipe() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final ingredients = getParsedIngredients();

    if (uid == null || nameController.text.trim().isEmpty || ingredients.isEmpty) return;

    final docRef = FirebaseFirestore.instance.collection('customRecipes').doc();

    await docRef.set({
      'recipeId': docRef.id,
      'cockName': nameController.text.trim(),
      'ingredients': ingredients,
      'instructions': instructionsController.text.trim(),
      'memo': memoController.text.trim(),
      'c_imgUrl': 'https://firebasestorage.googleapis.com/v0/b/arcohol-20250609.firebasestorage.app/o/recipe%2Fcustom.png?alt=media',
      'writer': uid,
      'isCustom': true,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('레시피가 저장되었습니다!')),
    );

    // 초기화
    nameController.clear();
    instructionsController.clear();
    memoController.clear();
    setState(() {
      ingredientControllers = [
        {'name': TextEditingController(), 'amount': TextEditingController()}
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1F1F1F),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('당신만의 한 잔을 완성해보세요.\n레시피를 직접 등록할 수 있어요.',
                style: TextStyle(color: Colors.white)),
            const Divider(color: Color(0xFFBEB08B)),
            const SizedBox(height: 12),

            // 재료 입력 필드 반복
            ...ingredientControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final map = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: map['name'],
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: '이름',
                          labelStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Color(0xFF333333),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: map['amount'],
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: '용량',
                          labelStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Color(0xFF333333),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _removeIngredientField(index),
                      icon: const Icon(Icons.remove_circle, color: Colors.grey),
                    )
                  ],
                ),
              );
            }),

            // 재료 입력 추가 버튼
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _addIngredientField,
                icon: const Icon(Icons.add, color: Color(0xFFE94E2B)),
                label: const Text('재료 추가', style: TextStyle(color: Color(0xFFE94E2B))),
              ),
            ),

            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('칵테일명', style: TextStyle(color: Color(0xFFBEB08B), fontSize: 16)),
            ),
            const SizedBox(height: 16),
            // 칵테일 이름
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: '칵테일 이름을 입력해주세요',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Color(0xFF333333),
                border: OutlineInputBorder(),
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
      ),
    );
  }
}