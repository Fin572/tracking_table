import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistoryPage extends StatefulWidget {
  final Map<String, dynamic> user;
  final int groupId;
  final List<dynamic> organizations;

  const HistoryPage({
    Key? key,
    required this.user,
    required this.groupId,
    required this.organizations,
  }) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> historyDataList = [];
  bool isLoading = true; // Untuk menunjukkan loading spinner

  @override
  void initState() {
    super.initState();
    fetchHistoryFromServer();
  }

  Future<void> fetchHistoryFromServer() async {
    try {
      // Ambil user_id dan group_id dari widget
      final String userId = widget.user['login'];
      final int groupId = widget.groupId;

      // Panggil API dengan parameter user_id dan group_id
      final response = await http.post(
        Uri.parse('http://192.168.252.28/Datatable/Form/Fetch/fetchhistory.php'),
        body: {
          'user_id': userId,
          'group_id': groupId.toString(),
        },
      );

      if (response.statusCode == 200) {
        // Decode JSON jika berhasil
        List<dynamic> data = json.decode(response.body);
        setState(() {
          historyDataList = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        // Tampilkan pesan kesalahan jika gagal
        print('Failed to fetch history data: ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // Tangkap kesalahan koneksi
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(), // Spinner saat loading
            )
          : historyDataList.isNotEmpty
              ? ListView.builder(
                  itemCount: historyDataList.length,
                  itemBuilder: (context, index) {
                    final historyData = historyDataList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          'Request: ${historyData['Title']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Added At: ${historyData['added_at']}'),
                            Text('Status: ${historyData['Status']}'),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text('No history available!'),
                ),
    );
  }
}
