import 'package:flutter/material.dart';
import 'package:tracking_table/Ticketing/form_incident.dart';
import 'package:tracking_table/navbar.dart';

class TicketingIncident extends StatelessWidget {
  final Map<String, dynamic> user;
  final int groupId;
  final List<dynamic> organizations;

  const TicketingIncident({
    Key? key,
    required this.user,
    required this.groupId,
    required this.organizations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Ticketing(
        user: user,
        groupId: groupId,
        organizations: organizations,
      ),
    );
  }
}

class Ticketing extends StatefulWidget {
  final Map<String, dynamic> user;
  final int groupId;
  final List<dynamic> organizations;

  const Ticketing({
    Key? key,
    required this.user,
    required this.groupId,
    required this.organizations,
  }) : super(key: key);

  @override
  State<Ticketing> createState() => _TicketingState();
}

class _TicketingState extends State<Ticketing> {
  static const List<(Color?, Color? background, ShapeBorder?)> customizations =
      <(Color?, Color?, ShapeBorder?)>[
    (null, null, null),
    (null, Colors.green, null),
    (Colors.white, Colors.green, null),
    (Colors.white, Colors.green, CircleBorder()),
  ];
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticketing Incident'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => MainPage(
                  user: widget.user,
                  groupId: widget.groupId,
                  organizations: widget.organizations,
                ),
              ),
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: const Center(child: Text('Incident!')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the IncidentTaskFormPage
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => IncidentTaskFormPage()),
          );
        },
        foregroundColor: customizations[index].$1,
        backgroundColor: customizations[index].$2,
        shape: customizations[index].$3,
        child: const Icon(Icons.add),
      ),
    );
  }
}
