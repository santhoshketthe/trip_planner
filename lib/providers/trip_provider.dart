import 'package:flutter/material.dart';

class TripProvider with ChangeNotifier {
  List<Map<String, dynamic>> days = [];
  Map<int, List<Map<String, dynamic>>> activitiesPerDay = {};
  String tripName = "";

  void selectTrip(Map<String, dynamic> trip) {
    tripName = trip['tripName'];
    extractTripDataForEditing(trip);
    notifyListeners();
  }

  void clearTrip() {
    tripName = '';
    days.clear();
    activitiesPerDay.clear();
    notifyListeners();
  }

  void extractTripDataForEditing(Map<String, dynamic> trip) {
    days.clear();
    activitiesPerDay.clear();

    final activitiesByDate =
        trip['activities'] as Map<String, List<Map<String, dynamic>>>;
    int dayIndex = 0;

    for (var date in activitiesByDate.keys) {
      days.add({
        'id': dayIndex + 1,
        'date': date,
      });

      activitiesPerDay[dayIndex + 1] = activitiesByDate[date]?.map((activity) {
            return {
              'category': activity['category'],
              'priority': activity['priority'],
              'time': activity['time'],
              'description': activity['description'],
              'dayId': dayIndex + 1
            };
          }).toList() ??
          [];

      dayIndex++;
    }
  }
}
