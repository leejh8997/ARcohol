import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyRecipeEditPage extends StatefulWidget {
  final Map<String, dynamic> recipeData;
  final String docId;

  const MyRecipeEditPage({super.key, required this.recipeData, required this.docId});

  @override
  State<MyRecipeEditPage> createState() => _MyRecipeEditPageState();
}

class _MyRecipeEditPageState extends State<MyRecipeEditPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();
  final TextEditingController memoController = TextEditingController();

  List<Map<String, TextEditingController>> ingredientControllers = [];

  @override
  void initState() {
    super.initState();
    final data = widget.recipeData;

    nameController.text = data['cockName'] ?? '';
    instructionsController.text = data['instructions'] ?? '';
    memoController.text = data['memo'] ?? '';

    final ingredients = data['ingredients'] as List<dynamic>? ?? [];
    ingredientControllers = ingredients.map((e) {
      return {
        'name': TextEditingController(text: e['name'] ?? ''),
        'amount': TextEditingController(text: '${e['amount'] ?? ''}'),
      };
    }).toList();

    // 없을 경우 최소 1줄
    if (ingredientControllers.isEmpty) {
      ingredientControllers.add({
        'name': TextEditingController(),
        'amount': TextEditingController(),
      });
    }
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

  Future<void> _updateRecipe() async {
    final ingredients = getParsedIngredients();
    if (nameController.text.trim().isEmpty || ingredients.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('customRecipes')
        .doc(widget.docId)
        .update({
      'cockName': nameController.text.trim(),
      'ingredients': ingredients,
      'instructions': instructionsController.text.trim(),
      'memo': memoController.text.trim(),
    });

    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('레시피가 수정되었습니다!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: AppBar(
        title: const Text('레시피 수정'),
        backgroundColor: const Color(0xFF1F1F1F),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
                    IconButton(
                      onPressed: () => _removeIngredientField(index),
                      icon: const Icon(Icons.remove_circle, color: Colors.grey),
                    )
                  ],
                ),
              );
            }),
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
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: '칵테일 이름',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Color(0xFF333333),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('제조법', style: TextStyle(color: Color(0xFFBEB08B), fontSize: 16)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: instructionsController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: '제조법',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Color(0xFF333333),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('메모', style: TextStyle(color: Color(0xFFBEB08B), fontSize: 16)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: memoController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: '메모',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Color(0xFF333333),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateRecipe,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94E2B),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Center(child: Text('수정 완료')),
            ),
            const SizedBox(height: 12),
            // ✅ 삭제 버튼 추가
            ElevatedButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF333333),
                    title: const Text('레시피 삭제', style: TextStyle(color: Colors.white)),
                    content: const Text('정말 이 레시피를 삭제하시겠습니까?', style: TextStyle(color: Colors.white70)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('취소', style: TextStyle(color: Colors.grey)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('삭제', style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await FirebaseFirestore.instance
                      .collection('customRecipes')
                      .doc(widget.docId)
                      .delete();

                  if (mounted) {
                    Navigator.pop(context, true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('레시피가 삭제되었습니다.')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Center(
                child: Text('레시피 삭제', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}