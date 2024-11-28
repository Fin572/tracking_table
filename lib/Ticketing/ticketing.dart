import 'package:flutter/material.dart';
import 'package:tracking_table/Ticketing/detail_ticketing.dart';
import 'package:tracking_table/Ticketing/form.dart';
import 'package:tracking_table/navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TicketingApp extends StatelessWidget {
  final Map<String, dynamic> user;
  final int groupId;
  final List<dynamic> organizations;

  const TicketingApp({
    Key? key,
    required this.user,
    required this.groupId,
    required this.organizations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Ticketing(
        user: user,
        groupId: groupId,
        organizations: organizations,
      ),
    );
  }
}

class Ticketing extends StatefulWidget {
  final Map<String, dynamic> user;
  final int groupId;
  final List<dynamic> organizations;

  const Ticketing({
    Key? key,
    required this.user,
    required this.groupId,
    required this.organizations,
  }) : super(key: key);

  @override
  State<Ticketing> createState() => _TicketingState();
}

class _TicketingState extends State<Ticketing> {
  List<Map<String, dynamic>> formDataList = [];

  @override
  void initState() {
    super.initState();
    fetchFormsFromServer(); // Ambil data dari server
  }

  // Mengambil form dari server berdasarkan added_by atau worker_id
  Future<void> fetchFormsFromServer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId =
        prefs.getString('login'); // Ambil login sebagai userId dari session

    if (userId != null) {
      // Kirim permintaan ke server untuk mengambil data form berdasarkan user yang mengisi (added_by) atau worker yang di-assign
      final response = await http.post(
        Uri.parse('http://192.168.252.28/Datatable/Form/fetchforms.php'),
        body: {'user_id': userId},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print('Data fetched: $data'); // Debug respons dari server
        setState(() {
          formDataList = List<Map<String, dynamic>>.from(data);
        });
      } else {
        print('Failed to fetch form data from server: ${response.body}');
      }
    } else {
      print('User ID not found in shared preferences');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticketing'),
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
      body: formDataList.isNotEmpty
          ? ListView.builder(
              itemCount: formDataList.length,
              itemBuilder: (context, index) {
                final formData = formDataList[index];
                // Gunakan Visibility widget untuk mengontrol apakah ListTile ditampilkan
                return Visibility(
                  visible: (widget.user['login'] == formData['added_by'] ||
                      widget.user['login'] == formData['worker_id']),
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        'Request: ${formData['Title']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Added At: ${formData['added_at']}'),
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
                                  formData, // Kirim data form yang dipilih
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            )
          : const Center(child: Text('No data submitted!')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigasi ke halaman form untuk menambahkan form baru
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskFormPage(),
            ),
          );
          // Setelah kembali dari form, ambil ulang data form dari server
          fetchFormsFromServer();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
