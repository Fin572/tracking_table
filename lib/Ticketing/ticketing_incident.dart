import 'package:flutter/material.dart';
import 'package:tracking_table/Ticketing/detail_incident.dart';
import 'package:tracking_table/Ticketing/form_incident.dart';
import 'package:tracking_table/Ticketing/history_incident.dart';
import 'package:tracking_table/navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TicketingIncident extends StatelessWidget {
  final Map<String, dynamic> user;
  final int groupId;
  final List<dynamic> organizations;

  const TicketingIncident({
    Key? key,
    required this.user,
    required this.groupId,
    required this.organizations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Incident(
        user: user,
        groupId: groupId,
        organizations: organizations,
      ),
    );
  }
}

class Incident extends StatefulWidget {
  final Map<String, dynamic> user;
  final int groupId;
  final List<dynamic> organizations;

  const Incident({
    Key? key,
    required this.user,
    required this.groupId,
    required this.organizations,
  }) : super(key: key);

  @override
  State<Incident> createState() => _IncidentState();
}

class _IncidentState extends State<Incident> {
  List<Map<String, dynamic>> incidentDataList = [];

  @override
  void initState() {
    super.initState();
    fetchIncidentsFromServer();
  }

  Future<void> fetchIncidentsFromServer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('login'); // Get userId from session

    if (userId != null) {
      final response = await http.post(
        Uri.parse('https://indoguna.info/Datatable/Form/fetchincident.php'),
        body: {
          'user_id': userId,
          'group_id': widget.groupId.toString(), // Send groupId to the server
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            // Directly assign data without filtering here, as filtering will be done in the UI if needed
            incidentDataList = List<Map<String, dynamic>>.from(data);
          });
        } else if (data['error'] != null) {
          print('Error from server: ${data['error']}');
        } else {
          print('Unexpected response: $data');
        }
      } else {
        print('Failed to fetch incident data from server: ${response.body}');
      }
    } else {
      print('User ID not found in shared preferences');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Ticketing'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => MainPage(
                  user: widget.user,
                  groupId: widget.groupId,
                  organizations: widget.organizations,
                ),
              ),
              (Route<dynamic> route) => false,
            );
          },
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'history') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryIncidentPage(
                      user: widget.user,
                      groupId: widget.groupId,
                      organizations: widget.organizations,
                    ),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'history',
                child: Text('History'),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchIncidentsFromServer,
        child: incidentDataList.isNotEmpty
            ? ListView.builder(
                itemCount: incidentDataList.length,
                itemBuilder: (context, index) {
                  final incidentData = incidentDataList[index];

                  // Make all incidents visible if group_id == 1 (admin)
                  final isVisible = widget.groupId == 1 ||
                      widget.user['login'] == incidentData['added_by'] ||
                      widget.user['login'] == incidentData['worker_id'];

                  return Visibility(
                    visible: isVisible,
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          'Incident: ${incidentData['Title']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Added At: ${incidentData['added_at']}'),
                            Text('Status: ${incidentData['Status']}'),
                            const SizedBox(height: 8),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailIncidentPage(
                                formData: incidentData,
                                onStatusChanged: () async {
                                  await fetchIncidentsFromServer();
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              )
            : const Center(child: Text('No incident data submitted!')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigasi ke halaman form
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IncidentTaskFormPage(),
            ),
          );

          // Panggil kembali data dari server
          await fetchIncidentsFromServer();

          // Tampilkan pesan menggunakan SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Form sudah ditambahkan'),
              duration: Duration(seconds: 3),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
