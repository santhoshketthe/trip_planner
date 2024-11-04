import 'package:flutter/material.dart';

class AddActivityScreen extends StatefulWidget {
  final int dayId;
  final Map<String, dynamic>? existingActivity;

  const AddActivityScreen(
      {super.key, required this.dayId, this.existingActivity});

  @override
  AddActivityScreenState createState() => AddActivityScreenState();
}

class AddActivityScreenState extends State<AddActivityScreen> {
  String? selectedCategory;
  String? selectedPriority;
  TimeOfDay? pickedTime;
  String? description;

  late TextEditingController _descriptionController;

  final List<String> categories = [
    'Travel',
    'Food',
    'Leisure',
    'Visit',
    'Work',
    'Health',
    'Shopping',
    'Education',
    'Others'
  ];

  final List<String> priorities = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();

    if (widget.existingActivity != null) {
      selectedCategory = widget.existingActivity!['category'];
      String timeString = widget.existingActivity!['time'];
      List<String> timeParts = timeString.split(' ');
      List<String> hourMinute = timeParts[0].split(':');

      int hour = int.parse(hourMinute[0]);
      int minute = int.parse(hourMinute[1]);

      if (timeParts[1] == 'PM' && hour < 12) {
        hour += 12;
      } else if (timeParts[1] == 'AM' && hour == 12) {
        hour = 0;
      }

      pickedTime = TimeOfDay(hour: hour, minute: minute);
      selectedPriority = widget.existingActivity!['priority'];
      description = widget.existingActivity!['description'];

      _descriptionController.text = description ?? '';
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.existingActivity == null ? 'Add Activity' : 'Edit Activity'),
        backgroundColor: const Color.fromRGBO(168, 108, 236, 1.0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Design Your Day, Your Way!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(98, 0, 238, 1),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Select activities, set times, and make every moment count!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildDropdownButton(
                      'Select Category',
                      selectedCategory,
                      categories,
                      (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTimeButton(),
                    const SizedBox(height: 20),
                    _buildPriorityDropdownButton(),
                    const SizedBox(height: 20),
                    _buildTextField(
                        'Description (Optional)', _descriptionController,
                        (value) {
                      setState(() {
                        description = value;
                      });
                    }),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 280,
              child: ElevatedButton(
                onPressed: _addActivity,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 14.0, horizontal: 24.0),
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  widget.existingActivity == null
                      ? "Add Activity"
                      : "Update Activity",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownButton(String hint, String? selectedValue,
      List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.purpleAccent, width: 1.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(
            hint,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          value: selectedValue,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
          dropdownColor: Colors.white,
          items: items.map((value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(color: Colors.black87)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildPriorityDropdownButton() {
    return _buildDropdownButton(
      'Select Priority (Optional)',
      selectedPriority,
      priorities,
      (value) {
        setState(() {
          selectedPriority = value;
        });
      },
    );
  }

  Widget _buildTimeButton() {
    return GestureDetector(
      onTap: () async {
        TimeOfDay? time = await showTimePicker(
          context: context,
          initialTime: pickedTime ?? TimeOfDay.now(),
        );
        if (time != null) {
          setState(() {
            pickedTime = time;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.purple,
            width: 1,
          ),
        ),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(
                left: 10.0, right: 10.0, top: 15, bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  pickedTime != null
                      ? pickedTime!.format(context)
                      : 'Select Time',
                  style: TextStyle(
                    color: pickedTime != null ? Colors.black87 : Colors.grey[600],
                    fontWeight:
                        pickedTime != null ? FontWeight.bold : FontWeight.bold,
                  ),
                ),
                const Icon(Icons.access_time, color: Colors.black),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addActivity() {
    if (selectedCategory == null) {
      _showAlert("Please select a category.");
      return;
    }

    if (pickedTime == null) {
      _showAlert("Please select a time.");
      return;
    }

    Map<String, dynamic> newActivity = {
      'category': selectedCategory,
      'priority': selectedPriority,
      'time': pickedTime!.format(context),
      'description': _descriptionController.text,
      'dayId': widget.dayId,
    };

    if (widget.existingActivity != null) {
      newActivity['id'] = widget.existingActivity!['id'];
    }

    Navigator.pop(context, newActivity);
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      ValueChanged<String?> onChanged) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(color: Colors.purple, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
      ),
      onChanged: onChanged,
    );
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
}
