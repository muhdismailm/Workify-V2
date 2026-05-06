import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:login_1/src/worker/features/home/viewmodels/worker_home_viewmodel.dart';
import 'package:login_1/src/worker/features/screens/pages/w_navigation.dart';
import 'package:login_1/src/worker/features/screens/pages/w_requests.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  // Calendar-related variables
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _showCalendar = false;
  final bool _showRatings = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WorkerRequestsPage()),
      );
    } else if (index == 2) {
      _scaffoldKey.currentState?.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<WorkerHomeViewModel>(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: WorkerNavigationDrawer(
        userName: viewModel.workerName,
        workerSkill: viewModel.workerSkill,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Navigation Bar with Welcome Message and Profile Icon
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 42),
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            child: const Icon(Icons.person, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'WELCOME',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              viewModel.workerName ?? 'Worker',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // My Calendar Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'My Calendar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showCalendar = !_showCalendar;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text(
                          _showCalendar ? 'Hide Calendar' : 'View Calendar',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (_showCalendar)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2000, 1, 1),
                    lastDay: DateTime.utc(2100, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    calendarStyle: const CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // My Ratings Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'My Ratings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    StreamBuilder<DatabaseEvent>(
                      stream: viewModel.getRTDBRatingsStream(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                          return const Center(child: Text('No ratings yet.'));
                        }

                        Map<dynamic, dynamic> ratings =
                            snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

                        double totalRating = 0;
                        int count = 0;

                        ratings.forEach((key, value) {
                          totalRating += value['rating'];
                          count++;
                        });

                        double averageRating = count > 0 ? totalRating / count : 0;

                        return Center(
                          child: Text(
                            'Average Rating: \${averageRating.toStringAsFixed(1)} / 5',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (_showRatings)
                SizedBox(
                  height: 300,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: viewModel.getFirestoreRatingsStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final ratings = snapshot.data!.docs;

                      if (ratings.isEmpty) {
                        return const Center(
                          child: Text(
                            'No ratings yet.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: ratings.length,
                        itemBuilder: (context, index) {
                          final rating = ratings[index];
                          final clientName = rating['clientName'] ?? 'Unknown Client';
                          final review = rating['review'] ?? 'No Review';
                          final stars = rating['rating'] ?? 'No Rating';

                          return ListTile(
                            leading: const Icon(Icons.star, color: Colors.amber),
                            title: Text(clientName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Rating: \$stars'),
                                Text('Review: \$review'),
                              ],
                            ),
                            isThreeLine: true,
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber,
        onTap: _onItemTapped,
      ),
    );
  }
}