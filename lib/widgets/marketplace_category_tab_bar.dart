import 'package:flutter/material.dart';

class MarketplaceCategoryTabBar extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  const MarketplaceCategoryTabBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = categories[i];
          final selected = cat == selectedCategory;
          return ChoiceChip(
            label: Text(
              cat,
              style: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            selected: selected,
            onSelected: (_) => onCategorySelected(cat),
            selectedColor: Theme.of(
              context,
            ).primaryColor.withValues(alpha: 0.15),
            backgroundColor: Colors.grey[100],
            labelStyle: TextStyle(
              color: selected ? Theme.of(context).primaryColor : Colors.black87,
            ),
          );
        },
      ),
    );
  }
}
