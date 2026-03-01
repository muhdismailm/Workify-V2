import 'package:flutter/material.dart';
import 'package:login_1/src/worker/features/screens/login/w_logout.dart';
import 'package:login_1/src/worker/features/screens/pages/update_profile.dart'; // Import the profile update screen
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Import the navigation drawer

class WorkerNavigationDrawer extends StatelessWidget {
  final String? userName;
  final String? workerSkill; // Add a parameter for the worker's skill

  const WorkerNavigationDrawer({super.key, this.userName, this.workerSkill});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.amber,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.amber),
                ),
                const SizedBox(height: 10),
                Text(
                  userName ?? 'User', // Display the logged-in user's name
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  workerSkill ?? 'Skill not set', // Display the worker's skill
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.update, color: Colors.grey), // Explicitly set the icon color
            title: const Text('Update Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UpdateProfile(), // Replace with your profile update screen
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout_outlined, color: Colors.grey), // Explicitly set the icon color
            title: const Text('Logout'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WorkerLogoutPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? userName;
  String? workerSkill;

  @override
  void initState() {
    super.initState();
    _fetchWorkerData();
  }
Future<void> _fetchWorkerData() async {
  try {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot workerDoc = await _firestore.collection('worker').doc(user.uid).get();
      if (workerDoc.exists && mounted) {
        Map<String, dynamic> data = workerDoc.data() as Map<String, dynamic>;
        setState(() {
          userName = data['name']?.toString() ?? 'User';
          workerSkill = data['skill']?.toString() ?? 'Skill not set';
        });
        print("Fetched worker data: Name=$userName, Skill=$workerSkill");
      } else {
        print("Worker document does not exist for user: ${user.uid}");
      }
    } else {
      print("No authenticated user found");
    }
  } catch (e) {
    print("Error fetching worker data: $e");
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: GlobalKey<ScaffoldState>(),
      drawer: WorkerNavigationDrawer(
        userName: userName, // Pass the worker's name
        workerSkill: workerSkill, // Pass the worker's skill
      ),
      body: const Center(
        child: Text('Welcome to Worker Home Page'),
      ),
    );
  }
}