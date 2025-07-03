import 'package:flutter/material.dart';
import '../models/seller.dart';

class MessengerBar extends StatelessWidget {
  final Seller seller;
  const MessengerBar({super.key, required this.seller});

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: TextEditingController(
                text:
                    isRTL
                        ? 'مرحباً، هل هذا متوفر؟'
                        : 'Bonjour, cet article est-il disponible ?',
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: isRTL ? 'اكتب رسالة...' : 'Écrire un message...',
              ),
              style: const TextStyle(fontSize: 15),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1877F2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: Text(
              isRTL ? 'إرسال' : 'Envoyer',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
