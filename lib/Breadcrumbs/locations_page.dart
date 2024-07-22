import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'device_types_page.dart';

class LocationsPage extends StatefulWidget {
  final String organizationId;
  final String organizationName;

  const LocationsPage({
    super.key,
    required this.organizationId,
    required this.organizationName,
  });

  @override
  _LocationsPageState createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  List<dynamic> locations = [];

  @override
  void initState() {
    super.initState();
    fetchLocations();
  }

  Future<void> fetchLocations() async {
    final response = await http.get(Uri.parse(
        'http://192.168.252.28/Datatable/get_locations.php?organization_id=${widget.organizationId}'));

    if (response.statusCode == 200) {
      setState(() {
        locations = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load locations');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.organizationName),
      ),
      body: ListView.builder(
        itemCount: locations.length,
        itemBuilder: (context, index) {
          var location = locations[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(location['Location_Name']),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeviceTypesPage(
                      locationId: location['LocationId'],
                      locationName: location['Location_Name'],
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
