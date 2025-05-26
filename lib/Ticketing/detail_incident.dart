import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DetailIncidentPage extends StatefulWidget {
  final Map<String, dynamic> formData;

  const DetailIncidentPage(
      {Key? key,
      required this.formData,
      required Future<Null> Function() onStatusChanged})
      : super(key: key);

  @override
  _DetailIncidentPageState createState() => _DetailIncidentPageState();
}

class _DetailIncidentPageState extends State<DetailIncidentPage> {
  String? selectedStatus;
  int? groupId;
  List<String> statuses = [];

  Future<void> fetchStatuses() async {
    final url = Uri.parse(
        'https://192.168.100.137/Datatable/Form/Fetch/fetch_s_incident.php'); // Update sesuai endpoint
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        setState(() {
          statuses = List<String>.from(data['enums']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${data['message']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch statuses from server.')),
      );
    }
  }

  Future<void> saveStatus() async {
    final url = Uri.parse(
        'https://192.168.100.137/Datatable/Form/Fetch/status_incident.php'); // Update sesuai endpoint
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'id': widget.formData['IncidentID'].toString(),
        'status': selectedStatus,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status berhasil disimpan!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan status: ${data['message']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghubungi server.')),
      );
    }
  }

  Future<String> fetchCallerName(String callerId) async {
    final response = await http.get(
      Uri.parse(
          'https://192.168.100.137/Datatable/Form/Fetch/fetch_callers.php?caller=$callerId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['Name'] ?? 'Unknown';
    } else {
      throw Exception('Failed to load caller name');
    }
  }

  Future<String> fetchOrganizationName(String organizationId) async {
    final response = await http.get(
      Uri.parse(
          'https://192.168.100.137/Datatable/Form/Fetch/fetch_organization.php?organization=$organizationId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['Name'] ?? 'Unknown';
    } else {
      throw Exception('Failed to load organization name');
    }
  }

  Future<String> fetchLocationName(String locationId) async {
    final response = await http.get(
      Uri.parse(
          'https://192.168.100.137/Datatable/Form/Fetch/fetch_location.php?location=$locationId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['Name'] ?? 'Unknown';
    } else {
      throw Exception('Failed to load location name');
    }
  }

  Future<void> fetchGroupId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      groupId = prefs.getInt('group_id'); // Ambil group_id dari sesi
      print(
          'Fetched group_id: $groupId'); // Debugging untuk memastikan nilai group_id
      if (groupId == null) {
        print('Group ID is null. Cannot prefill form.');
      } else if (groupId! > 3) {
        print('Group ID is valid. Prefilling form...');
      } else {
        print('Group ID is less than or equal to 3. No prefill needed.');
      }
    } catch (e) {
      print('Error fetching group_id: $e');
    }
  }

  Future<String> fetchServiceName(String smService) async {
    final response = await http.get(
      Uri.parse(
          'https://192.168.100.137/Datatable/Form/Fetch/fetch_service.php?service=$smService'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['Name'] ?? 'Unknown';
    } else {
      throw Exception('Failed to load service name');
    }
  }

  Future<String> fetchDeviceName(String deviceId) async {
    final response = await http.get(
      Uri.parse(
          'https://192.168.100.137/Datatable/Form/Fetch/fetch_device.php?device=$deviceId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['name'] ?? 'Unknown';
    } else {
      throw Exception('Failed to load device name');
    }
  }

  Future<void> deleteIncident() async {
    final url = Uri.parse(
        'https://192.168.100.137/Datatable/Form/Fetch/delete_f_incident.php'); // Update sesuai endpoint
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'id': widget.formData['IncidentID'].toString()},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Incident berhasil dihapus!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal menghapus incident: ${data['message']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghubungi server.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchGroupId();
    fetchStatuses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Incident Detail'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            tooltip: 'Hapus Form',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Konfirmasi Hapus'),
                  content: Text('Apakah Anda yakin ingin menghapus data ini?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        deleteIncident();
                      },
                      child:
                          Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            statuses.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        filled: groupId != null && groupId! > 3,
                        fillColor: groupId != null && groupId! > 3
                            ? Colors.grey.shade200
                            : null,
                      ),
                      value: selectedStatus,
                      items: statuses.map((status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (groupId != null && groupId! > 3)
                          ? null
                          : (value) {
                              setState(() {
                                selectedStatus = value;
                              });
                            },
                      validator: (value) => (groupId != null && groupId! > 3)
                          ? null
                          : (value == null ? 'Please select a status' : null),
                    ),
                  ),
            _buildDetailFormField('Title', widget.formData['Title']),
            _buildDetailFormField(
                'Description', widget.formData['Description']),
            FutureBuilder(
              future: fetchOrganizationName(
                  widget.formData['OrganizationID'].toString()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return _buildDetailFormField('Organization', 'Error');
                } else {
                  return _buildDetailFormField(
                      'Organization', snapshot.data ?? 'Unknown');
                }
              },
            ),
            FutureBuilder(
              future:
                  fetchLocationName(widget.formData['location_id'].toString()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return _buildDetailFormField('Location', 'Error');
                } else {
                  return _buildDetailFormField(
                      'Location', snapshot.data ?? 'Unknown');
                }
              },
            ),
            FutureBuilder(
              future: fetchCallerName(widget.formData['CallerID'].toString()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return _buildDetailFormField('Caller', 'Error');
                } else {
                  return _buildDetailFormField(
                      'Caller', snapshot.data ?? 'Unknown');
                }
              },
            ),
            _buildDetailFormField('Department', widget.formData['Department']),
            FutureBuilder(
              future: fetchServiceName(widget.formData['ServiceID'].toString()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return _buildDetailFormField('Service', 'Error');
                } else {
                  return _buildDetailFormField(
                      'Service', snapshot.data ?? 'Unknown');
                }
              },
            ),
            _buildDetailFormField('Impact', widget.formData['Impact']),
            FutureBuilder(
              future: fetchDeviceName(widget.formData['devices'].toString()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return _buildDetailFormField('Device', 'Error');
                } else {
                  return _buildDetailFormField(
                      'Device', snapshot.data ?? 'Unknown');
                }
              },
            ),
            _buildDetailFormField('Start Date', widget.formData['StartDate']),
            _buildDetailFormField('Added At', widget.formData['added_at']),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedStatus == null ? null : saveStatus,
                child: Text('Save Status'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailFormField(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value?.toString() ?? 'N/A',
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        readOnly: true,
      ),
    );
  }
}
