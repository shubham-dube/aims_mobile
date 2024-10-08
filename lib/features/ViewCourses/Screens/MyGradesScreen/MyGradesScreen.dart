import 'dart:convert';
import 'dart:core';
import 'dart:core';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:AIMS_MOBILE/app.dart';
import 'package:AIMS_MOBILE/common/theme_provider.dart';
import 'package:AIMS_MOBILE/utils/device/device_utility.dart';
import 'package:AIMS_MOBILE/utils/helper/helper_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class GradeModel {
  final String courseName;
  final String instructorName;
  final String grade;
  final double credits;
  final int semester;

  GradeModel({
    required this.courseName,
    required this.instructorName,
    required this.grade,
    required this.credits,
    required this.semester
  });
}

class MyGradesScreen extends StatefulWidget {
  final String sessionId;
  final String studentName;
  const MyGradesScreen({super.key, required this.sessionId, required this.studentName});

  @override
  State<MyGradesScreen> createState() => _MyGradesScreenState();
}

class _MyGradesScreenState extends State<MyGradesScreen> {
  late Future<List<GradeModel>> _gradesFuture;
  double CGPA = 0;
  String baseUrl = "http://192.168.113.121:5001";
  Map<int, Map<String, String>> semesters = {};
  Map<String, List> coursesData = {};


  @override
  void initState() {
    super.initState();
    _gradesFuture = fetchGrades();
  }

  Future<List<GradeModel>> fetchGrades() async {
    var reqBody = {
      "sessionId": widget.sessionId
    };

    try{
      var jsonResponse = await http.post(
          Uri.parse('$baseUrl/api/v1/getCourseHistory'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(reqBody)
      );

      if(jsonResponse.statusCode == 200){
        final response  = jsonDecode(jsonResponse.body);

        if(response['status'].toLowerCase() == "error"){
          HelperFunctions.showAlert('My Courses', response['message']);
          return [];
        }

        List<GradeModel> courses = [];

        Map<int, Map<String, String>> tempSemesters = {};
        Map<String, int> tempSemesters2 = {};

        int count = 0;
        int numberOfSem = 1;
        for(int i=0;i<response['courses'].length;i++){
          count++;
          if(i!=response['courses'].length-1 && response['courses'][i]['hdrName'] != response['courses'][i+1]['hdrName']){
            tempSemesters[numberOfSem] = {
              "session": response['courses'][i+1]['hdrName'],
              "totalCourses": count.toString(),
            };
            tempSemesters2[response['courses'][i+1]['hdrName']] = numberOfSem;

            tempSemesters[numberOfSem-1]?['totalCourses'] = count.toString();
            numberOfSem++;
            count = 0;
          } else if(i == 0){
            tempSemesters[numberOfSem] = {
              "session": response['courses'][i]['hdrName'],
              "totalCourses": count.toString(),
            };
            tempSemesters2[response['courses'][i]['hdrName']] = numberOfSem;
            numberOfSem++;
          }
        }

        tempSemesters[numberOfSem-1]?['totalCourses'] = count.toString();
        semesters = tempSemesters;

        for(int i=0;i<response['courses'].length;i++){
          if(response['courses'][i]['gradeDesc'].trim() != ""){
            courses.add(
                GradeModel(courseName: response['courses'][i]['courseName'], instructorName: response['courses'][i]['instructorName'],
                    grade: response['courses'][i]['gradeDesc'], credits: double.parse(response['courses'][i]['credits']),
                    semester: tempSemesters2[response['courses'][i]['hdrName']]!)
            );
          }
        }

        for(int i=0;i<response['courses'].length;i++){
          final session = response['courses'][i]['hdrName'];
          if (coursesData[session] == null) {
            coursesData[session] = [];
          }
          if(response['courses'][i]['gradeDesc'].trim() != ""){
            coursesData[session]!.add(response['courses'][i]);
          }
        }

        Map<String, int> gradePoints = {
           "A+":  10,
           "A":  10,
           "A-":  9,
           "B":  8,
           "B-":  7,
           "C":  6,
           "C-":  5,
           "D":  4,
           "F":  0,
           "FR":  0,
           "FS":  0,
        };

        double score = 0;
        double totalScore = 0;

        for(int i=0;i<courses.length; i++){
          score += courses[i].credits*gradePoints[courses[i].grade.trim()]!;
          totalScore += courses[i].credits*10;
        }

        double cgpa = score/totalScore;

        setState(() {
          CGPA = cgpa*10;
        });

        return courses;
      } else {
        HelperFunctions.showAlert("AIMS MOBILE", 'Error in fetching Courses\n Please Login Again.');
      }
    } catch (e){
      print(e);
      bool isConnected = await DeviceUtils.isConnected();
      if(!isConnected) {
        HelperFunctions.showAlert('AIMS MOBILE', 'Please Connect to Internet Connection');
      }
      else {
        HelperFunctions.showAlert('AIMS MOBILE', 'An error occurred while fetching courses ! Please retry again.');
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Grades'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: FutureBuilder<List<GradeModel>>(
          future: _gradesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error fetching grades'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No grades available'));
            }

            List<GradeModel> grades = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSummaryMetrics(),
                const SizedBox(height: 20),
                Text("Graded Courses", style: Theme.of(context).textTheme.headlineSmall,),
                const SizedBox(height: 20),
                buildGradesList(grades),
                // const SizedBox(height: 20),
                // buildBestWorstCourses(grades),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildSummaryMetrics() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: DeviceUtils.getScreenSize(context).width,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.green.shade50
              ),
              child: Text("Overall CGPA: ${CGPA.toStringAsFixed(3)}", style: Theme.of(context).textTheme.bodyLarge?.merge(const TextStyle(color: Colors.green)),),
            ),

            // const SizedBox(height: 5,),
            //
            // Container(
            //   width: DeviceUtils.getScreenSize(context).width,
            //   padding: const EdgeInsets.all(10),
            //   decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(5),
            //       color: Colors.yellow.shade50
            //   ),
            //   child: Column(
            //     // crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text("SGPA's", style: Theme.of(context).textTheme.headlineMedium?.merge( TextStyle(color: Colors.yellow.shade900))),
            //       Text("Semester 1: 8.9", style: Theme.of(context).textTheme.bodyLarge?.merge( TextStyle(color: Colors.yellow.shade900))),
            //       Text("Semester 2: 8.66", style: Theme.of(context).textTheme.bodyLarge?.merge( TextStyle(color: Colors.yellow.shade900))),
            //     ],
            //   ),
            // ),

            const SizedBox(height: 10,),

            SizedBox(
              width: DeviceUtils.getScreenSize(context).width,
              child: ElevatedButton(
                  onPressed: ()=> PdfGenerator.generateGpaSummaryPdf(coursesData, widget.studentName, CGPA),
                  child: const Text("DOWNLOAD GPA SUMMARY")
              ),
            )
          ],
        )
      ),
    );
  }

  Widget buildGradesList(List<GradeModel> grades) {
    return Expanded(
      child: ListView.builder(
        itemCount: grades.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
              title: Text(grades[index].courseName,
                style: Theme.of(context).textTheme.bodyMedium?.merge(const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),),
              subtitle: Text('Credits: ${grades[index].credits}', style: Theme.of(context).textTheme.bodyMedium?.merge(const TextStyle(color: Colors.black45))),
              trailing: Text((grades[index].grade.length==1? "${grades[index].grade}   ": grades[index].grade),
                  style: Theme.of(context).textTheme.headlineSmall?.merge(const TextStyle(color: Colors.green))),
            ),
          );
        },
      ),
    );
  }

}


