import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:workmates/models/Session.dart';
import 'package:workmates/data/global_data.dart';

class SessionsView extends StatefulWidget {
  const SessionsView({Key? key}) : super(key: key);

  @override
  _SessionsViewState createState() => _SessionsViewState();
}

class _SessionsViewState extends State<SessionsView> {
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchSessions();
  }

  Future<void> _fetchSessions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse('$serverUrl/sessions'));

      if (response.statusCode == 200) {
        final List<dynamic> sessionsJson = jsonDecode(response.body);
        setState(() {
          allSessions =
              sessionsJson.map((json) => Session.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Erreur lors du chargement des sessions: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de connexion: $e';
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sessions de travail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchSessions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchSessions,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : allSessions.isEmpty
                  ? const Center(child: Text('Aucune session disponible'))
                  : RefreshIndicator(
                      onRefresh: _fetchSessions,
                      child: ListView.builder(
                        itemCount: allSessions.length,
                        itemBuilder: (context, index) {
                          final session = allSessions[index] as Session;
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    session.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Adresse: ${session.addressNumber} ${session.streetName}, ${session.zipCode} ${session.city}',
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Début: ${_formatDate(session.startDate)}',
                                  ),
                                  Text(
                                    'Fin: ${_formatDate(session.endDate)}',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigation vers la page de création de session (à implémenter)
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
