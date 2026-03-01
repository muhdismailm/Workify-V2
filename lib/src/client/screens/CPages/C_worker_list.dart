import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class WorkerList extends StatelessWidget {
  final bool isLoading;
  final String? selectedSkill;
  final List<DocumentSnapshot> workers;
  final Function(BuildContext, Map<String, dynamic>) onBookWorker;

  const WorkerList({
    super.key,
    required this.isLoading,
    required this.selectedSkill,
    required this.workers,
    required this.onBookWorker,
  });

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : selectedSkill == null
            ? const Center(
                child: Text(
                  'Please select a skill to view available workers.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              )
            : workers.isEmpty
                ? const Center(
                    child: Text(
                      'No workers available for the selected skill.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: workers.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> workerData =
                          workers[index].data() as Map<String, dynamic>;
                      final workerName =
                          workerData['name']?.toString() ?? 'Unknown Worker';
                      final workerPlace =
                          workerData['place']?.toString() ?? 'Unknown Place';
                      final workerExperience =
                          workerData['experience']?.toString() ??
                              'Not specified';

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: const Icon(Icons.person, color: Colors.blue),
                          ),
                          title: Text(
                            workerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(workerPlace),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.work,
                                      size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text('Experience: $workerExperience'),
                                ],
                              ),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              _showWorkerDetails(context, workerData);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('View'),
                          ),
                          isThreeLine: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                      );
                    },
                  );
  }

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
              onPressed: () async {
                await _sendRequest(context, workerData);
                Navigator.of(context).pop();
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

  Future<void> _sendRequest(BuildContext context, Map<String, dynamic> workerData) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Get client details
        String clientName = user.displayName ?? user.email?.split('@')[0] ?? 'Unknown Client';
        String clientContact = user.email ?? 'Unknown Contact';

        // Fetch worker phone number from Firestore
        String workerPhone = workerData['phone'] ?? 'Unknown Phone';

        // Store request in Realtime Database
        DatabaseReference requestRef = FirebaseDatabase.instance.ref('requests').push();
        await requestRef.set({
          'workerName': workerData['name'],
          'workerSkill': workerData['skill'],
          'workerPhone': workerPhone, // Add worker phone number
          'clientName': clientName,
          'clientContact': clientContact,
          'timestamp': DateTime.now().toIso8601String(),
          'status': 'Pending', // Default status
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent successfully!')),
        );
      }
    } catch (e) {
      print('Error sending request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send request. Please try again.')),
      );
    }
  }
}

Future<void> createRequest({
  required String workerName,
  required String workerSkill,
  required String clientName,
  required String clientPhone,
  required String clientEmail,
}) async {
  try {
    final DatabaseReference ref = FirebaseDatabase.instance.ref('requests');

    // Push a new request to the 'requests' node
    await ref.push().set({
      'workerName': workerName,
      'workerSkill': workerSkill,
      'clientName': clientName,
      'clientPhone': clientPhone, // Add client phone number
      'clientEmail': clientEmail, // Add client email
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'Pending', // Default status
    });

    print('Request created successfully.');
  } catch (e) {
    print('Error creating request: $e');
  }
}