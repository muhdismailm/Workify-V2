import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:login_1/src/worker/features/requests/viewmodels/worker_requests_viewmodel.dart';
import 'package:login_1/src/worker/features/screens/pages/HomeScreen.dart';
import 'package:login_1/src/worker/features/screens/pages/w_navigation.dart';
import 'package:login_1/src/core/widgets/success_page.dart';

// ── Amber worker theme colours ────────────────────────────────────────────────
const Color _kPrimary = Color(0xFFFFA000);
const Color _kAccent  = Color(0xFFFFD54F);
const Color _kBg      = Color(0xFFFFFBF0);

class WorkerRequestsPage extends StatefulWidget {
  const WorkerRequestsPage({super.key});

  @override
  State<WorkerRequestsPage> createState() => _WorkerRequestsPageState();
}

class _WorkerRequestsPageState extends State<WorkerRequestsPage> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else if (index == 1) {
      // Stay on Requests
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WorkerNavigationDrawer()),
      );
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel =
        Provider.of<WorkerRequestsViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          // ── Gradient header ────────────────────────────────────────────
          _buildHeader(),

          // ── Request cards list ─────────────────────────────────────────
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: viewModel.getRequestsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: _kPrimary));
                }

                if (snapshot.hasError) {
                  return _emptyState(
                    icon: Icons.error_outline,
                    message: 'Error fetching requests.',
                    color: Colors.redAccent,
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return _emptyState(
                    icon: Icons.inbox_outlined,
                    message: 'No requests yet.',
                    color: Colors.grey,
                  );
                }

                final raw = snapshot.data!.snapshot.value
                    as Map<dynamic, dynamic>;

                final list = raw.entries.map((e) {
                  return {
                    'key': e.key,
                    'workerName':  e.value['workerName'],
                    'workerSkill': e.value['workerSkill'],
                    'clientName':  e.value['clientName'],
                    'clientPhone': e.value['clientPhone'] ??
                        e.value['clientContact'],
                    'clientEmail': e.value['clientEmail'],
                    'timestamp':   e.value['timestamp'],
                    'status':      e.value['status'] ?? 'Pending',
                    'price':       e.value['price'],
                  };
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  itemCount: list.length,
                  itemBuilder: (ctx, i) => _RequestCard(
                    request: list[i],
                    viewModel: viewModel,
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // ── Bottom nav ──────────────────────────────────────────────────────
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kPrimary, _kAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Client Requests',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty state ─────────────────────────────────────────────────────────────

  Widget _emptyState(
      {required IconData icon,
      required String message,
      required Color color}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 60, color: color.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(message,
              style: TextStyle(
                  fontSize: 15, color: color.withValues(alpha: 0.6))),
        ],
      ),
    );
  }

  // ── Bottom nav ─────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4))
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.inbox_outlined),
              activeIcon: Icon(Icons.inbox),
              label: 'Requests'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Account'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: _kPrimary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

// ── Request Card ───────────────────────────────────────────────────────────────

class _RequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final WorkerRequestsViewModel viewModel;

  const _RequestCard({required this.request, required this.viewModel});

  // ── Timestamp formatter ──────────────────────────────────────────────────────
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static const _days = [
    'Monday', 'Tuesday', 'Wednesday',
    'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  String _dateStr(dynamic ts) {
    if (ts == null) return 'Date not set';
    try {
      final dt = DateTime.fromMillisecondsSinceEpoch(int.parse(ts.toString()));
      return '${dt.day.toString().padLeft(2, '0')} ${_months[dt.month - 1]} ${dt.year}, ${_days[dt.weekday - 1]}';
    } catch (_) {
      return ts.toString();
    }
  }

  String _timeStr(dynamic ts) {
    if (ts == null) return '';
    try {
      final dt = DateTime.fromMillisecondsSinceEpoch(int.parse(ts.toString()));
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m ${dt.hour < 12 ? 'AM' : 'PM'}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final status     = (request['status'] ?? 'Pending') as String;
    final clientName = request['clientName'] ?? 'Unknown Client';
    final skill      = request['workerSkill'] ?? 'Service';
    final phone      = request['clientPhone'] ?? '';
    final price      = request['price'];
    final ts         = request['timestamp'];

    final isPending  = status.toLowerCase() == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          // ── Top row: avatar + client name + status chip ─────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 0),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [_kPrimary, _kAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: _kPrimary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child:
                      const Icon(Icons.person, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),

                // Client name + phone
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clientName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF1A1A2E)),
                      ),
                      if (phone.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined,
                                size: 13, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(phone,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Status chip
                _StatusChip(status: status),
              ],
            ),
          ),

          // ── Service name + price ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  skill,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                if (price != null)
                  Text(
                    '\$$price',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: _kPrimary,
                    ),
                  ),
              ],
            ),
          ),

          // ── Divider ─────────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),

          // ── Date / Time row ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Date',
                          style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 2),
                      Text(_dateStr(ts),
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1A1A2E))),
                    ],
                  ),
                ),
                if (_timeStr(ts).isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Time',
                          style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 2),
                      Text(_timeStr(ts),
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1A1A2E))),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // ── Accept / Reject buttons (Pending only) ──────────────────────
          if (isPending)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                children: [
                  // Reject
                  Expanded(
                    child: _ActionButton(
                      label: 'Reject',
                      icon: Icons.close,
                      color: Colors.redAccent,
                      onTap: () => _handleReject(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Accept
                  Expanded(
                    child: _ActionButton(
                      label: 'Accept',
                      icon: Icons.check,
                      color: _kPrimary,
                      filled: true,
                      onTap: () => _handleAccept(context),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Handlers ────────────────────────────────────────────────────────────────

  Future<void> _handleAccept(BuildContext context) async {
    final success = await viewModel.acceptRequest(request['key']);
    if (!context.mounted) return;
    if (success) {
      // Show animated success page
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SuccessPage(
            title: 'Request Accepted\nSuccessfully!',
            primaryLabel: 'Chat with Client',
            primaryIcon: Icons.chat_bubble_outline,
            primaryColor: _kPrimary,
            onPrimary: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chat feature coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            onHome: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomePage()),
                (route) => false,
              );
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Failed to accept request.'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  Future<void> _handleReject(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final success = await viewModel.rejectRequest(request['key']);
    messenger.showSnackBar(SnackBar(
      content: Text(success ? 'Request rejected.' : 'Failed to reject.'),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }
}

// ── Status Chip ────────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'accepted':
        bg = const Color(0xFFE8F5E9);
        fg = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case 'rejected':
        bg = const Color(0xFFFFEBEE);
        fg = Colors.redAccent;
        icon = Icons.cancel_outlined;
        break;
      case 'completed':
        bg = const Color(0xFFFFF8E1);
        fg = _kPrimary;
        icon = Icons.verified_outlined;
        break;
      default: // Pending
        bg = const Color(0xFFFFF8E1);
        fg = const Color(0xFFF59E0B);
        icon = Icons.access_time;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 13),
          const SizedBox(width: 4),
          Text(status,
              style: TextStyle(
                  color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Action Button (Accept / Reject) ───────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 44,
        decoration: BoxDecoration(
          color: filled ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: filled ? null : Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: filled ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: filled ? Colors.white : color),
            ),
          ],
        ),
      ),
    );
  }
}