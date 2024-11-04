import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:planner/providers/trip_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import '../db_setup/database.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  @override
  void initState() {
    super.initState();
    fetchTrips();
  }

  Future<List<Map<String, dynamic>>> fetchTrips() async {
    final db = await DatabaseHelper().database;

    final List<Map<String, dynamic>> trips = await db.query('Trips');
    final List<Map<String, dynamic>> tripDetails = [];

    for (var trip in trips) {
      final List<Map<String, dynamic>> activities = await db.query(
        'Activities',
        where: 'trip_id = ?',
        whereArgs: [trip['name']],
      );

      final Map<String, List<Map<String, dynamic>>> activitiesByDate = {};
      for (var activity in activities) {
        final date = activity['date'];
        if (!activitiesByDate.containsKey(date)) {
          activitiesByDate[date] = [];
        }
        activitiesByDate[date]!.add(activity);
      }

      tripDetails.add({
        'tripName': trip['name'],
        'activities': activitiesByDate,
      });
    }

    return tripDetails;
  }

  Future<void> _downloadPdf(Map<String, dynamic> trip) async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Trip Name: ${trip['tripName']}',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              ...trip['activities'].entries.map((entry) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(entry.key,
                        style: pw.TextStyle(
                            fontSize: 20, fontWeight: pw.FontWeight.bold)),
                    ...entry.value.map((activity) {
                      return pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 5),
                        child: pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                                color: PdfColors.purple, width: 1),
                            borderRadius: pw.BorderRadius.circular(8),
                            color: PdfColors.white,
                          ),
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Category: ${activity['category']}',
                                  style: pw.TextStyle(fontSize: 14)),
                              pw.Text('Time: ${activity['time']}',
                                  style: pw.TextStyle(fontSize: 14)),
                              if (activity['description'] != null &&
                                  activity['description'].isNotEmpty)
                                pw.Text(
                                    'Description: ${activity['description']}',
                                    style: pw.TextStyle(fontSize: 12)),
                              if (activity['priority'] != null &&
                                  activity['priority'].isNotEmpty)
                                pw.Text('Priority: ${activity['priority']}',
                                    style: pw.TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    pw.SizedBox(height: 10),
                  ],
                );
              }).toList(),
            ],
          ),
        );
      },
    ));

    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/trip_${trip['tripName']}.pdf');
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Trip saved to ${file.path}')),
    );
  }

  Future<void> _sharePdf(Map<String, dynamic> trip) async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Trip Name: ${trip['tripName']}',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              ...trip['activities'].entries.map((entry) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(entry.key,
                        style: pw.TextStyle(
                            fontSize: 20, fontWeight: pw.FontWeight.bold)),
                    ...entry.value.map((activity) {
                      return pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 5),
                        child: pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                                color: PdfColors.purple, width: 1),
                            borderRadius: pw.BorderRadius.circular(8),
                            color: PdfColors.white,
                          ),
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Category: ${activity['category']}',
                                  style: const pw.TextStyle(fontSize: 14)),
                              pw.Text('Time: ${activity['time']}',
                                  style: const pw.TextStyle(fontSize: 14)),
                              if (activity['description'] != null &&
                                  activity['description'].isNotEmpty)
                                pw.Text(
                                    'Description: ${activity['description']}',
                                    style: const pw.TextStyle(fontSize: 12)),
                              if (activity['priority'] != null &&
                                  activity['priority'].isNotEmpty)
                                pw.Text('Priority: ${activity['priority']}',
                                    style: const pw.TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    pw.SizedBox(height: 10),
                  ],
                );
              }).toList(),
            ],
          ),
        );
      },
    ));

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/trip_${trip['tripName']}.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'Check out my trip!');
  }

  void deleteTrip(Map<String, dynamic> trip) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Delete Activity"),
            content: const Text("Are you sure want to delete?"),
            actions: [
              TextButton(
                  onPressed: () async {
                    await DatabaseHelper().deleteTrip(trip['tripName']);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Trip  delete successful")));
                  },
                  child: const Text("Yes")),
              TextButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.of(context).pop();
                  },
                  child: const Text("No"))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchTrips(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.isEmpty) {
          return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/travel.png'),
                  const Text("Trips not yet created",style: TextStyle(
                    color: Colors.purple
                  ),),
                ],
              ));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final trips = snapshot.data;

        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 3,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListView.builder(
            itemCount: trips!.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              return Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.horizontal,
                onDismissed: (direction) {
                  if (direction == DismissDirection.startToEnd) {
                    Provider.of<TripProvider>(context, listen: false)
                        .selectTrip(trip);
                    DefaultTabController.of(context).animateTo(0);
                  }
                  if (direction == DismissDirection.endToStart) {
                    deleteTrip(trip);
                  }
                },
                background: Container(
                  color: Colors.green,
                  alignment: AlignmentDirectional.centerStart,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.edit, color: Colors.white),
                  ),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: AlignmentDirectional.centerEnd,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                ),
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 16.0, right: 16, left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trip Name: ${trip['tripName']}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[800],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Divider(color: Colors.purple[300]),
                        const SizedBox(height: 5),
                        Column(
                          children:
                              trip['activities'].entries.map<Widget>((entry) {
                            return Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0, horizontal: 8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.purple[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Day Activities: ${entry.key}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.purple[800],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Column(
                                    children:
                                        entry.value.map<Widget>((activity) {
                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8.0),
                                        padding: const EdgeInsets.all(12.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: Colors.purple, width: 1),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.2),
                                              spreadRadius: 1,
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Category: ${activity['category']}',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Colors.purple[600]),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  if (activity['description'] !=
                                                          null &&
                                                      activity['description']
                                                          .isNotEmpty)
                                                    Text(
                                                      'Description: ${activity['description']}',
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .purple[600]),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                if (activity['priority'] !=
                                                    null)
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8.0,
                                                        vertical: 4.0),
                                                    decoration: BoxDecoration(
                                                      color: Colors.purple[100],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Text(
                                                      'Priority: ${activity['priority']}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Colors.purple[800],
                                                      ),
                                                    ),
                                                  ),
                                                const SizedBox(height: 6),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8.0,
                                                      vertical: 4.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.purple[50],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Text(
                                                    '${activity['time']}',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.purple[800],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () async {
                                await _sharePdf(trip);
                              },
                              icon:
                                  const Icon(Icons.share, color: Colors.purple),
                            ),
                            IconButton(
                              onPressed: () async {
                                await _downloadPdf(trip);
                              },
                              icon: const Icon(Icons.download,
                                  color: Colors.purple),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
