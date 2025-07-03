import 'package:flutter/material.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});
  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _publishing = false;

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final String title = isRTL ? 'إنشاء منشور' : 'Créer une publication';
    final String placeholder =
        isRTL ? 'بم تفكر؟' : 'Qu\'est-ce que vous pensez ?';
    final String addPhoto = isRTL ? 'إضافة صورة' : 'Ajouter une photo';
    final String publish = isRTL ? 'نشر' : 'Publier';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
            tooltip: isRTL ? 'إلغاء' : 'Annuler',
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: AssetImage('assets/images/default_user.png'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    minLines: 2,
                    style: const TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      hintText: placeholder,
                      hintStyle: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.photo_library, color: Color(0xFF1877F2)),
              label: Text(
                addPhoto,
                style: const TextStyle(
                  color: Color(0xFF1877F2),
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF1877F2)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 18,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed:
                    _publishing
                        ? null
                        : () async {
                          setState(() => _publishing = true);
                          await Future.delayed(const Duration(seconds: 1));
                          setState(() => _publishing = false);
                          Navigator.pop(context);
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1877F2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  elevation: 0,
                ),
                child:
                    _publishing
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(publish),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
