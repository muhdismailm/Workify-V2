import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:login_1/src/client/features/home/viewmodels/client_home_viewmodel.dart';
import 'package:login_1/src/core/widgets/success_page.dart';
import 'package:login_1/src/client/screens/CPages/c_homescreen.dart';

class WorkerList extends StatelessWidget {
  const WorkerList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ClientHomeViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.selectedSkill == null) {
          return const Center(
            child: Text(
              'Please select a skill to view available workers.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          );
        }

        if (viewModel.workers.isEmpty) {
          return const Center(
            child: Text(
              'No workers available for the selected skill.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: viewModel.workers.length,
          itemBuilder: (context, index) {
            final workerData = viewModel.workers[index];
            final workerName = workerData['name']?.toString() ?? 'Unknown Worker';
            final workerPlace = workerData['place']?.toString() ?? 'Unknown Place';
            final workerExperience = workerData['experience']?.toString() ?? 'Not specified';

            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.engineering_rounded, color: Color(0xFF2196F3), size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(workerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A1A2E))),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 12, color: Colors.grey),
                              const SizedBox(width: 2),
                              Text(workerPlace, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text('$workerExperience experience', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showWorkerDetails(context, workerData, viewModel),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('Book', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showWorkerDetails(
      BuildContext context, Map<String, dynamic> workerData, ClientHomeViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(workerData['name'] ?? 'Worker Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Skill: ${workerData['skill'] ?? 'Not specified'}"),
              const SizedBox(height: 8),
              Text("Experience: ${workerData['experience'] ?? 'Not specified'}"),
              const SizedBox(height: 8),
              Text("Location: ${workerData['place'] ?? 'Not specified'}"),
              const SizedBox(height: 8),
              Text("Contact: ${workerData['phone'] ?? 'Not specified'}"),
              const SizedBox(height: 16),
              const Text('Would you like to book this worker?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nav       = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                nav.pop(); // close dialog
                final success = await viewModel.sendRequest(workerData);
                if (context.mounted) {
                  if (success) {
                    _showBookingSuccess(context);
                  } else {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Failed to send request. Please try again.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
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

  // Navigate to the success page after booking
  void _showBookingSuccess(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SuccessPage(
          title: 'Your Booking is\nSuccessfully Placed!',
          primaryLabel: 'Chat with Vendor',
          primaryIcon: Icons.chat_bubble_outline,
          primaryColor: const Color(0xFF2196F3),
          onPrimary: () {
            // TODO: open chat screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Chat feature coming soon!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          onHome: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const ClientHomePage()),
              (route) => false,
            );
          },
        ),
      ),
    );
  }
}