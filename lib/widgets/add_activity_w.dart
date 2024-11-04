import 'package:flutter/material.dart';

class CustomAddButton extends StatefulWidget {
  final Function onPressed;
  final List<Map<String, dynamic>> days;
  final int selectedIndex;

  const CustomAddButton({
    super.key,
    required this.onPressed,
    required this.days,
    required this.selectedIndex,
  });

  @override
  CustomAddButtonState createState() => CustomAddButtonState();
}

class CustomAddButtonState extends State<CustomAddButton> {
  double _scaleFactor = 1.0;

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _scaleFactor = 0.9;
    });
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _scaleFactor = 1.0;
    });
  }

  void _handleTapCancel() {
    setState(() {
      _scaleFactor = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: () {
        if (widget.days.isEmpty) {
          _showAlert('Please create a day first.');
        } else {
          widget.onPressed();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(_scaleFactor),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              spreadRadius: 4,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(message),
          actions: <Widget>[
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
