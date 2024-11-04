import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:planner/providers/trip_provider.dart';
import 'package:planner/widgets/add_activity_w.dart';
import 'package:provider/provider.dart';
import 'activity_screen.dart';
import '../db_setup/database.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  CreateScreenState createState() => CreateScreenState();
}

class CreateScreenState extends State<CreateScreen> {
  late TripProvider tripProvider;
  List<Map<String, dynamic>> days = [];
  int selectedIndex = 0;
  final int maxDays = 10;
  String tripNameForEdit = '';
  Map<int, List<Map<String, dynamic>>> activitiesPerDay = {};
  List<Map<String, dynamic>> availableDays = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    tripProvider = Provider.of<TripProvider>(context);
    days = tripProvider.days;
    activitiesPerDay = tripProvider.activitiesPerDay;
    tripNameForEdit = tripProvider.tripName;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      tripProvider.clearTrip();
    });
    super.dispose();
  }

  void _editDay(int selectedIndex) async {
    List<String> parts = days[selectedIndex]['date'].split('-');
    DateTime initialDate = DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );

    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (newDate != null) {
      setState(() {
        days[selectedIndex]['date'] = DateFormat('dd-MM-yyyy').format(newDate);

        for (int i = selectedIndex - 1; i >= 0; i--) {
          DateTime adjustedDate =
              newDate.subtract(Duration(days: selectedIndex - i));
          days[i]['date'] = DateFormat('dd-MM-yyyy').format(adjustedDate);
        }

        for (int i = selectedIndex + 1; i < days.length; i++) {
          DateTime adjustedDate =
              newDate.add(Duration(days: i - selectedIndex));
          days[i]['date'] = DateFormat('dd-MM-yyyy').format(adjustedDate);
        }
      });
    }
  }

  void _addDay() {
    if (days.length < maxDays) {
      setState(() {
        int dayId = days.length + 1;

        DateTime lastDate = days.isEmpty
            ? DateTime.now()
            : DateFormat('dd-MM-yyyy').parse(days.last['date']!);

        String formattedDate = DateFormat('dd-MM-yyyy').format(
          lastDate.add(const Duration(days: 1)),
        );

        days.add({
          'id': dayId,
          'date': formattedDate,
        });
        selectedIndex = days.length - 1;
      });
    } else {
      _showAlert('You can only add up to $maxDays days.');
    }
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _deleteLastDay() {
    if (days.isNotEmpty) {
      setState(() {
        int dayId = days.last['id'];
        activitiesPerDay.remove(dayId);
        days.removeLast();
        if (selectedIndex >= days.length) {
          selectedIndex = days.length - 1;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 30),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blueAccent, Colors.purpleAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.only(
                          top: 10, bottom: 10, right: 20, left: 20),
                      child: const Text(
                        'Plan Your Upcoming Day!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _addDay,
                        child: Container(
                          height: 110,
                          width: 90,
                          margin: const EdgeInsets.only(left: 12, right: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(104, 81, 163, 1.0),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                offset: Offset(2, 4),
                              ),
                            ],
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 28,
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Add Day",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (days.isNotEmpty)
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(left: 5),
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(days.length, (index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = index;
                                    });
                                  },
                                  child: Container(
                                    height: 110,
                                    width: 100,
                                    margin: const EdgeInsets.all(8),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: selectedIndex == index
                                          ? const Color.fromRGBO(
                                              149, 111, 223, 1.0)
                                          : Colors.white54,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 5,
                                          offset: Offset(2, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Day ${index + 1}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: selectedIndex == index
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '${days[index]['date']}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: selectedIndex == index
                                                ? Colors.white
                                                : Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (days.isNotEmpty && selectedIndex != -1)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildEditButton(),
                          const SizedBox(width: 10),
                          if (selectedIndex == days.length - 1)
                            _buildDeleteButton(),
                        ],
                      ),
                    ),
                  Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                            top: 23, left: 20, right: 20, bottom: 10),
                        padding: const EdgeInsets.all(12),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.grey,
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 4),
                            CustomAddButton(
                              onPressed: () async {
                                if (tripNameForEdit.isNotEmpty) {
                                  _navigateToActivityInput(
                                      context, days[selectedIndex]['id']);
                                } else {
                                  String selectedDate =
                                      days[selectedIndex]['date'];
                                  bool overlap =
                                      await dateOverlapped(selectedDate);

                                  if (!overlap) {
                                    _navigateToActivityInput(
                                        context, days[selectedIndex]['id']);
                                  } else {
                                    _showAlert(
                                        "Oops! It looks like there are already events planned for the selected date in another trip. Please choose a different date");
                                  }
                                }
                              },
                              days: days,
                              selectedIndex: selectedIndex,
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Add Activity",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.deepPurple),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (days.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 8.0, left: 16, right: 16, bottom: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Created Activities:',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${activitiesPerDay[days[selectedIndex]['id']]?.length ?? 0}',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            if (activitiesPerDay[days[selectedIndex]['id']] !=
                                null)
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount:
                                    activitiesPerDay[days[selectedIndex]['id']]!
                                        .length,
                                itemBuilder: (context, index) {
                                  var activity = activitiesPerDay[
                                      days[selectedIndex]['id']]![index];
                                  return Dismissible(
                                    key: UniqueKey(),
                                    direction: DismissDirection.horizontal,
                                    onDismissed: (direction) {
                                      if (direction ==
                                          DismissDirection.endToStart) {
                                        setState(() {
                                          activitiesPerDay[days[selectedIndex]
                                                  ['id']]!
                                              .removeAt(index);
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                "${activity['category']} dismissed"),
                                            action: SnackBarAction(
                                              label: 'Undo',
                                              onPressed: () {
                                                setState(() {
                                                  activitiesPerDay[
                                                          days[selectedIndex]
                                                              ['id']]!
                                                      .insert(index, activity);
                                                });
                                              },
                                            ),
                                          ),
                                        );
                                      } else if (direction ==
                                          DismissDirection.startToEnd) {
                                        _editActivity(activity,
                                            days[selectedIndex]['id']);
                                        setState(() {});
                                      }
                                    },
                                    background: Container(
                                      color: Colors.green,
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Icon(Icons.move_to_inbox,
                                            color: Colors.white),
                                      ),
                                    ),
                                    secondaryBackground: Container(
                                      color: Colors.red,
                                      alignment: AlignmentDirectional.centerEnd,
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Icon(Icons.delete,
                                            color: Colors.white),
                                      ),
                                    ),
                                    child: Card(
                                      color: Colors.purple.shade50,
                                      elevation: 4,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                        tileColor: Colors.purple.shade50,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        title: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              activity['category'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: Colors.purple.shade900,
                                              ),
                                            ),
                                            if (activity.containsKey('priority') && activity['priority'] != null)
                                              Container(
                                                width : 100,
                                                height: 35,
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.white70,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    activity['priority'],
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.purple,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              if (activity.containsKey('description') && activity['description'] != null)
                                                Text(
                                                  activity['description'],
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black87,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.access_time,
                                                        size: 22,
                                                        color: Colors.black,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        activity['time'],
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black54,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      IconButton(
                                                        onPressed: () {
                                                          _editActivity(activity, days[selectedIndex]['id']);
                                                          setState(() {});
                                                        },
                                                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          showMoveDialog(
                                                            context,
                                                            days[selectedIndex]['id'],
                                                            activity,
                                                            index,
                                                          );
                                                        },
                                                        icon: const Icon(Icons.move_up, color: Colors.orangeAccent),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            activitiesPerDay[days[selectedIndex]['id']]!.removeAt(index);
                                                          });
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                              content: Text("${activity['category']} dismissed"),
                                                              action: SnackBarAction(
                                                                label: 'Undo',
                                                                onPressed: () {
                                                                  setState(() {
                                                                    activitiesPerDay[days[selectedIndex]['id']]!.insert(index, activity);
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        onTap: () {
                                          showMoveDialog(context, days[selectedIndex]['id'], activity, index);
                                        },
                                      ),

                                    ),
                                  );
                                },
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 15, left: 30.0, right: 30),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/activity.png',
                                    ),
                                    const Text(
                                      "Create Activity for this Day",
                                      style: TextStyle(
                                          color: Colors.black45, fontSize: 16),
                                    ),
                                  ],
                                ),
                              )
                          ]),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 15, left: 30.0, right: 30),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/do.png',
                              ),
                              const Text(
                                "Create Day",
                                style: TextStyle(
                                    color: Colors.black45, fontSize: 16),
                              ),
                            ],
                          ),
                        )
                    ],
                  )
                ],
              ),
            ),
          ),
          _buildSaveTripButton(days, activitiesPerDay)
        ],
      ),
    );
  }

  void showMoveDialog(BuildContext context, int fromDayId,
      Map<String, dynamic> activity, int index) {
    List<Map<String, dynamic>> availableDays =
        days.where((day) => day['id'] != fromDayId).toList();

    if (availableDays.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Move ${activity['category']} to another day."),
            content: SingleChildScrollView(
              child: ListBody(
                children: availableDays.map((day) {
                  int dayId = day['id'];
                  return ListTile(
                    title: Text(day['date']),
                    onTap: () {
                      moveActivity(fromDayId, dayId, activity, index);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("No others days available "),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Ok"),
              ),
            ],
          );
        },
      );
    }
  }

  void moveActivity(
      int fromDay, int toDay, Map<String, dynamic> activity, int index) {
    setState(() {
      if (activitiesPerDay[fromDay] != null &&
          index >= 0 &&
          index < activitiesPerDay[fromDay]!.length) {
        activitiesPerDay[fromDay]!.removeAt(index);
      }

      activitiesPerDay[toDay] ??= [];
      activitiesPerDay[toDay]!.add(activity);
    });
  }

  void _navigateToActivityInput(BuildContext context, int selectedDayId) async {
    final newActivity = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddActivityScreen(dayId: selectedDayId),
      ),
    );

    if (newActivity != null) {
      setState(() {
        if (newActivity['category'] != null && newActivity['time'] != null) {
          activitiesPerDay[selectedDayId] =
              (activitiesPerDay[selectedDayId] ?? [])..add(newActivity);
        } else {
          print("New activity data is incomplete: $newActivity");
        }
      });
    }
  }

  void _editActivity(Map<String, dynamic> activity, int dayId) async {
    final editedActivity = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddActivityScreen(
          dayId: dayId,
          existingActivity: activity,
        ),
      ),
    );

    if (editedActivity != null) {
      setState(() {
        int index = activitiesPerDay[dayId]!.indexOf(activity);
        if (index != -1) {
          activitiesPerDay[dayId]![index] = editedActivity;
        }
      });
    }
  }

  Widget _buildEditButton() {
    return ElevatedButton(
      onPressed: () {
        _editDay(selectedIndex);
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        backgroundColor: const Color.fromRGBO(163, 90, 200, 1.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Edit',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return ElevatedButton(
      onPressed: _deleteLastDay,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Delete',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildSaveTripButton(List<Map<String, dynamic>> days,
      Map<int, List<Map<String, dynamic>>> activitiesPerDay) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 15.0, top: 10, right: 60, left: 60),
      child: ElevatedButton(
        onPressed: () async {
          if (days.isNotEmpty && activitiesPerDay.isNotEmpty) {
            if (tripNameForEdit.isNotEmpty) {
              if (tripNameForEdit.isNotEmpty) {
                await _saveTrip(days, activitiesPerDay, tripNameForEdit);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a trip name.')),
                );
              }
            } else {
              String? tripName = await _showTripNameDialog(context);

              if (tripName!.isNotEmpty) {
                await _saveTrip(days, activitiesPerDay, tripName);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a trip name.')),
                );
              }
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter all trip details.')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          backgroundColor: Colors.purple,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Save Trip',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<String?> _showTripNameDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    TextEditingController tripNameController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Trip Name'),
          content: Form(
            key: formKey,
            child: TextFormField(
              validator: tripNameValidator,
              controller: tripNameController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Trip Name'),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  String tripName = tripNameController.text;
                  bool exists =
                      await DatabaseHelper().checkTripNameExists(tripName);
                  if (!exists) {
                    Navigator.of(context).pop(tripName);
                  } else {
                    Fluttertoast.showToast(msg: "Trip name already Exists");
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  String? tripNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a valid Trip name';
    }
    if (value.length < 3) {
      return 'Trip name must be at least 3 characters';
    }
    String pattern = r'^[a-zA-Z\s\-]+$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Name can only contain letters, spaces, and hyphens';
    }
    return null;
  }

  Future<bool> dateOverlapped(String selectedDate) async {
    final db = await DatabaseHelper().database;

    final List<Map<String, dynamic>> activities = await db.query(
      'Activities',
      where: 'date = ?',
      whereArgs: [selectedDate],
    );

    return activities.isNotEmpty;
  }

  Future<void> _saveTrip(
      List<Map<String, dynamic>> days1,
      Map<int, List<Map<String, dynamic>>> activitiesPerDay1,
      String tripName) async {
    bool tripNameExists = await DatabaseHelper().checkTripNameExists(tripName);
    if (tripNameExists) {
      await DatabaseHelper().updateTrip(tripName, days, activitiesPerDay);

      final tripProvider = Provider.of<TripProvider>(context, listen: false);
      tripProvider.clearTrip();
      setState(() {
        days.clear();
        activitiesPerDay.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip Updated successfully!')),
      );
    } else {
      await DatabaseHelper().saveTrip(tripName, days1, activitiesPerDay1);

      setState(() {
        days.clear();
        activitiesPerDay.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip saved successfully!')),
      );
    }
  }
}
