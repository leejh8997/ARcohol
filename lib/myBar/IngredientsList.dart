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
  final Map<String, List<String>> alcoholGroups = {
    "리큐르 & 향신료": ["리큐르", "비터스"],
    "럼 계열": ["럼"],
    "클리어 증류주": ["보드카", "진"],
    "숙성 증류주": ["브랜디", "위스키"],
    "고도 증류주": ["데킬라"],
    "발효주": ["와인", "맥주"],
    "전통 증류": ["증류주", "기타주류"],
  };

  final List<String> nonAlcoholGroupOrder = ["음료", "감미료", "팬트리"];

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("ingredients").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("오류 발생", style: TextStyle(color: Colors.red)));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        final List<Widget> children = [];

        // 알코올 그룹 처리
        final alcoholGroupKeys = alcoholGroups.keys.toList();
        for (int i = 0; i < alcoholGroupKeys.length; i++) {
          final groupName = alcoholGroupKeys[i];
          final categories = alcoholGroups[groupName]!;

          // 해당 그룹에 포함된 실제 재료가 있는지 확인
          final hasData = docs.any((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return categories.contains(data["category"]);
          });

          if (hasData) {
            for (final category in categories) {
              final matchedDocs = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data["category"] == category;
              }).toList();

              if (matchedDocs.isNotEmpty) {
                children.add(_buildCategoryTile(category));
              }
            }

            // 다음 그룹과 구분선
            if (i != alcoholGroupKeys.length - 1) {
              children.add(const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Divider(color: Colors.white30, thickness: 0.5),
              ));
            }
          }
        }

        // 비알콜 그룹 구분선
        children.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Divider(color: Colors.white30, thickness: 0.5),
        ));

        // 비알콜 처리
        for (final category in nonAlcoholGroupOrder) {
          final matchedDocs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data["category"] == category;
          }).toList();

          if (matchedDocs.isNotEmpty) {
            children.add(_buildCategoryTile(category));
          }
        }

        children.add(const SizedBox(height: 8));
        children.add(const Divider(color: Colors.white54));
        children.add(_buildAddCustomTile());

        return ListView(children: children);
      },
    );
  }

  Widget _buildCategoryTile(String category) {
    return IngredientTile(
      title: category,
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white70),
      onTap: () async {
        await widget.navigatorKey.currentState?.push(
          PageRouteBuilder(
            pageBuilder: (_, animation, __) => IngredientsView(category: category),
            transitionsBuilder: (_, animation, __, child) {
              final tween = Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeInOut));
              return SlideTransition(position: animation.drive(tween), child: child);
            },
          ),
        );

        if (mounted) setState(() {});
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
        if (mounted && added == true) setState(() {});
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
