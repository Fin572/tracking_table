import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DetailTicketingPage extends StatelessWidget {
  final Map<String, dynamic> formData;

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
    // Build the URL with organizationId as a query parameter
    final response = await http.get(
      Uri.parse(
          'https://indoguna.info/Datatable/Form/Fetch/fetch_organization.php?organization=$organizationId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['Name'] ?? 'Unknown'; // Extract 'Name' from the response
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

  Future<String> fetchServiceName(String smService) async {
    final response = await http.get(
      Uri.parse(
          'https://indoguna.info/Datatable/Form/Fetch/fetch_service.php?service=$smService'),
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

  const DetailTicketingPage({Key? key, required this.formData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailFormField('Request/Problems', formData['Title']),
            _buildDetailFormField('Description', formData['Description']),
            FutureBuilder(
              future:
                  fetchOrganizationName(formData['OrganizationID'].toString()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return _buildDetailFormField('OrganizationID', 'Error');
                } else {
                  return _buildDetailFormField('OrganizationID', snapshot.data);
                }
              },
            ),
            FutureBuilder<String>(
              future: fetchLocationName(formData['location_id'].toString()),
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
              future: fetchCallerName(formData['CallerID'].toString()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return _buildDetailFormField('CallerID', 'Error');
                } else {
                  return _buildDetailFormField('CallerID', snapshot.data);
                }
              },
            ),
            _buildDetailFormField('Department', formData['Department']),
            FutureBuilder(
              future: fetchServiceName(formData['ServiceID'].toString()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Show loading indicator while waiting
                } else if (snapshot.hasError) {
                  return _buildDetailFormField(
                      'ServiceID', 'Error loading service');
                } else {
                  return _buildDetailFormField('ServiceID', snapshot.data);
                }
              },
            ),
            _buildDetailFormField('Impact', formData['Impact']),
            _buildDetailFormField('Worker', formData['worker_id']),
            _buildDetailFormField('Device Type', formData['devices_type']),
            FutureBuilder(
              future: fetchDeviceName(formData['devices'].toString()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final name = snapshot.data ?? 'Unknown';
                  return _buildDetailFormField('Device Name', name);
                }
              },
            ),
            _buildDetailFormField('Selected Date', formData['StartDate']),
            _buildDetailFormField('Added At', formData['added_at']),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk membuat row untuk setiap detail form
  Widget _buildDetailFormField(String label, dynamic value) {
    // Log each field and its type
    print('$label: ${value.runtimeType}');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value?.toString() ?? 'N/A', // Convert any value to String
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        readOnly: true,
      ),
    );
  }
}
