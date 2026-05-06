import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:login_1/src/client/screens/CPages/update_profile.dart';
import 'package:login_1/src/client/screens/login/c_logout.dart';

const Color kClientPrimary = Color(0xFF2196F3);
const Color kClientAccent = Color(0xFF03A9F4);

class ClientNavigationDrawer extends StatelessWidget {
  final String? userName;
  const ClientNavigationDrawer({super.key, this.userName});

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
                colors: [kClientPrimary, kClientAccent],
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
                    child: FaIcon(FontAwesomeIcons.circleUser, size: 36, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  userName ?? 'Client',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Text('Client Account', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildTile(
            icon: FontAwesomeIcons.userPen,
            title: 'Update Profile',
            color: kClientPrimary,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UpdateProfile()));
            },
          ),
          const Divider(indent: 16, endIndent: 16),
          _buildTile(
            icon: FontAwesomeIcons.rightFromBracket,
            title: 'Logout',
            color: Colors.redAccent,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientLogoutPage()));
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
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
