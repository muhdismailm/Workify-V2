import 'package:flutter/material.dart';
import 'package:login_1/src/worker/features/screens/login/w_logout.dart';
import 'package:login_1/src/worker/features/screens/pages/update_profile.dart';

const Color kWorkerPrimary = Color(0xFFFFA000);
const Color kWorkerAccent = Color(0xFFFFD54F);

class WorkerNavigationDrawer extends StatelessWidget {
  final String? userName;
  final String? workerSkill;

  const WorkerNavigationDrawer({super.key, this.userName, this.workerSkill});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [kWorkerPrimary, kWorkerAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white54, width: 2)),
                  child: const CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.engineering_rounded, size: 36, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(userName ?? 'Worker', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text(workerSkill ?? 'Skill not set', style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildTile(
            icon: Icons.manage_accounts_outlined,
            title: 'Update Profile',
            color: kWorkerPrimary,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UpdateProfile()));
            },
          ),
          const Divider(indent: 16, endIndent: 16),
          _buildTile(
            icon: Icons.logout_outlined,
            title: 'Logout',
            color: Colors.redAccent,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkerLogoutPage()));
            },
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Workify v1.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildTile({required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}