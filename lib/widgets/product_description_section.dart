import 'package:flutter/material.dart';

class ProductDescriptionSection extends StatefulWidget {
  final String description;
  const ProductDescriptionSection({super.key, required this.description});

  @override
  State<ProductDescriptionSection> createState() =>
      _ProductDescriptionSectionState();
}

class _ProductDescriptionSectionState extends State<ProductDescriptionSection> {
  bool _expanded = false;
  static const int _maxLength = 180;
  @override
  Widget build(BuildContext context) {
    final desc = widget.description;
    final isLong = desc.length > _maxLength;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _expanded || !isLong ? desc : '${desc.substring(0, _maxLength)}...',
            style: const TextStyle(fontSize: 15, color: Colors.black),
          ),
          if (isLong)
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _expanded
                      ? (Directionality.of(context) == TextDirection.rtl
                          ? 'عرض أقل'
                          : 'Voir moins')
                      : (Directionality.of(context) == TextDirection.rtl
                          ? 'عرض المزيد'
                          : 'Voir plus'),
                  style: const TextStyle(
                    color: Color(0xFF1877F2),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
