import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Screen'),
      ),
      body: const Center(
        child: Text('Welcome to the Main Screen!'),
      ),

      // ✅ Bouton flottant
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // 👉 Action à faire quand on clique sur le bouton
          debugPrint('Créer une session cliqué');
          // Par exemple, tu pourrais naviguer vers un écran de création :
          Navigator.pushNamed(context, "/createSession");
        },
        icon: const Icon(Icons.add),
        label: const Text('Créer une session'),
      ),

      // ✅ Position du bouton : centré en bas
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
