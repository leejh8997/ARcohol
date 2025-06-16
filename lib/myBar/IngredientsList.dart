import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ingredientsView.dart';
import 'customIngredientDialog.dart';
import 'ingredient_tile.dart';

class IngredientsList extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const IngredientsList({super.key, required this.navigatorKey});

  @override
  State<IngredientsList> createState() => _IngredientsListState();
}

class _IngredientsListState extends State<IngredientsList> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder<QuerySnapshot>(
      key: const ValueKey("ingredients_list"), // 👈 강제 rebuild 트리거용
      stream: FirebaseFirestore.instance
          .collection("ingredients")
          .orderBy("name") // 👈 쿼리 정렬 추가로 캐시 무효화 유도
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("오류 발생", style: TextStyle(color: Colors.red)));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        final alcoholic = _groupCategories(docs, true);
        final nonAlcoholic = _groupCategories(docs, false);

        return ListView(
          children: [
            // 알콜 재료
            ...alcoholic.map((category) => _buildCategoryTile(category, docs)),

            // 구분선
            if (nonAlcoholic.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Divider(color: Colors.white30, thickness: 0.5),
              ),

            // 논알콜 재료
            ...nonAlcoholic.map((category) => _buildCategoryTile(category, docs)),

            const SizedBox(height: 8),
            const Divider(color: Colors.white54),
            _buildAddCustomTile(),
          ],
        );
      },
    );
  }

  List<String> _groupCategories(List<QueryDocumentSnapshot> docs, bool isAlcoholic) {
    final Set<String> categories = {};
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final category = data["category"]?.toString() ?? "기타";
      final alcoholFlag = data["isAlcoholic"] == true;
      if (alcoholFlag == isAlcoholic) {
        categories.add(category);
      }
    }
    final sorted = categories.toList();
    sorted.sort();
    return sorted;
  }

  Widget _buildCategoryTile(String category, List<QueryDocumentSnapshot> docs) {
    return IngredientTile(
      title: category,
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white70),
      onTap: () async {
        await widget.navigatorKey.currentState?.push(
          PageRouteBuilder(
            pageBuilder: (_, animation, __) =>
                IngredientsView(category: category),
            transitionsBuilder: (_, animation, __, child) {
              final tween = Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeInOut));
              return SlideTransition(position: animation.drive(tween), child: child);
            },
          ),
        );

        if (mounted) setState(() {}); // 돌아왔을 때 새로고침
      },
    );
  }

  Widget _buildAddCustomTile() {
    return ListTile(
      leading: const Icon(Icons.add, color: Colors.white),
      title: const Text("커스텀 재료 추가", style: TextStyle(color: Colors.white)),
      onTap: () async {
        final added = await showDialog(
          context: context,
          builder: (_) => const CustomIngredientDialog(),
        );
        if (mounted && added == true) setState(() {}); // optional
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
