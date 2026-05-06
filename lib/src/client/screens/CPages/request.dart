import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:login_1/src/client/features/requests/viewmodels/client_requests_viewmodel.dart';
import 'package:login_1/src/client/screens/CPages/c_homescreen.dart';

class BookedServicesPage extends StatefulWidget {
  const BookedServicesPage({super.key});

  @override
  State<BookedServicesPage> createState() => _BookedServicesPageState();
}

class _BookedServicesPageState extends State<BookedServicesPage> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ClientHomePage()),
      );
    } else if (index == 1) {
      // Stay on "My Bookings"
    } else if (index == 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account page is under construction.')),
      );
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ClientRequestsViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Bookings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: viewModel.getRequestsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Error fetching requests.'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(
              child: Text(
                'No requests found.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          Map<dynamic, dynamic> requests =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          List<Map<String, dynamic>> requestList = requests.entries.map((entry) {
            return {
              'key': entry.key,
              'workerName': entry.value['workerName'],
              'workerSkill': entry.value['workerSkill'],
              'workerPhone': entry.value['workerPhone'],
              'clientName': entry.value['clientName'],
              'clientContact': entry.value['clientContact'],
              'clientEmail': entry.value['clientEmail'],
              'timestamp': entry.value['timestamp'],
              'status': entry.value['status'] ?? 'Pending',
            };
          }).toList();

          return ListView.builder(
            itemCount: requestList.length,
            itemBuilder: (context, index) {
              final request = requestList[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            request['workerName'] ?? 'Unknown Worker',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Skill: \${request['workerSkill'] ?? 'Unknown Skill'}'),
                      Text('Client: \${request['clientName'] ?? 'Unknown Client'}'),
                      Text('Worker Contact: \${request['workerPhone'] ?? 'Unknown Phone'}'),
                      Text(
                        'Status: \${request['status']}',
                        style: TextStyle(
                          color: request['status'] == 'Accepted' ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (request['status'] == 'Accepted')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _showRatingDialog(context, request['workerName'], request['key'], viewModel);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Rate'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final success = await viewModel.rejectRequest(request['key']);
                                if (context.mounted) {
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Request rejected.')),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Error rejecting request.')),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Reject'),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
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

  void _showRatingDialog(
      BuildContext context, String workerName, String requestKey, ClientRequestsViewModel viewModel) {
    int? selectedRating;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Rate \$workerName'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Please select a rating:'),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    initialValue: selectedRating,
                    decoration: const InputDecoration(
                      labelText: 'Rating',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(5, (index) => index + 1)
                        .map((rating) => DropdownMenuItem<int>(
                              value: rating,
                              child: Text(rating.toString()),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRating = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedRating == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a rating before submitting.')),
                      );
                      return;
                    }

                    Navigator.of(context).pop();
                    final success = await viewModel.submitRating(requestKey, workerName, selectedRating!);
                    
                    if (context.mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Rating submitted successfully!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to submit rating.')),
                        );
                      }
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          }
        );
      },
    );
  }
}