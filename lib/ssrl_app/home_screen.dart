import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:logger/logger.dart';
import 'package:ssrl_attendance_app/sharedprefs.dart';
import 'package:http/http.dart' as http;
import 'package:ssrl_attendance_app/ssrl_app/attendance.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final Logger _logger = Logger();
  final TextEditingController _passwordController = TextEditingController();
  String qrCodeData = 'Unknown';

  Future<void> _scanQRCode() async {
    String barcodeScanRes;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.QR,
      );
      if (barcodeScanRes != '-1') {
        // Get student ID from shared preferences
        String userUid = await getSharedPrefsSavedString("user_uid");
        String pwd = _passwordController.text;

        setState(() {
          qrCodeData = barcodeScanRes;
        });
        await _uploadScanData(userUid, pwd, qrCodeData
            );

        _logger.i('user_uid: $userUid');
        _logger.i('pwd: $pwd');
        _logger.i('scan completed: $qrCodeData');
      } else {
        // User canceled the scan
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Scan canceled by user.'),
          ),
        );
      }
    } on PlatformException catch (e) {
      _logger.e('Failed to scan: $e');
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Failed to scan. Please try again.'),
        ),
      );
    }
  }

  Future<void> _uploadScanData(
      String userUid, String pwd, String qrCodeData) async {

    final String userUid =  await getSharedPrefsSavedString("user_uid");
    final String pwd = _passwordController.text;

    const String apiUrl = 'https://ssrl.onrender.com/api/user/attendance';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_uid': userUid,
          'pwd': pwd,
          'scanned_data': qrCodeData,
        }),
      );

      if (response.statusCode == 200) {
        _logger.i('QR code uploaded successfully');
        _logger.w('response.statusCode ${response.statusCode}');
      } else {
        _logger.e('Failed to upload QR code');
        _logger.w('response.statusCode ${response.statusCode}');
        _logger.w('response.statusCode ${response.body}');
      }
    } catch (error) {
      _logger.e('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Scan"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 150,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/ssrl.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _scanQRCode,
              child: const Text('Scan QR Code'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Attendance()),
                );
              },
              child: const Text('View Students'),
            ),
          ],
        ),
      ),
    );
  }
}
