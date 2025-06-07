import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const blueColor = Color(0xFF1877F2);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final TextEditingController nameController = TextEditingController(text: user.displayName ?? '');
    final TextEditingController emailController = TextEditingController(text: user.email ?? '');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'My Account',
          style: TextStyle(color: blueColor),
        ),
        iconTheme: const IconThemeData(color: blueColor),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: blueColor,
              child: Icon(Icons.person, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            const Text("Full Name", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: "Enter your full name",
              ),
            ),
            const SizedBox(height: 16),
            const Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: emailController,
              readOnly: true,
              decoration: const InputDecoration(
                hintText: "Enter your email",
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: blueColor,
                ),
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await user.updateDisplayName(nameController.text.trim());
                    await user.reload();

                    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                      'name': nameController.text.trim(),
                      'email': user.email,
                      'updatedAt': Timestamp.now(),
                    }, SetOptions(merge: true));

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Changes saved.')),
                    );
                  }
                },
                child: const Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
