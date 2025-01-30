import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tracking_table/Breadcrumbs/locations_page.dart';
import 'dart:convert';
import 'device_list_page.dart';

class DeviceTypesPage extends StatefulWidget {
  final String locationId;
  final String locationName;
  final String organizationId; // Add organizationId
  final String organizationName; // Add organizationName

  const DeviceTypesPage({
    super.key,
    required this.locationId,
    required this.locationName,
    required this.organizationId, // Add organizationId
    required this.organizationName, // Add organizationName
  });

  @override
  _DeviceTypesPageState createState() => _DeviceTypesPageState();
}

class _DeviceTypesPageState extends State<DeviceTypesPage> {
  List<String> deviceTypes = [];

  @override
  void initState() {
    super.initState();
    fetchDeviceTypes();
  }

  Future<void> fetchDeviceTypes() async {
    final response = await http.get(Uri.parse(
        'https://indoguna.info/Datatable/get_devices_type.php?location_id=${widget.locationId}'));

    if (response.statusCode == 200) {
      setState(() {
        List<dynamic> data = json.decode(response.body);
        deviceTypes =
            data.map((item) => item['device_type'] as String).toList();
      });
    } else {
      throw Exception('Failed to load device types');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Device Types'),
      ),
      body: Column(
        children: [
          // Breadcrumbs added here
          Breadcrumb(
            paths: ["Home", widget.organizationName, "Device Types"],
            onTap: (index) {
              if (index == 0) {
                Navigator.popUntil(
                    context, (route) => route.isFirst); // Go to Home
              } else if (index == 1) {
                // Navigate to LocationsPage instead of just popping the current page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocationsPage(
                      organizationId: widget.organizationId,
                      organizationName: widget.organizationName,
                    ),
                  ),
                );
              }
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: deviceTypes.length,
              itemBuilder: (context, index) {
                String deviceType = deviceTypes[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(deviceType),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeviceListPage(
                            locationId: widget.locationId,
                            deviceType: deviceType,
                            organizationId:
                                widget.organizationId, // Pass organizationId
                            organizationName: widget
                                .organizationName, // Pass organizationName
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Breadcrumb widget to add breadcrumb navigation
class Breadcrumb extends StatelessWidget {
  final List<String> paths;
  final Function(int) onTap;

  Breadcrumb({required this.paths, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: List.generate(paths.length, (index) {
          return GestureDetector(
            onTap: () => onTap(index),
            child: Row(
              children: [
                if (index > 0) Icon(Icons.arrow_forward_ios, size: 12),
                Text(paths[index], style: TextStyle(color: Colors.blue)),
              ],
            ),
          );
        }),
      ),
    );
  }
}
