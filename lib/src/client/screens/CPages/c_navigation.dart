import 'package:flutter/material.dart';
import 'package:login_1/src/client/screens/CPages/update_profile.dart'; // Import the client profile update screen
import 'package:login_1/src/client/screens/login/c_logout.dart'; // Import the client logout screen

class ClientNavigationDrawer extends StatelessWidget {
  final String? userName;

  const ClientNavigationDrawer({super.key, this.userName});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.blue),
                ),
                const SizedBox(height: 10),
                Text(
                  userName ?? 'User', // Display the logged-in client's name
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Client',
                  style: TextStyle(
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
                  builder: (context) => const UpdateProfile(), // Replace with your client profile update screen
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.login_outlined,color: Colors.grey), // Explicitly set the icon color
            title: const Text('Logout'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ClientLogoutPage(), // Replace with your client logout screen
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}