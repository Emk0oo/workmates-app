import 'package:flutter/material.dart';
import 'dart:io' show Platform;

// http
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:convert';

import 'package:workmates/data/global_data.dart' as gd;
import 'package:workmates/models/Session.dart';



class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => LoadingScreenState();
}

class LoadingScreenState extends State<LoadingScreen> {
  String deviceName = "";
  bool isLoading = false;
  String currentAction = "Initialisation";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      isLoading = true;
      // Load data
      loadSession();
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],

      // Reuse the theme
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingAnimationWidget.threeRotatingDots(
                      color: Theme.of(context).colorScheme.primary, size: 50),
                  const SizedBox(height: 20),
                  Text('Chargement...', style: TextStyle(fontSize: 20)),
                  Text('${currentAction}', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: Center(
              child: Text('© ' + DateTime.now().year.toString() + ' MEV', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loadSession() async {
    try {
      // Effectuer la requête HTTP GET
      final response = await http.get(
        Uri.parse('${gd.serverUrl}/sessions'),
      );

      if (response.statusCode == 200) {
        debugPrint('Response status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');

        // ✅ Décoder directement en List<dynamic>
        List<dynamic> jsonList = jsonDecode(response.body);

        // ✅ Parser chaque élément avec fromJson
        gd.allSessions = jsonList.map((item) => Session.fromJson(item)).toList();

        //attendre 2 secondes
        await Future.delayed(const Duration(seconds: 2));

        // ✅ Naviguer vers /home
        if (mounted) {
          Navigator.pushReplacementNamed(context, "/home");
        }
      } else {
        debugPrint('Error: ${response.body}');
        throw Exception('Failed to load sessions');
      }
    } catch (e) {
      debugPrint('Exception: $e');
      throw Exception('Failed to load sessions');
    }
  }

}

