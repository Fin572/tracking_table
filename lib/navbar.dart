import 'package:flutter/material.dart';
import 'package:tracking_table/Breadcrumbs/Treeview.dart';
import 'package:tracking_table/Ticketing/ticketing.dart';
import 'package:tracking_table/Ticketing/ticketing_incident.dart';
import 'package:tracking_table/home.dart';

class MainPage extends StatefulWidget {
  final Map<String, dynamic> user;
  final int groupId;
  final List<dynamic> organizations;

  MainPage({
    Key? key,
    required this.user,
    required this.groupId,
    required this.organizations,
  }) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      if (index == 2) {
        _showPopupMenu();
      } else {
        _selectedIndex = index;
      }
    });
  }

  void _showPopupMenu() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) => _buildPopupMenu(),
    );
  }

  Widget _buildPopupMenu() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.person),
            title: Text('User Request'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TicketingApp(
                    user: widget.user,
                    groupId: widget.groupId,
                    organizations: widget.organizations,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.report),
            title: Text('Incident'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TicketingIncident(
                        user: widget.user,
                        groupId: widget.groupId,
                        organizations: widget.organizations)),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _selectedIndex == 0
            ? ProfilePage(user: widget.user)
            : _selectedIndex == 1
                ? BreadcrumbsPage(
                    user: widget.user,
                    groupId: widget.groupId,
                    organizations: widget.organizations,
                  )
                : Container(), // Empty container for ticketing
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 24),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.view_list, size: 24),
              label: 'Organizations',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_num, size: 24),
              label: 'Ticketing',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
          selectedFontSize: 12,
          unselectedFontSize: 10,
          iconSize: 24,
        ),
      ),
    );
  }
}
