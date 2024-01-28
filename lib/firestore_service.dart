import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future addScan(String scanBarcode) async {
    try {
      await firestore.collection('scans').add({
        "scanBarcode": scanBarcode,
        "date": DateTime.now(),
      });
    } catch (e) {
      print(e);
      // Handle error
    }
  }

  Future addAttendance(String qrCodeData) async {
    try {
      await firestore.collection('attendance').add({
        "qrCodeData": qrCodeData,
        "date": DateTime.now(),
      });
    } catch (e) {
      print(e);
      // Handle error
    }
  }

  Stream<QuerySnapshot> getAttendanceStream() {
    return firestore.collection('attendance').snapshots();
  }

  Future addStudent(String studentName, studentStack, studentPosition, String studentID) async {
    try {
      await firestore.collection('students').add({
        "studentName": studentName,
        "studentStack": studentStack,
        "studentPosition": studentPosition,
        "studentID": studentID,
        "signedIn": false, // Initial state is signed out
      });
    } catch (e) {
      print(e);
      // Handle error
    }
  }

  Future<bool> isStudentIDRegistered(String studentID) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await firestore.collection('students').where('studentID', isEqualTo: studentID).get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print(e);
      // Handle error
      return false;
    }
  }

  Future uploadScanData({
    required String qrCodeData,
    required String studentID,
    required BuildContext context,
  }) async {
    try {
      bool isRegistered = await isStudentIDRegistered(studentID);

      if (isRegistered) {
        // Fetch student details including name based on student ID
        DocumentSnapshot<Map<String, dynamic>> studentSnapshot = await firestore
            .collection('students')
            .where('studentID', isEqualTo: studentID)
            .get()
            .then((querySnapshot) => querySnapshot.docs.first);

        String studentName = studentSnapshot["studentName"];

        // Check if the student has already signed in for today
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
            .collection('daily_attendance')
            .where('studentID', isEqualTo: studentID)
            .where('date', isGreaterThan: DateTime.now().subtract(const Duration(days: 1)))
            .get();

        bool alreadySignedInToday = querySnapshot.docs.isNotEmpty;

        if (alreadySignedInToday) {
          // If already signed in today, mark as signed out
          await firestore.collection('daily_attendance').doc(querySnapshot.docs.first.id).update({
            "signedOut": true,
            "signOutTime": DateTime.now(),
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("You have been marked as signed out"),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          // If not signed in today, mark as signed in
          await firestore.collection('daily_attendance').add({
            "qrCodeData": qrCodeData,
            "studentID": studentID,
            "studentName": studentName, // Include student name in the attendance record
            "date": DateTime.now(),
            "signedIn": true,
            "signInTime": DateTime.now(),
            "signedOut": false,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("You have been marked as signed in"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Student ID is not registered"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print(e);
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to upload scan data"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



}
