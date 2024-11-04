import 'package:flutter/material.dart';
import 'package:planner/screens/trips_screen.dart';
import '../screens/create_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child:
      Scaffold(
        appBar: PreferredSize(
          preferredSize:const Size.fromHeight(90),
          child: AppBar(
            // title: const Text(
            //   "Plan it",
            //   style: TextStyle(
            //     fontSize: 22,
            //     color: Colors.white,
            //     fontWeight: FontWeight.bold,
            //     letterSpacing: 1.2,
            //   ),
            // ),
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            bottom: const TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              labelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
              tabs: [
                Tab(icon: Icon(Icons.create), text: "Create"),
                Tab(icon: Icon(Icons.map), text: "Trips"),
              ],
            ),
          ),
        ),

        body: const TabBarView(
          children: [
            CreateScreen(),
            TripsScreen(),
          ],
        ),
      ),
    );
  }
}





