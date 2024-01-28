import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Attendance extends StatefulWidget {
  const Attendance({super.key});

  @override
  AttendanceState createState() => AttendanceState();
}

class AttendanceState extends State<Attendance> {
  late Future<List<Student>> students;
  bool isCardView = true;

  @override
  void initState() {
    super.initState();
    students = fetchStudentData();
  }

  Future<List<Student>> fetchStudentData() async {
    final response =
    await http.get(Uri.parse('https://ssrl.onrender.com/api/users'));

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body)['response'];
      List<Student> studentList =
      responseData.map<Student>((e) => Student.fromJson(e)).toList();
      return studentList;
    } else {
      throw Exception('Failed to load student data');
    }
  }

  Widget buildCardView(List<Student> studentList) {
    return ListView.builder(
      itemCount: studentList.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.all(8.0),
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ListTile(
            title: Text(
              'User ID: ${studentList[index].userUid}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4.0),
                Text(
                  'Date: ${studentList[index].date}',
                  style: const TextStyle(
                    color: Colors.blue,
                  ),
                ),
                Text(
                  'Time In: ${studentList[index].timeIn}',
                  style: const TextStyle(
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4.0),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildTableView(List<Student> studentList) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16.0,
        ),
        dataTextStyle: const TextStyle(
          fontSize: 14.0,
        ),
        columns: const [
          DataColumn(label: Text('User ID')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Time In')),
        ],
        rows: studentList.map((student) {
          return DataRow(
            cells: [
              DataCell(Text(student.userUid)),
              DataCell(Text(student.date)),
              DataCell(Text(student.timeIn)),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.view_module),
            onPressed: () {
              setState(() {
                isCardView = !isCardView;
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Student>>(
        future: students,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No student data available.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          } else {
            List<Student> studentList = snapshot.data!;
            return isCardView
                ? buildCardView(studentList)
                : buildTableView(studentList);
          }
        },
      ),
    );
  }
}

class Student {
  final String userUid;
  final String timeIn;
  final String date;

  Student({
    required this.userUid,
    required this.timeIn,
    required this.date,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      userUid: json['user_uid'] ?? '',
      timeIn: json['time_in'] ?? '',
      date: json['date'] ?? '',
    );
  }
}
