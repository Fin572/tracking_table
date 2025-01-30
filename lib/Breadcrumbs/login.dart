import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tracking_table/navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String _message = '';
  bool _obscurePassword = true;

  Future<void> _login() async {
    final response = await http.post(
      Uri.parse('https://indoguna.info/Datatable/login.php'),
      body: {
        'username': _usernameController.text,
        'password': _passwordController.text,
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    try {
      // Parsing JSON
      final data = jsonDecode(response.body);

      // Debugging tambahan untuk memverifikasi struktur JSON
      print('Full response data: $data');

      if (data['status'] == 'success') {
        final user = data['user'];
        int groupId = user['group_id'];
        String userId = user['login'];

        print('Parsed groupId: $groupId');
        print('Parsed userId: $userId');

        // Gabungkan semua penyimpanan ke SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // Simpan data utama
        await prefs.setString('login', userId);
        await prefs.setInt('group_id', groupId);

        // Validasi dan simpan userDetails
        if (data['userDetails'] != null && data['userDetails'] is Map) {
          Map<String, dynamic> userDetails = data['userDetails'];

          // Simpan data userDetails
          await prefs.setString('employee_id', userDetails['EmployeeID'] ?? '');
          await prefs.setString(
              'location', userDetails['Location']?.toString() ?? '');
          await prefs.setString('department', userDetails['Department'] ?? '');
          await prefs.setString('name', userDetails['Name'] ?? '');
          await prefs.setString('email', userDetails['Email'] ?? '');
          await prefs.setString('phone', userDetails['Phone'] ?? '');

          print('User details saved for regular user.');
        } else {
          // Admin: Clear userDetails-related keys
          await prefs.setString('employee_id', '');
          await prefs.setString('location', '');
          await prefs.setString('department', '');
          await prefs.setString('name', '');
          await prefs.setString('email', '');
          await prefs.setString('phone', '');

          print('Admin login detected, no userDetails to save.');
        }

        // Debugging untuk memastikan data tersimpan
        print('Final saved data in SharedPreferences:');
        print('Login: ${prefs.getString('login')}');
        print('Group ID: ${prefs.getInt('group_id')}');
        print('Employee ID: ${prefs.getString('employee_id')}');
        print('Location: ${prefs.getString('location')}');
        print('Department: ${prefs.getString('department')}');
        print('Name: ${prefs.getString('name')}');
        print('Email: ${prefs.getString('email')}');
        print('Phone: ${prefs.getString('phone')}');

        // Navigasi ke MainPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainPage(
              user: user,
              groupId: groupId,
              organizations: data['organizations'],
            ),
          ),
        );
      } else {
        setState(() {
          _message = data['message'] ?? 'Username/Password Incorrect';
        });
      }
    } catch (e) {
      print('Error parsing JSON or processing data: $e');
      setState(() {
        _message = 'An error occurred';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                height: 200,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      child: FadeInUp(
                        duration: Duration(milliseconds: 1600),
                        child: Container(
                          margin: EdgeInsets.only(top: 50),
                          child: Center(
                            child: Text(
                              "Welcome",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(30.0),
                child: Column(
                  children: <Widget>[
                    FadeInUp(
                      duration: Duration(milliseconds: 1800),
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Color.fromRGBO(143, 148, 251, 1)),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(143, 148, 251, .2),
                              blurRadius: 20.0,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color:
                                            Color.fromRGBO(143, 148, 251, 1))),
                              ),
                              child: TextField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Username",
                                  hintStyle: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Password",
                                  hintStyle: TextStyle(color: Colors.grey[700]),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    FadeInUp(
                      duration: Duration(milliseconds: 1900),
                      child: GestureDetector(
                        onTap: _login,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              colors: [
                                Color.fromRGBO(143, 148, 251, 1),
                                Color.fromRGBO(143, 148, 251, .6),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "Login",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 70),
                    SizedBox(height: 20),
                    FadeInUp(
                      duration: Duration(milliseconds: 2000),
                      child: Text(
                        _message,
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
