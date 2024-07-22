import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:tracking_table/Breadcrumbs/login.dart';
import 'package:tracking_table/Breadcrumbs/detail_page.dart'; // Import the detail page

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> user;

  ProfilePage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 16),
              Text(
                user['username'],
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
                    MaterialPageRoute(builder: (context) => QRViewExample()),
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

class QRViewExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text('Scan a QR code'),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      // Assuming the scanData contains device information
      Map<String, dynamic> device = jsonDecode(scanData.code!);
      controller.pauseCamera(); // Pause the camera to prevent multiple scans
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DeviceDetailPage(device: device),
        ),
      ).then((_) {
        controller
            .resumeCamera(); // Resume the camera when returning to the scan screen
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
