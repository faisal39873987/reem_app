import 'package:flutter/material.dart';

class FeedFilterTabBar extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;
  const FeedFilterTabBar({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final filter = filters[i];
          final selected = filter == selectedFilter;
          return ChoiceChip(
            label: Text(
              filter,
              style: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            selected: selected,
            onSelected: (_) => onFilterSelected(filter),
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
