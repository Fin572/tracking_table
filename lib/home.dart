import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:tracking_table/Breadcrumbs/detail_page.dart';
import 'package:tracking_table/Breadcrumbs/login.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> user;

  ProfilePage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 16),
              Text(
                user['name'],
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                user['email'],
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [],
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Available Status', style: TextStyle(fontSize: 16)),
                  Switch(
                    value: user['active'] == '1',
                    onChanged: (bool value) {},
                  ),
                ],
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.language),
                title: Text('App Language'),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.brightness_4),
                title: Text('App Theme'),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.qr_code),
                title: Text('Scan QR Code'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QRScanPage()),
                  );
                },
              ),
              Divider(),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: Text('Log Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QRScanPage extends StatefulWidget {
  @override
  _QRScanPageState createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  String _scanResult = 'Unknown';

  Future<void> _startQRScan() async {
    try {
      String scanResult = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // Warna garis tepi saat scanning
        'Cancel', // Tombol cancel
        true, // Tampilkan garis
        ScanMode.QR, // Mode QR
      );

      if (scanResult != '-1') {
        setState(() {
          _scanResult = scanResult;
        });

        await _fetchDeviceData(scanResult);
      }
    } catch (e) {
      setState(() {
        _scanResult = 'Failed to get the scan result.';
      });
    }
  }

  Future<void> _fetchDeviceData(String qrData) async {
    try {
      // Parse QR data as URI to extract parameters
      Uri uri = Uri.parse(qrData);
      String? id = uri.queryParameters['id'];

      if (id != null) {
        // Prepare the URL for the request
        final response = await http.get(
          Uri.parse('https://192.168.252.28/Datatable/get_devices.php?id=$id'),
        );

        if (response.statusCode == 200) {
          // Log respons untuk memastikan apa yang diterima
          print('Response body: ${response.body}');

          // Parse response body dan casting
          final dynamic jsonResponse = json.decode(response.body);

          // Cek apakah jsonResponse adalah List atau Map
          if (jsonResponse is List && jsonResponse.isNotEmpty) {
            final Map<String, dynamic> device =
                Map<String, dynamic>.from(jsonResponse[0]);

            if (device != null && device['id'] != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DeviceDetailPage(device: device),
                ),
              );
            } else {
              _showError('No valid device data found with ID: $id');
            }
          } else if (jsonResponse is Map) {
            final Map<String, dynamic> device =
                Map<String, dynamic>.from(jsonResponse);

            if (device != null && device['id'] != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DeviceDetailPage(device: device),
                ),
              );
            } else {
              _showError('No valid device data found with ID: $id');
            }
          } else {
            _showError('No data returned from the server.');
          }
        } else {
          _showError(
              'Failed to fetch device details. Status Code: ${response.statusCode}');
        }
      } else {
        _showError('Invalid QR code data.');
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Scan result: $_scanResult'),
            ElevatedButton(
              onPressed: _startQRScan,
              child: Text('Start QR scan'),
            ),
          ],
        ),
      ),
    );
  }
}
