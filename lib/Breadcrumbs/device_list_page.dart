import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tracking_table/Breadcrumbs/detail_page.dart';
import 'dart:convert';

class DeviceListPage extends StatefulWidget {
  final String locationId;
  final String deviceType;

  const DeviceListPage({
    super.key,
    required this.locationId,
    required this.deviceType,
  });

  @override
  _DeviceListPageState createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage> {
  List<dynamic> devices = [];
  List<dynamic> filteredDevices = [];
  TextEditingController searchController = TextEditingController();

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
          'http://192.168.252.28/Datatable/get_devices.php?location_id=${widget.locationId}&device_type=${widget.deviceType}';
      print('Fetching devices from URL: $url'); // Log URL untuk debugging
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print(
            'Response body: ${response.body}'); // Log response body untuk debugging
        if (response.body.isNotEmpty) {
          final List<dynamic> deviceList = json.decode(response.body);
          setState(() {
            devices = deviceList;
            filteredDevices = devices;
          });
        } else {
          // Handle the case where the response is empty
          setState(() {
            devices = [];
            filteredDevices = [];
          });
          print(
              'No data found for location_id: ${widget.locationId} and device_type: ${widget.deviceType}');
        }
      } else {
        throw Exception('Failed to load devices');
      }
    } catch (e) {
      // Handle JSON parsing error
      print('Error parsing JSON: $e');
      setState(() {
        devices = [];
        filteredDevices = [];
      });
    }
  }

  void filterDevices() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredDevices = devices.where((device) {
        return device['device_name'].toLowerCase().contains(query);
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
      body: Column(
        children: [
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
                String deviceName = device['device_name'];
                String deviceId =device['id'].toString();

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
