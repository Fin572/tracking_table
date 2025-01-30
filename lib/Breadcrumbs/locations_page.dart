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
        'https://indoguna.info/Datatable/get_locations.php?organization_id=${widget.organizationId}'));

    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          locations = json.decode(response.body);
        });
      }
    } else {
      throw Exception('Failed to load locations');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location At ${widget.organizationName}'),
      ),
      body: Column(
        children: [
          // Breadcrumbs added here
          Breadcrumb(
            paths: ["Home", widget.organizationName, "Locations"],
            onTap: (index) {
              if (index == 0) {
                Navigator.popUntil(
                    context, (route) => route.isFirst); // Go to home
              } else if (index == 1) {
                Navigator.pop(context); // Go to Organizations page
              }
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: locations.length,
              itemBuilder: (context, index) {
                var location = locations[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(location['Name']),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeviceTypesPage(
                            locationId: location['LocationId'],
                            locationName: location['Name'],
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
