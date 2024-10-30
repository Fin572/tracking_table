import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class IncidentTaskFormPage extends StatefulWidget {
  @override
  _IncidentTaskFormPageState createState() => _IncidentTaskFormPageState();
}

class _IncidentTaskFormPageState extends State<IncidentTaskFormPage> {
  TextEditingController taskController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  String? selectedOrganization;
  String? selectedLocation;
  String? selectedDeviceType;
  String? selectedDevice;
  String? selectedCaller;
  String? selectedDepartment;
  String? selectedService;
  String? selectedImpact;
  String? selectedWorkerLogin;
  String? userId;
  DateTime? selectedDate;

  List<dynamic> organizations = [];
  List<dynamic> locations = [];
  List<dynamic> devicesType = [];
  List<dynamic> devices = [];
  List<dynamic> callers = [];
  List<dynamic> departments = [];
  List<dynamic> services = [];
  List<dynamic> workers = [];

  @override
  void initState() {
    super.initState();
    fetchOrganizations();
    fetchServices();
    fetchWorkers();
    fetchUserId();
  }

  Future<void> fetchOrganizations() async {
    final response = await http.get(
        Uri.parse('https://indoguna.info/Datatable/Form/get_organization.php'));
    if (response.statusCode == 200) {
      setState(() {
        organizations = json.decode(response.body);
      });
    }
  }

