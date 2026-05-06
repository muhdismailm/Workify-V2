import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:login_1/src/client/features/home/viewmodels/client_home_viewmodel.dart';

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
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(Icons.person, color: Colors.blue),
                ),
                title: Text(
                  workerName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(workerPlace),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.work, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('Experience: \$workerExperience'),
                      ],
                    ),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    _showWorkerDetails(context, workerData, viewModel);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('View'),
                ),
                isThreeLine: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              Text('Skill: \${workerData['skill'] ?? 'Not specified'}'),
              const SizedBox(height: 8),
              Text('Experience: \${workerData['experience'] ?? 'Not specified'}'),
              const SizedBox(height: 8),
              Text('Location: \${workerData['place'] ?? 'Not specified'}'),
              const SizedBox(height: 8),
              Text('Contact: \${workerData['phone'] ?? 'Not specified'}'),
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
                Navigator.of(context).pop();
                final success = await viewModel.sendRequest(workerData);
                if (context.mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Request sent successfully!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to send request. Please try again.')),
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
}