import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DetailHistoryPage extends StatefulWidget {
  final Map<String, dynamic> formData;

  const DetailHistoryPage({Key? key, required this.formData}) : super(key: key);

  @override
  _DetailHistoryPageState createState() => _DetailHistoryPageState();
}

class _DetailHistoryPageState extends State<DetailHistoryPage> {
  Future<String> fetchCallerName(String callerId) async {
    final response = await http.get(
      Uri.parse(
          'https://indoguna.info/Datatable/Form/Fetch/fetch_callers.php?caller=$callerId'),
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
          'https://indoguna.info/Datatable/Form/Fetch/fetch_organization.php?organization=$organizationId'),
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
          'https://indoguna.info/Datatable/Form/Fetch/fetch_location.php?location=$locationId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['Name'] ?? 'Unknown';
    } else {
      throw Exception('Failed to load location name');
    }
  }

  Future<String> fetchServiceName(String serviceId) async {
    final response = await http.get(
      Uri.parse(
          'https://indoguna.info/Datatable/Form/Fetch/fetch_service.php?service=$serviceId'),
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
          'https://indoguna.info/Datatable/Form/Fetch/fetch_device.php?device=$deviceId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['name'] ?? 'Unknown';
    } else {
      throw Exception('Failed to load device name');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail History'),
        backgroundColor: const Color(0xff32394a),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tombol Back Manual Jika AppBar Tidak Muncul
            Align(
              alignment: Alignment.topLeft,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Kontainer Detail
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailItem(
                      'Request/Problems', widget.formData['Title']),
                  _buildDetailItem(
                      'Description', widget.formData['Description']),
                  FutureBuilder(
                    future: fetchOrganizationName(
                        widget.formData['OrganizationID'].toString()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildLoadingItem('Organization');
                      } else if (snapshot.hasError) {
                        return _buildDetailItem('Organization', 'Error');
                      } else {
                        return _buildDetailItem(
                            'Organization', snapshot.data.toString());
                      }
                    },
                  ),
                  FutureBuilder(
                    future: fetchLocationName(
                        widget.formData['location_id'].toString()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildLoadingItem('Location');
                      } else if (snapshot.hasError) {
                        return _buildDetailItem('Location', 'Error');
                      } else {
                        return _buildDetailItem(
                            'Location', snapshot.data.toString());
                      }
                    },
                  ),
                  FutureBuilder(
                    future:
                        fetchCallerName(widget.formData['CallerID'].toString()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildLoadingItem('Caller');
                      } else if (snapshot.hasError) {
                        return _buildDetailItem('Caller', 'Error');
                      } else {
                        return _buildDetailItem(
                            'Caller', snapshot.data.toString());
                      }
                    },
                  ),
                  _buildDetailItem('Department', widget.formData['Department']),
                  FutureBuilder(
                    future: fetchServiceName(
                        widget.formData['ServiceID'].toString()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildLoadingItem('Service');
                      } else if (snapshot.hasError) {
                        return _buildDetailItem('Service', 'Error');
                      } else {
                        return _buildDetailItem(
                            'Service', snapshot.data.toString());
                      }
                    },
                  ),
                  _buildDetailItem('Impact', widget.formData['Impact']),
                  _buildDetailItem('Worker', widget.formData['worker_id']),
                  _buildDetailItem(
                      'Device Type', widget.formData['devices_type']),
                  FutureBuilder(
                    future:
                        fetchDeviceName(widget.formData['devices'].toString()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildLoadingItem('Device Name');
                      } else if (snapshot.hasError) {
                        return _buildDetailItem('Device Name', 'Error');
                      } else {
                        return _buildDetailItem(
                            'Device Name', snapshot.data.toString());
                      }
                    },
                  ),
                  _buildDetailItem(
                      'Selected Date', widget.formData['StartDate']),
                  _buildDetailItem('Added At', widget.formData['added_at']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xff32394a)),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value?.toString() ?? 'N/A',
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingItem(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xff32394a)))),
          const Expanded(
              flex: 3, child: Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }
}