class PdfGenerator {
  static Future<void> generateGpaSummaryPdf(
      Map<String, List<dynamic>> hdrNamesWithCourses,
      String studentName,
      double CGPA
      ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Student Name
                pw.Text('Name: $studentName',
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),

                pw.Text('Overall CGPA: $CGPA',
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.green)),
                pw.SizedBox(height: 20),

                for (var hdrName in hdrNamesWithCourses.keys) ...[
                  pw.Text(hdrName,
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        decoration: pw.TextDecoration.underline,
                      )),
                  pw.SizedBox(height: 10),

                  for (var course in hdrNamesWithCourses[hdrName]!) ...[
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Course: ${course['courseName']}'),
                        pw.Text('Instructor: ${course['instructorName']}'),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Credits: ${course['credits']}'),
                        pw.Text('Grade: ${course['gradeDesc']}'),
                        pw.Text('Course Code: ${course['courseCd']}'),
                      ],
                    ),
                    pw.Divider(),
                  ],
                  pw.SizedBox(height: 20),
                ]
              ],
            )
          ];
        },
      ),
    );

    // Print or save the generated PDF
    // await Printing.layoutPdf(
    //   onLayout: (PdfPageFormat format) async => pdf.save(),
    // );

    final outputDir = await getApplicationDocumentsDirectory(); // You can also use getApplicationDocumentsDirectory()
    final outputFile = File('${outputDir.path}/gpa_summary.pdf');
    await outputFile.writeAsBytes(await pdf.save());

    // Share or download the PDF
    await Share.shareXFiles([XFile(outputFile.path)], text: 'GPA Summary PDF');
  }
}