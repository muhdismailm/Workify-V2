import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:login_1/src/client/features/home/viewmodels/client_home_viewmodel.dart';
import 'package:login_1/src/client/screens/CPages/request.dart';
import 'package:login_1/src/client/screens/CPages/c_navigation.dart';
import 'package:login_1/src/client/screens/CPages/C_worker_list.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<String> skills = ['Electrician', 'Plumber', 'Carpenter', 'Painter'];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch user data via Provider after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // The ViewModel automatically fetches the name in its constructor,
      // but we can ensure it's ready or refresh if needed.
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ClientHomePage()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BookedServicesPage()),
      );
    } else if (index == 2) {
      _scaffoldKey.currentState?.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // The drawer requires the name, we can pass it from the ViewModel
      drawer: Consumer<ClientHomeViewModel>(
        builder: (context, viewModel, child) {
          return ClientNavigationDrawer(userName: viewModel.clientName);
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 42),
              decoration: const BoxDecoration(
                color: Colors.blue,
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
                      Consumer<ClientHomeViewModel>(
                        builder: (context, viewModel, child) {
                          return Column(
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
                                viewModel.clientName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Consumer<ClientHomeViewModel>(
                builder: (context, viewModel, child) {
                  return DropdownButtonFormField<String>(
                    initialValue: viewModel.selectedSkill,
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
                      viewModel.selectSkill(newValue);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Expanded(
              child: WorkerList(),
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
}