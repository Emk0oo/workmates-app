import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:workmates/models/Session.dart';
import 'package:workmates/data/global_data.dart';
import 'package:workmates/screens/loginScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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

  Future<void> _deleteSession(int sessionId) async {
    try {
      final response = await http.delete(
        Uri.parse('$serverUrl/sessions/$sessionId'),
      );

      if (response.statusCode == 204) {
        debugPrint('Session supprimée avec succès. Pour l id $sessionId');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session supprimée avec succès')),
        );
        // Rafraîchir la liste après suppression
        await _fetchSessions();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression : ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion : $e')),
      );
    }
  }

  void _showDeleteConfirmationDialog(Session session) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text(
              'Êtes-vous sûr de vouloir supprimer la session "${session.name}" ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteSession(session.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  final DateFormat backendDateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');


  Future<void> _updateSession(Session session) async {
    try {

      debugPrint('Session à modifier : ${session.id}');


      // Convertir l'objet Session en JSON
      final String sessionJson = jsonEncode({
        'id': session.id,
        'nom': session.name,
        'adresse_numero': session.addressNumber,
        'adresse_rue': session.streetName,
        'code_postal': session.zipCode,
        'ville': session.city,
        'date_debut': backendDateFormat.format(session.startDate), // Format correct
        'date_fin': backendDateFormat.format(session.endDate),     // Format correct
      });


      final response = await http.put(
        Uri.parse('$serverUrl/sessions/${session.id}'),
        headers: {'Content-Type': 'application/json'},
        body: sessionJson,
      );
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');


      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session modifiée avec succès')),
        );
        await _fetchSessions();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la modification : ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion : $e')),
      );
    }
  }
  void _showEditModal(Session session) {
    final TextEditingController nameController =
    TextEditingController(text: session.name);
    final TextEditingController addressNumberController =
    TextEditingController(text: session.addressNumber.toString());
    final TextEditingController streetNameController =
    TextEditingController(text: session.streetName);
    final TextEditingController zipCodeController =
    TextEditingController(text: session.zipCode.toString());
    final TextEditingController cityController =
    TextEditingController(text: session.city);

    DateTime startDate = session.startDate;
    DateTime endDate = session.endDate;

    Future<void> _selectDate(BuildContext context, bool isStartDate) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: isStartDate ? startDate : endDate,
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      );

      if (picked != null) {
        final TimeOfDay? timePicked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(
              isStartDate ? startDate : endDate),
        );

        if (timePicked != null) {
          setState(() {
            final DateTime newDateTime = DateTime(
              picked.year,
              picked.month,
              picked.day,
              timePicked.hour,
              timePicked.minute,
            );

            if (isStartDate) {
              startDate = newDateTime;
              if (endDate.isBefore(startDate)) {
                endDate = startDate.add(const Duration(hours: 1));
              }
            } else {
              endDate = newDateTime;
            }
          });
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Modifier la session',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nom de la session'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: TextField(
                      controller: addressNumberController,
                      decoration: const InputDecoration(labelText: 'N°'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    flex: 2,
                    child: TextField(
                      controller: streetNameController,
                      decoration: const InputDecoration(labelText: 'Rue'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: TextField(
                      controller: zipCodeController,
                      decoration: const InputDecoration(labelText: 'Code postal'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    flex: 2,
                    child: TextField(
                      controller: cityController,
                      decoration: const InputDecoration(labelText: 'Ville'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ListTile(
                title: Text(
                  'Début : ${DateFormat('dd/MM/yyyy • HH:mm').format(startDate)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              ListTile(
                title: Text(
                  'Fin : ${DateFormat('dd/MM/yyyy • HH:mm').format(endDate)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  final updatedSession = Session(
                    id: session.id,
                    name: nameController.text,
                    addressNumber: addressNumberController.text,
                    streetName: streetNameController.text,
                    zipCode: zipCodeController.text,
                    city: cityController.text,
                    startDate: startDate,
                    endDate: endDate,
                  );
                  _updateSession(updatedSession);
                },
                child: const Text('Enregistrer les modifications'),
              ),
            ],
          ),
        );
      },
    );
  }


  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy • HH:mm').format(date);
  }

  void _logout() {
    // Réinitialiser le token
    appToken = "";

    // Alternative pour naviguer vers l'écran de connexion
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sessions de travail'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchSessions,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Déconnexion',
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
              style: ElevatedButton.styleFrom(
                backgroundColor:
                Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      )
          : allSessions.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune session disponible',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Créez une nouvelle session pour commencer',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _fetchSessions,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: allSessions.length,
          itemBuilder: (context, index) {
            final session = allSessions[index] as Session;
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          session.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Column(

                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.blue),
                              onPressed: () => _showEditModal(session),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () =>
                                  _showDeleteConfirmationDialog(
                                      session),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 18,
                            color: Theme.of(context)
                                .colorScheme
                                .primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${session.addressNumber} ${session.streetName}, ${session.zipCode} ${session.city}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 18,
                            color: Theme.of(context)
                                .colorScheme
                                .primary),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(session.startDate),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time_filled,
                            size: 18,
                            color: Theme.of(context)
                                .colorScheme
                                .primary),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(session.endDate),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, "/createSession").then((_) {
            _fetchSessions();
          });
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add),
        label: const Text('Créer une session'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}