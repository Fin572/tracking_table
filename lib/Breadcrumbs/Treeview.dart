import 'package:flutter/material.dart';
import 'locations_page.dart';

class BreadcrumbsPage extends StatefulWidget {
  final Map<String, dynamic> user;
  final int groupId;
  final List<dynamic> organizations;

  BreadcrumbsPage(
      {required this.user, required this.groupId, required this.organizations});

  @override
  _BreadcrumbsPageState createState() => _BreadcrumbsPageState();
}

class _BreadcrumbsPageState extends State<BreadcrumbsPage> {
  Map<String, List<dynamic>> groupedOrganizations = {};
  Map<String, List<dynamic>> filteredOrganizations = {};
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    groupOrganizations();
    filteredOrganizations = Map.from(groupedOrganizations);
    _searchController.addListener(_filterOrganizations);
  }

  void groupOrganizations() {
    groupedOrganizations.clear();
    for (var organization in widget.organizations) {
      String group = organization['Code'];
      if (!groupedOrganizations.containsKey(group)) {
        groupedOrganizations[group] = [];
      }
      groupedOrganizations[group]!.add(organization);
    }
  }

  void _filterOrganizations() {
    String query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        filteredOrganizations = Map.from(groupedOrganizations);
      });
    } else {
      Map<String, List<dynamic>> tempFilteredOrganizations = {};
      groupedOrganizations.forEach((group, organizations) {
        var filteredList = organizations
            .where((organization) =>
                organization['Organization_Name'].toLowerCase().contains(query))
            .toList();
        if (filteredList.isNotEmpty) {
          tempFilteredOrganizations[group] = filteredList;
        }
      });
      setState(() {
        filteredOrganizations = tempFilteredOrganizations;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizations'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search organizations...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredOrganizations.length,
              itemBuilder: (context, index) {
                String group = filteredOrganizations.keys.elementAt(index);
                List<dynamic> organizations = filteredOrganizations[group]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        group,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...organizations.map((organization) {
                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(organization['Organization_Name']),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LocationsPage(
                                  organizationId:
                                      organization['OrganizationID'],
                                  organizationName:
                                      organization['Organization_Name'],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
