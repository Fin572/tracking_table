import 'package:flutter/material.dart';
import 'package:tracking_table/Ticketing/detail_ticketing.dart';
import 'package:tracking_table/Ticketing/form_incident.dart';
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

  // Mengambil data incident dari server berdasarkan added_by atau worker_id
  Future<void> fetchIncidentsFromServer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId =
        prefs.getString('login'); // Ambil login sebagai userId dari session

    if (userId != null) {
      // Kirim permintaan ke server untuk mengambil data incident berdasarkan user yang mengisi (added_by) atau worker yang di-assign
      final response = await http.post(
        Uri.parse('https://indoguna.info/Datatable/Form/fetchincident.php'),
        body: {'user_id': userId},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print('Data fetched: $data'); // Debug respons dari server
        setState(() {
          incidentDataList = List<Map<String, dynamic>>.from(data);
        });
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
      ),
      body: incidentDataList.isNotEmpty
          ? ListView.builder(
              itemCount: incidentDataList.length,
              itemBuilder: (context, index) {
                final incidentData = incidentDataList[index];
                // Gunakan Visibility widget untuk mengontrol apakah ListTile ditampilkan
                return Visibility(
                  visible: (widget.user['login'] == incidentData['added_by'] ||
                      widget.user['login'] == incidentData['worker_id']),
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          const SizedBox(height: 8),
                        ],
                      ),
                      isThreeLine: true,
                      onTap: () {
                        // Navigasi ke halaman detail ticketing
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailTicketingPage(
                              formData:
                                  incidentData, // Kirim data incident yang dipilih
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigasi ke halaman form untuk menambahkan incident baru
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IncidentTaskFormPage(),
            ),
          );
          // Setelah kembali dari form, ambil ulang data incident dari server
          fetchIncidentsFromServer();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
