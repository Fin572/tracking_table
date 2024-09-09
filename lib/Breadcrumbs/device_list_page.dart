import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tracking_table/Breadcrumbs/detail_page.dart';
import 'dart:convert';
import 'package:tracking_table/Breadcrumbs/locations_page.dart';

class DeviceListPage extends StatefulWidget {
  final String locationId;
  final String deviceType;
  final String organizationId; // Add organizationId
  final String organizationName; // Add organizationName

  const DeviceListPage({
    super.key,
    required this.locationId,
    required this.deviceType,
    required this.organizationId, // Add organizationId to constructor
    required this.organizationName, // Add organizationName to constructor
  });

  @override
  _DeviceListPageState createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage> {
  List<dynamic> devices = [];
  List<dynamic> filteredDevices = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true; // Add loading state
  bool isError = false; // Add error state

  @override
  void initState() {
    super.initState();
    fetchDevices();
    searchController.addListener(() {
      filterDevices();
    });
  }

  Future<void> fetchDevices() async {
    try {
      final url =
          'http://indoguna.info/Datatable/get_devices.php?location_id=${widget.locationId}&device_type=${widget.deviceType}&organization_id=${widget.organizationId}';
      print('Fetching devices from URL: $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final List<dynamic> deviceList = json.decode(response.body);
          setState(() {
            devices = deviceList;
            filteredDevices = devices;
            isLoading = false;
          });
        } else {
          setState(() {
            devices = [];
            filteredDevices = [];
            isLoading = false;
          });
          print(
              'No data found for location_id: ${widget.locationId} and device_type: ${widget.deviceType}');
        }
      } else {
        throw Exception('Failed to load devices');
      }
    } catch (e) {
      print('Error fetching devices: $e');
      setState(() {
        devices = [];
        filteredDevices = [];
        isLoading = false;
        isError = true;
      });
    }
  }

  void filterDevices() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredDevices = devices.where((device) {
        return device['name'].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.deviceType} Devices'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : isError
              ? Center(child: Text('Failed to load devices'))
              : Column(
                  children: [
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: 'Search',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredDevices.length,
                        itemBuilder: (context, index) {
                          var device = filteredDevices[index];
                          String deviceName = device['name'];
                          String deviceId = device['id'].toString();

                          return Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text(deviceName),
                              subtitle: Text('ID: $deviceId'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DeviceDetailPage(
                                      device: device,
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
