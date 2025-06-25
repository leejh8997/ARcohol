import 'package:flutter/material.dart';

class IngredientTile extends StatelessWidget {
  final String title;
  final String? description; // ⬅️ 추가
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool compact;
  final Color? tileColor;

  const IngredientTile({
    super.key,
    required this.title,
    this.description, // ⬅️ 추가
    this.trailing,
    this.onTap,
    this.compact = false,
    this.tileColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: compact
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 6)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 2)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: tileColor ?? const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (description != null && description!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        description!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
