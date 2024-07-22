import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'device_list_page.dart';

class DeviceTypesPage extends StatefulWidget {
  final String locationId;
  final String locationName;

  const DeviceTypesPage(
      {super.key, required this.locationId, required this.locationName});

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
        'http://192.168.252.28/Datatable/get_devices_type.php?location_id=${widget.locationId}'));

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
        title: Text('Device Types at ${widget.locationName}'),
      ),
      body: ListView.builder(
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
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
