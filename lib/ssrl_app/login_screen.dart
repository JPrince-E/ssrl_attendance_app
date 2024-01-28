import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:ssrl_attendance_app/sharedprefs.dart';
import 'package:http/http.dart' as http;
import 'package:ssrl_attendance_app/ssrl_app/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final Logger _logger = Logger();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool loading = false;

  // Check if the user is already logged in
  Future<void> checkLoginStatus() async {
    String savedUsername = await getSharedPrefsSavedString("user_uid");
    String savedPassword = await getSharedPrefsSavedString("pwd");

    if (savedUsername.isNotEmpty && savedPassword.isNotEmpty) {
      // Directly navigate to the next screen or perform desired actions
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    loading = false;
  }

  Future<void> _login() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final String userUid = _usernameController.text;
    final String pwd = _passwordController.text;

    // Replace the API URL with your actual authentication API endpoint.
    const String apiUrl = 'https://ssrl.onrender.com/api/user/login';

    try {
      setState(() {
        loading = true;
      });
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_uid': userUid,
          'pwd': pwd,
        }),
      );

      setState(() {
        loading = false;
      });

      if (response.statusCode == 200) {
        saveSharedPrefsStringValue("user_uid", userUid);
        saveSharedPrefsStringValue("pwd", pwd);
        _logger.i("response code: ${response.statusCode}");
        setState(() {
          loading = false;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        setState(() {
          loading = false;
        });
        _logger.e('Login failed');
        _logger.e("response code: ${response.statusCode}");

        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Invalid username or password.'),
          ),
        );

        _logger.i('user_uid: $userUid');
        _logger.i('pwd: $pwd');
      }
    } catch (error) {
      _logger.e('Error: $error');
      setState(() {
        loading = false;
      });
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Failed to connect to the server.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 50,
              ),
              Container(
                height: 200,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/ssrl.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _login,
                child: loading ? const CircularProgressIndicator() :const Text('Login') ,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
