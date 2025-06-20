import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomIngredientDialog extends StatefulWidget {
  const CustomIngredientDialog({super.key});

  @override
  State<CustomIngredientDialog> createState() => _CustomIngredientDialogState();
}

class _CustomIngredientDialogState extends State<CustomIngredientDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _abvController = TextEditingController();
  bool _isAlcoholic = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _abvController.dispose();
    super.dispose();
  }

  Future<String> _getNextCustomId(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("custom")
        .get();

    int maxIndex = 0;
    for (var doc in snapshot.docs) {
      final id = doc.id;
      if (id.startsWith("custom")) {
        final number = int.tryParse(id.replaceFirst("custom", ""));
        if (number != null && number > maxIndex) {
          maxIndex = number;
        }
      }
    }

    return "custom${maxIndex + 1}";
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final name = _nameController.text.trim();
    final desc = _descriptionController.text.trim();
    final abv = _isAlcoholic ? int.tryParse(_abvController.text.trim()) ?? 0 : 0;

    final ingredientsId = await _getNextCustomId(uid);

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("custom")
        .doc(ingredientsId)
        .set({
      "ingredientsId": ingredientsId,
      "category": "custom",
      "name": name,
      "description": desc,
      "abv": abv,
      "isAlcoholic": _isAlcoholic,
    });

    Navigator.of(context).pop(true); // 등록 완료 시 즉시 반영
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("커스텀 재료 추가"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "재료명을 입력하세요"),
                  validator: (value) =>
                  (value == null || value.trim().isEmpty) ? "재료명을 입력하세요" : null,
                ),
                SizedBox(height: 20,),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: "재료 설명을 입력하세요"),
                  validator: (value) =>
                  (value == null || value.trim().isEmpty) ? "재료 설명을 입력하세요" : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("취소"),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text("추가"),
        ),
      ],
    );
  }
}
