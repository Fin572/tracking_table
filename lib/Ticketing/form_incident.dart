import 'package:dropdown_search/dropdown_search.dart';
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
  int? groupId;
  DateTime? selectedDate;
  DateTime? autoDate;

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
    autoDate = DateTime.now();
    fetchOrganizations();
    fetchServices();
    fetchWorkers();
    fetchUserId();
    fetchGroupId();
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

  Future<void> fetchGroupId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      groupId = prefs.getInt('group_id'); // Ambil group_id dari sesi
      print(
          'Fetched group_id: $groupId'); // Debugging untuk memastikan nilai group_id
      if (groupId == null) {
        print('Group ID is null. Cannot prefill form.');
      } else if (groupId! > 3) {
        print('Group ID is valid. Prefilling form...');
        prefillForm();
      } else {
        print('Group ID is less than or equal to 3. No prefill needed.');
      }
    } catch (e) {
      print('Error fetching group_id: $e');
    }
  }

  void prefillForm() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? location = prefs.getString('location');
      String? caller = prefs.getString('employee_id');

      setState(() {
        if (location != null &&
            locations.any((loc) => loc['LocationID'].toString() == location)) {
          selectedLocation = location;
          fetchDevicesType(
              selectedLocation!); // Fetch device type jika location valid
        }

        if (caller != null &&
            callers.any((call) => call['EmployeeID'].toString() == caller)) {
          selectedCaller = caller;
          fetchDepartments(
              selectedCaller!); // Fetch departments jika caller valid
        }
      });
    } catch (e) {
      print('Error in prefillForm: $e');
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
      List<dynamic> fetchedLocations = json.decode(response.body);

      // Remove duplicate LocationID values by using a Set
      Set<String> seenIds = Set();
      List<dynamic> uniqueLocations = [];

      for (var location in fetchedLocations) {
        if (!seenIds.contains(location['LocationID'].toString())) {
          seenIds.add(location['LocationID'].toString());
          uniqueLocations.add(location);
        }
      }

      // Update the locations list with unique values
      setState(() {
        locations = uniqueLocations;
      });

      // Call prefillForm after fetching locations to prefill selectedLocation
      prefillForm();
    } else {
      print('Failed to fetch locations');
    }
  }

  Future<void> fetchDevicesType(String locationID) async {
    final response = await http.get(
      Uri.parse(
          'https://indoguna.info/Datatable/Form/get_devices_type.php?location_id=$locationID'),
    );

    if (response.statusCode == 200) {
      setState(() {
        devicesType = json.decode(response.body);
      });

      // Debugging: Periksa data devicesType
      print('Devices Type fetched for Location ID $locationID: $devicesType');
    } else {
      print('Failed to fetch device types for Location ID $locationID');
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
      List<dynamic> fetchedCallers = json.decode(response.body);

      // Filter out invalid callers (where EmployeeID or Name is null)
      fetchedCallers = fetchedCallers.where((caller) {
        return caller['EmployeeID'] != null && caller['Name'] != null;
      }).toList();

      setState(() {
        callers = fetchedCallers;
      });

      print('Fetched and valid callers: $callers'); // Debugging log
      prefillForm(); // Call prefill after fetching callers
    } else {
      print('Failed to fetch callers');
    }
  }

  Future<void> fetchDepartments(String callerID) async {
    final response = await http.get(
      Uri.parse(
          'https://indoguna.info/Datatable/Form/get_department.php?CallerID=$callerID'),
    );

    if (response.statusCode == 200) {
      setState(() {
        departments = json.decode(response.body);
      });

      print('Fetched departments for Caller ID $callerID: $departments');
    } else {
      print('Failed to fetch departments for Caller ID $callerID');
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
    // Check if all required fields are selected
    if (selectedOrganization == null ||
        selectedLocation == null ||
        selectedCaller == null ||
        selectedDepartment == null ||
        selectedDeviceType == null ||
        selectedDevice == null ||
        selectedService == null ||
        selectedImpact == null ||
        selectedWorkerLogin == null ||
        selectedDate == null) {
      // Show a warning message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Incomplete Form"),
          content: Text("Please fill out all fields before submitting."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

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
      'request': taskController.text,
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
      'added_at': DateTime.now().toIso8601String(),
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
                  decoration: InputDecoration(labelText: 'Problem'),
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
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    hint: Text('Select Location'),
                    value: selectedLocation, // Nilai default
                    items: locations.map((location) {
                      return DropdownMenuItem<String>(
                        value: location['LocationID']
                            .toString(), // Gunakan ID Lokasi
                        child: Text(location['Name']), // Tampilkan nama lokasi
                      );
                    }).toList(),
                    onChanged: (groupId != null && groupId! > 3)
                        ? null // Nonaktifkan dropdown untuk group_id > 3
                        : (value) {
                            setState(() {
                              selectedLocation =
                                  value; // Update lokasi yang dipilih
                              selectedDeviceType =
                                  null; // Reset device type saat lokasi berubah
                              devicesType
                                  .clear(); // Kosongkan daftar device type
                            });

                            if (selectedLocation != null) {
                              fetchDevicesType(
                                  selectedLocation!); // Fetch device type
                            }
                          },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a location';
                      }
                      return null;
                    },
                  ),
                ),

                SizedBox(height: 10),

                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    hint: Text('Select Your Name'),
                    value: selectedCaller, // Nilai default
                    items: callers.map((caller) {
                      return DropdownMenuItem<String>(
                        value: caller['EmployeeID'], // Gunakan EmployeeID
                        child: Text(caller['Name']), // Tampilkan nama karyawan
                      );
                    }).toList(),
                    onChanged: (groupId != null && groupId! > 3)
                        ? null // Nonaktifkan dropdown untuk group_id > 3
                        : (value) {
                            setState(() {
                              selectedCaller =
                                  value; // Update caller yang dipilih
                              selectedDepartment =
                                  null; // Reset department saat caller berubah
                              departments
                                  .clear(); // Kosongkan daftar department
                            });

                            if (selectedCaller != null) {
                              fetchDepartments(
                                  selectedCaller!); // Fetch departments
                            }
                          },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a name';
                      }
                      return null;
                    },
                  ),
                ),

                SizedBox(height: 10),

                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    hint: Text('Select Department'),
                    value: selectedDepartment, // Nilai default
                    items: departments.map((department) {
                      return DropdownMenuItem<String>(
                        value: department[
                            'Department'], // Gunakan nama department sebagai value
                        child: Text(department[
                            'Department']), // Tampilkan nama department
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDepartment =
                            value; // Update department yang dipilih
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a department';
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    hint: Text('Select Device Type'),
                    value: selectedDeviceType, // Nilai default
                    items: devicesType.map((device) {
                      return DropdownMenuItem<String>(
                        value:
                            device['device_type'], // Gunakan nilai device_type
                        child: Text(device[
                            'device_type']), // Tampilkan device_type di UI
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDeviceType =
                            value; // Update selected device type
                        selectedDevice = null; // Reset selected device
                      });

                      if (selectedLocation != null &&
                          selectedDeviceType != null) {
                        fetchDevices(selectedLocation!,
                            selectedDeviceType!); // Fetch devices
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a device type';
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: DropdownSearch<String>(
                    popupProps: PopupProps.menu(
                      showSearchBox: true, // Aktifkan fitur pencarian
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          labelText: 'Search Devices', // Label untuk search bar
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    items: devices
                        .map((device) => device['name'] as String)
                        .toList(),
                    selectedItem: selectedDevice != null
                        ? devices.firstWhere(
                            (device) =>
                                device['id'].toString() == selectedDevice,
                            orElse: () => {'name': null},
                          )['name']
                        : null,
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Select Devices', // Label dropdown utama
                        border: OutlineInputBorder(),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedDevice = devices
                            .firstWhere(
                                (device) => device['name'] == value)['id']
                            .toString();
                      });
                    },
                  ),
                ),
                SizedBox(height: 10),
                // Dropdown for Service
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: DropdownSearch<dynamic>(
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Select Service',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    items: services, // Tetap menggunakan List<dynamic>
                    itemAsString: (dynamic item) =>
                        item['Name'] ?? '', // Casting saat mengambil 'Name'
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedService = value?[
                            'ServiceID']; // Casting saat mengambil 'ServiceID'
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
                  child: DropdownSearch<dynamic>(
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Select Worker',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    items: workers, // Tetap menggunakan List<dynamic>
                    itemAsString: (dynamic item) =>
                        item['name'] ?? '', // Tampilkan nama worker
                    selectedItem: workers.any(
                            (worker) => worker['login'] == selectedWorkerLogin)
                        ? workers.firstWhere(
                            (worker) => worker['login'] == selectedWorkerLogin)
                        : null, // Validasi item yang dipilih
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedWorkerLogin =
                            value?['login']; // Simpan login worker
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
