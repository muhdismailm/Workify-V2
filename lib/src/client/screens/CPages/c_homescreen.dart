import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login_1/src/client/screens/CPages/request.dart'; // Import the booked services screen
import 'package:login_1/src/client/screens/CPages/c_navigation.dart'; // Import the client navigation drawer
import 'package:login_1/src/client/screens/CPages/C_worker_list.dart'; // Import the WorkerList widget

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Key to control the drawer
  String? name;

  // Dropdown-related variables
  String? selectedSkill;
  List<String> skills = ['Electrician', 'Plumber', 'Carpenter', 'Painter'];
  List<DocumentSnapshot> workers = [];
  bool isLoading = false;

  // Bottom Navigation Bar-related variables
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // First try to get from 'clients' collection
        DocumentSnapshot userDoc = await _firestore.collection('clients').doc(user.uid).get();

        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            name = userData['name']?.toString() ?? 'User';
          });
          print("Found user in clients collection: $name");
        } else {
          // If not found in 'clients', try 'users' collection
          DocumentSnapshot userDoc2 = await _firestore.collection('users').doc(user.uid).get();
          if (userDoc2.exists) {
            Map<String, dynamic> userData = userDoc2.data() as Map<String, dynamic>;
            setState(() {
              name = userData['name']?.toString() ?? 'User';
            });
            print("Found user in users collection: $name");
          } else {
            // If not found in either collection, use email as fallback
            setState(() {
              name = user.email?.split('@')[0] ?? 'User';
            });
            print("User document not found, using email fallback");
          }
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> _fetchWorkers(String skill) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Try with the correct collection name and field
      QuerySnapshot querySnapshot = await _firestore
          .collection('worker') // Changed from 'workers' to 'worker'
          .where('skill', isEqualTo: skill) // Changed from 'skills' to 'skill'
          .get();

      print("Found ${querySnapshot.docs.length} workers with skill: $skill");

      if (mounted) {
        setState(() {
          workers = querySnapshot.docs;
          isLoading = false;
        });
      }

      // Print details of found workers for debugging
      for (var worker in workers) {
        Map<String, dynamic> data = worker.data() as Map<String, dynamic>;
        print("Worker: ${data['name']}, Skill: ${data['skill']}");
      }
    } catch (e) {
      print("Error fetching workers: $e");
      if (mounted) {
        setState(() {
          workers = [];
          isLoading = false;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to different screens based on the selected index
    if (index == 0) {
      // Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ClientHomePage()),
      );
    } else if (index == 1) {
      // Bookings
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BookedServicesPage()),
      );
    } else if (index == 2) {
      // Account
      _scaffoldKey.currentState?.openDrawer(); // Open the navigation drawer for account
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the key to the Scaffold
      drawer: ClientNavigationDrawer(userName: name), // Use the correct navigation drawer class
      body: SafeArea(
        child: Column(
          children: [
            // Navigation Bar with Welcome Message and Profile Icon
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 42),
              decoration: const BoxDecoration(
                color: Colors.blue, // Background color for the navigation bar
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
                          _scaffoldKey.currentState?.openDrawer(); // Open the drawer when tapped
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
                            name ?? 'User', // Display the logged-in client's name
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

            // Dropdown for selecting skill
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonFormField<String>(
                initialValue: selectedSkill,
                decoration: InputDecoration(
                  labelText: 'Select work',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: skills.map((String skill) {
                  return DropdownMenuItem<String>(
                    value: skill,
                    child: Text(skill),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedSkill = newValue;
                  });
                  if (newValue != null) {
                    _fetchWorkers(newValue); // Fetch workers for the selected skill
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // Display workers based on selected skill
            Expanded(
              child: WorkerList(
                isLoading: isLoading,
                selectedSkill: selectedSkill,
                workers: workers,
                onBookWorker: _showWorkerDetails,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'My Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  // Method to show worker details and booking option
  void _showWorkerDetails(BuildContext context, Map<String, dynamic> workerData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(workerData['name'] ?? 'Worker Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Skill: ${workerData['skill'] ?? 'Not specified'}'),
              const SizedBox(height: 8),
              Text('Experience: ${workerData['experience'] ?? 'Not specified'}'),
              const SizedBox(height: 8),
              Text('Location: ${workerData['place'] ?? 'Not specified'}'),
              const SizedBox(height: 8),
              Text('Contact: ${workerData['phone'] ?? 'Not specified'}'),
              const SizedBox(height: 16),
              const Text('Would you like to book this worker?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement booking functionality
                Navigator.of(context).pop();
                // You can add navigation to a booking form or direct booking logic here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('Request Now'),
            ),
          ],
        );
      },
    );
  }
}