import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductActionRow extends StatelessWidget {
  final Product product;
  const ProductActionRow({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final actions = [
      _Action(Icons.notifications_none, isRTL ? 'تنبيه' : 'Alerte'),
      _Action(Icons.message, isRTL ? 'رسالة' : 'Message'),
      _Action(Icons.share_outlined, isRTL ? 'مشاركة' : 'Partager'),
      _Action(Icons.bookmark_border, isRTL ? 'حفظ' : 'Enregistrer'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:
            actions
                .map(
                  (a) => Column(
                    children: [
                      InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(a.icon, color: Colors.black, size: 24),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        a.label,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
      ),
    );
  }
}

class _Action {
  final IconData icon;
  final String label;
  _Action(this.icon, this.label);
}