  Future<void> fetchUserId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('login'); // Ambil login yang disimpan
      if (userId != null) {
        print('User ID fetched: $userId');
      } else {
        print('No userId found');
      }
    } catch (e) {
      print('Error fetching userId: $e');
    }
  }

  Future<void> saveLogin(String login) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('login', login);
    print("Login disimpan: $login");
  }

  void onLoginSuccess(String login) {
    saveLogin(login); // Panggil fungsi ini setelah login berhasil
  }

  Future<void> fetchLocations(String organizationID) async {
    final response = await http.get(Uri.parse(
        'https://indoguna.info/Datatable/Form/get_location.php?OrganizationID=$organizationID'));
    if (response.statusCode == 200) {
      setState(() {
        locations = json.decode(response.body);
      });
    }
  }

  Future<void> fetchDevicesType(String locationID) async {
    final response = await http.get(Uri.parse(
        'https://indoguna.info/Datatable/Form/get_devices_type.php?location_id=$locationID'));

    if (response.statusCode == 200) {
      print(response.body); // Debugging line to check the response
      setState(() {
        devicesType = json.decode(response.body);
      });
    } else {
      print('Failed to fetch devices type');
    }
  }

  Future<void> fetchDevices(String locationID, String deviceType) async {
    final response = await http.get(Uri.parse(
        'https://indoguna.info/Datatable/Form/get_devices.php?location_id=$locationID&device_type=$deviceType'));
    if (response.statusCode == 200) {
      setState(() {
        devices = json.decode(response.body); // Parse device data
      });
    } else {
      print('Failed to fetch devices');
    }
  }

  Future<void> fetchCallers(String organizationId) async {
    final response = await http.get(Uri.parse(
        'https://indoguna.info/Datatable/Form/get_caller.php?OrganizationID=$organizationId'));
    if (response.statusCode == 200) {
      setState(() {
        callers = json.decode(response.body);
      });
    }
  }

  Future<void> fetchDepartments(String callerID) async {
    final response = await http.get(Uri.parse(
        'https://indoguna.info/Datatable/Form/get_department.php?CallerID=$callerID'));
    if (response.statusCode == 200) {
      setState(() {
        departments = json.decode(response.body);
      });
    }
  }

  Future<void> fetchServices() async {
    final response = await http
        .get(Uri.parse('https://indoguna.info/Datatable/Form/get_service.php'));
    if (response.statusCode == 200) {
      setState(() {
        services = json.decode(response.body);
      });
    }
  }

  Future<void> fetchWorkers() async {
    final response = await http
        .get(Uri.parse('https://indoguna.info/Datatable/Form/get_worker.php'));
    if (response.statusCode == 200) {
      setState(() {
        workers = json.decode(response.body);
      });
    }
  }

  Future<void> submitTask() async {
    // Ambil login dari SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? login =
        prefs.getString('login'); // Mengambil 'login', bukan 'userId'

    // Pastikan login tidak null
    if (login == null || login.isEmpty) {
      print("Error: Login is null or empty");
      return;
    }

    // Buat data form untuk disubmit
    var data = {
      'problems': taskController.text,
      'description': descriptionController.text,
      'organization': selectedOrganization,
      'location': selectedLocation,
      'caller': selectedCaller,
      'department': selectedDepartment,
      'service': selectedService,
      'impact': selectedImpact,
      'worker': selectedWorkerLogin,
      'device_type': selectedDeviceType,
      'device': selectedDevice != null
          ? int.tryParse(selectedDevice!)?.toString()
          : null,
      'date': selectedDate != null
          ? "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}"
          : null,
      'login': login, // Otomatis menambahkan 'login' ke data
    };

    print("Data to submit: $data"); // Debugging log untuk memastikan login ada

    // Lakukan POST request ke server
    final response = await http.post(
      Uri.parse('https://indoguna.info/Datatable/Form/submit_incident.php'),
      body: data,
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, data);
    } else {
      print('Gagal menyimpan data');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(3000),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Input Your Problems')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: taskController,
                  decoration: InputDecoration(labelText: 'Problems'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                SizedBox(height: 10),
                // Dropdown for Organization
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: DropdownButtonFormField(
                    isExpanded: true,
                    hint: Text('Select Organization'),
                    value: selectedOrganization,
                    items: organizations.map((organization) {
                      return DropdownMenuItem(
                        value: organization['OrganizationID'],
                        child: Text(organization['Name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedOrganization = value as String?;
                        selectedLocation = null;
                        selectedCaller = null;
                        selectedDepartment = null;

                        locations.clear();
                        departments.clear();

                        if (selectedOrganization != null) {
                          fetchLocations(selectedOrganization!);
                          fetchCallers(selectedOrganization!);
                        }
                      });
                    },
                  ),
                ),
                SizedBox(height: 10),
                // Dropdown for Location
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: DropdownButtonFormField(
                    isExpanded: true,
                    hint: Text('Select Location'),
                    value: selectedLocation,
                    items: locations.map((location) {
                      return DropdownMenuItem(
                        value: location['LocationID'],
                        child: Text(location['Name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedLocation = value as String?;
                        selectedDepartment = null;

                        departments.clear();
                        devicesType.clear();
                        devices.clear();

                        if (selectedLocation != null) {
                          fetchDevicesType(selectedLocation!);
                        }
                        if (selectedLocation != null &&
                            selectedDeviceType != null) {
                          fetchDevices(selectedLocation!, selectedDeviceType!);
                        }
                      });
                    },
                  ),
                ),
                SizedBox(height: 10),
                // Dropdown for Caller
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: DropdownButtonFormField(
                    isExpanded: true,
                    hint: Text('Select Your Name'),
                    value: selectedCaller,
                    items: callers.map((caller) {
                      return DropdownMenuItem(
                        value: caller['EmployeeID'],
                        child: Text(caller['Name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCaller = value as String?;
                        fetchDepartments(selectedCaller!);
                      });
                    },
                  ),
                ),
                SizedBox(height: 10),
                // Dropdown for Department
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: DropdownButtonFormField(
                    isExpanded: true,
                    hint: Text('Select Department'),
                    value: selectedDepartment,
                    items: departments.map((department) {
                      return DropdownMenuItem(
                        value: department['Department'],
                        child: Text(department['Department']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDepartment = value as String?;
                      });
                    },
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: DropdownButtonFormField(
                    isExpanded: true,
                    hint: Text('Select Device Type'),
                    value: selectedDeviceType,
                    items: devicesType.map((device) {
                      return DropdownMenuItem(
                        value: device[
                            'device_type'], // Pastikan field ini ada di JSON
                        child: Text(
                            device['device_type']), // Ditampilkan sebagai teks
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDeviceType = value as String?;
                        if (selectedLocation != null &&
                            selectedDeviceType != null) {
                          fetchDevices(selectedLocation!, selectedDeviceType!);
                        }
                      });
                    },
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: DropdownButtonFormField(
                    isExpanded: true,
                    hint: Text('Select Devices'),
                    value: selectedDevice,
                    items: devices.map((device) {
                      return DropdownMenuItem(
                        value: device['id']
                            .toString(), // Convert device ID to String
                        child: Text(device['name']), // Display device name
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDevice = value as String?; // Keep it as String?
                      });
                    },
                  ),
                ),

                SizedBox(height: 10),
                // Dropdown for Service
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: DropdownButtonFormField(
                    isExpanded: true,
                    alignment: Alignment.centerLeft,
                    hint: Text('Select Service'),
                    value: selectedService,
                    items: services.map((service) {
                      return DropdownMenuItem(
                        value: service['ServiceID'],
                        child: Text(
                          service['Name'],
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedService = value as String?;
                      });
                    },
                  ),
                ),
                SizedBox(height: 10),
                // Dropdown for Impact
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: DropdownButtonFormField(
                    isExpanded: true,
                    hint: Text('Select Impact'),
                    value: selectedImpact,
                    items: [
                      DropdownMenuItem(
                          value: 'A department', child: Text('A department')),
                      DropdownMenuItem(
                          value: 'A service', child: Text('A service')),
                      DropdownMenuItem(
                          value: 'A person', child: Text('A person')),
                      DropdownMenuItem(
                          value: 'A company', child: Text('A company')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedImpact = value as String?;
                      });
                    },
                  ),
                ),
                SizedBox(height: 10),
                // Dropdown for Worker
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: DropdownButtonFormField(
                    isExpanded: true,
                    hint: Text('Select Worker'),
                    value: workers.any(
                            (worker) => worker['login'] == selectedWorkerLogin)
                        ? selectedWorkerLogin
                        : null, // Ensure the initial value is valid or null
                    items: workers.map((worker) {
                      return DropdownMenuItem(
                        value: worker['login'], // Use login as the value
                        child: Text(worker['name']), // Display the name
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedWorkerLogin =
                            value as String?; // Save login to be submitted
                      });
                    },
                  ),
                ),
                SizedBox(height: 10),
                // Date Picker
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: selectedDate != null
                              ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                              : 'Select Date',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: submitTask,
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
