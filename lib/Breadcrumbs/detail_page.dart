import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

class DeviceDetailPage extends StatefulWidget {
  final Map<String, dynamic> device;

  const DeviceDetailPage({super.key, required this.device});

  @override
  _DeviceDetailPageState createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  double? latitude;
  double? longitude;
  bool isLoading = true;
  List<String> _photoUrls = [];
  final ImagePicker _picker = ImagePicker();
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
    _loadPhotos();
  }

  Future<void> _loadSavedLocation() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.252.28/Datatable/geolocator.php'),
        body: {
          'id': widget.device['id'].toString(),
          'action': 'get_location',
        },
      );

      print('Location response: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final data = json.decode(response.body);
          final savedLatitude = double.tryParse(data['latitude'].toString());
          final savedLongitude = double.tryParse(data['longitude'].toString());

          setState(() {
            latitude = savedLatitude;
            longitude = savedLongitude;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = 'Empty response body';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load location: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading location: $e';
      });
    }
  }

  Future<void> _loadPhotos() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.252.28/Datatable/get_photos.php?id=${widget.device['id']}'),
      );

      print('Photos response: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final List<dynamic> photoData = json.decode(response.body);

          setState(() {
            _photoUrls = List<String>.from(photoData);
          });
        } else {
          print('No photos found');
        }
      } else {
        print('Failed to load photos with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading photos: $e');
    }
  }

  Future<void> _determinePosition() async {
    try {
      LocationPermission permission;
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });
    } catch (e) {
      print('Error determining position: $e');
    }
  }

  Future<void> _saveLocation() async {
    if (latitude == null || longitude == null) {
      print('Error: Latitude or Longitude is null');
      return;
    }

    print(
        'Sending data: id=${widget.device['id']}, latitude=$latitude, longitude=$longitude');

    try {
      final response = await http.post(
        Uri.parse('http://192.168.252.28/Datatable/geolocator.php'),
        body: {
          'id': widget.device['id'].toString(),
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'action': 'save_location',
        },
      );

      print('Save location response: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        print("Location saved successfully");
      } else {
        print("Error saving location: ${response.body}");
      }
    } catch (e) {
      print('Error saving location: $e');
    }
  }

  Future<void> _capturePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      List<int> imageBytes = await pickedFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      try {
        final response = await http.post(
          Uri.parse('http://192.168.252.28/Datatable/upload_photo.php'),
          body: {
            'id': widget.device['id'].toString(),
            'photo': base64Image,
          },
        );

        print('Upload photo response: ${response.body}'); // Debug print

        if (response.statusCode == 200) {
          print("Photo uploaded successfully");
          _loadPhotos(); // Refresh the photo list
        } else {
          print("Error uploading photo: ${response.body}");
        }
      } catch (e) {
        print('Error uploading photo: $e');
      }
    }
  }

  Future<void> _deletePhoto(int index) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.252.28/Datatable/delete_photo.php'),
        body: {
          'id': widget.device['id'].toString(),
          'photoIndex': index.toString(),
        },
      );

      print('Delete photo response: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _photoUrls.removeAt(index);
        });
        print("Photo deleted successfully");
      } else {
        print("Error deleting photo: ${response.body}");
      }
    } catch (e) {
      print('Error deleting photo: $e');
    }
  }

  void _openPhotoViewer(int initialIndex) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Stack(
          children: [
            PhotoViewGallery.builder(
              itemCount: _photoUrls.length,
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: MemoryImage(base64Decode(_photoUrls[index])),
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 2,
                );
              },
              scrollPhysics: BouncingScrollPhysics(),
              backgroundDecoration: BoxDecoration(
                color: Colors.black,
              ),
              pageController: PageController(initialPage: initialIndex),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: Icon(Icons.delete, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                  _deletePhoto(initialIndex);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Scan this QR Code'),
          content: Container(
            width: 200, // Set width for the QR code container
            height: 200, // Set height for the QR code container
            child: QrImageView(
              data:
                  'http://192.168.252.28/Datatable/get_devices.php?id=${widget.device['id']}',
              version: QrVersions.auto,
              size: 150.0,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device['device_name']),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code),
            onPressed: _showQRCode,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (!isLoading && latitude != null && longitude != null)
            FlutterMap(
              options: MapOptions(
                center: LatLng(latitude!, longitude!),
                zoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(latitude!, longitude!),
                      builder: (ctx) => Container(
                        child: Icon(Icons.location_on,
                            color: Colors.red, size: 40.0),
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Container(
              color: Colors.blueGrey[100],
              child: Center(
                child: isLoading
                    ? CircularProgressIndicator()
                    : Text(
                        errorMessage ?? 'Map Placeholder',
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      ),
              ),
            ),
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.2,
            maxChildSize: 0.7,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.device['device_name'],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                      Text(
                        'Device Category: ${widget.device['device_category'] ?? ''}',
                        style: TextStyle(fontSize: 17),
                      ),
                      Text(
                        'Location: ${widget.device['geolocation'] ?? ''}',
                        style: TextStyle(fontSize: 17),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _determinePosition,
                            child: const Text('Get Location'),
                          ),
                          ElevatedButton(
                            onPressed: _saveLocation,
                            child: const Text('Save Location'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.camera_alt),
                            onPressed: _capturePhoto,
                            iconSize: 40.0,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      if (latitude != null && longitude != null)
                        Center(
                          child: Text(
                            'Latitude: $latitude, Longitude: $longitude',
                            style:
                                TextStyle(fontSize: 16, color: Colors.blueGrey),
                          ),
                        ),
                      if (_photoUrls.isNotEmpty)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                          ),
                          itemCount: _photoUrls.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => _openPhotoViewer(index),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Image.memory(
                                  base64Decode(_photoUrls[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
