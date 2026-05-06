import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:login_1/src/client/features/requests/viewmodels/client_requests_viewmodel.dart';
import 'package:login_1/src/client/screens/CPages/c_homescreen.dart';

// ── Theme colours (same blue palette as the rest of the client app) ───────────
const Color _kPrimary = Color(0xFF2196F3);
const Color _kAccent  = Color(0xFF03A9F4);
const Color _kBg      = Color(0xFFF5F8FF);

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
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel =
        Provider.of<ClientRequestsViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          // ── Gradient header ──────────────────────────────────────────────
          _buildHeader(),

          // ── Booking list ─────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: viewModel.getRequestsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: _kPrimary),
                  );
                }

                if (snapshot.hasError) {
                  return _buildEmptyState(
                    icon: Icons.error_outline,
                    message: 'Error fetching bookings.',
                    color: Colors.redAccent,
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return _buildEmptyState(
                    icon: Icons.calendar_today_outlined,
                    message: 'No bookings yet.',
                    color: Colors.grey,
                  );
                }

                final raw =
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

                final requestList = raw.entries.map((e) {
                  return {
                    'key': e.key,
                    'workerName': e.value['workerName'],
                    'workerSkill': e.value['workerSkill'],
                    'workerPhone': e.value['workerPhone'],
                    'clientName': e.value['clientName'],
                    'clientContact': e.value['clientContact'],
                    'clientEmail': e.value['clientEmail'],
                    'timestamp': e.value['timestamp'],
                    'status': e.value['status'] ?? 'Pending',
                    'price': e.value['price'],
                    'rating': e.value['rating'],
                  };
                }).toList();

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: requestList.length,
                  itemBuilder: (context, index) =>
                      _BookingCard(
                        request: requestList[index],
                        viewModel: viewModel,
                        onRate: () => _showRatingDialog(
                          context,
                          requestList[index]['workerName'] ?? '',
                          requestList[index]['key'],
                          viewModel,
                        ),
                        onReject: () async {
                          final success = await viewModel
                              .rejectRequest(requestList[index]['key']);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success
                                    ? 'Request cancelled.'
                                    : 'Error cancelling request.'),
                              ),
                            );
                          }
                        },
                      ),
                );
              },
            ),
          ),
        ],
      ),

      // ── Bottom nav ───────────────────────────────────────────────────────
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
            'My Bookings',
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

  Widget _buildEmptyState(
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
              style: TextStyle(fontSize: 15, color: color.withValues(alpha: 0.6))),
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
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Bookings'),
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

  // ── Rating dialog ───────────────────────────────────────────────────────────

  void _showRatingDialog(BuildContext context, String workerName,
      String requestKey, ClientRequestsViewModel viewModel) {
    int? selectedRating;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Rate $workerName'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Please select a rating:'),
                const SizedBox(height: 10),
                // Star row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final star = i + 1;
                    return GestureDetector(
                      onTap: () => setState(() => selectedRating = star),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          selectedRating != null && selectedRating! >= star
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 36,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                onPressed: () async {
                  if (selectedRating == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text('Please select a rating before submitting.')));
                    return;
                  }
                  Navigator.of(context).pop();
                  final success = await viewModel.submitRating(
                      requestKey, workerName, selectedRating!);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(success
                          ? 'Rating submitted successfully!'
                          : 'Failed to submit rating.'),
                    ));
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          );
        });
      },
    );
  }
}

// ── Booking Card ───────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final ClientRequestsViewModel viewModel;
  final VoidCallback onRate;
  final VoidCallback onReject;

  const _BookingCard({
    required this.request,
    required this.viewModel,
    required this.onRate,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final status = (request['status'] ?? 'Pending') as String;
    final workerName = request['workerName'] ?? 'Unknown Worker';
    final skill = request['workerSkill'] ?? 'Service';
    final price = request['price'];
    final rating = request['rating'];
    final ts = request['timestamp'];

    // Format timestamp
    String dateStr = 'Date not set';
    String timeStr = '';
    if (ts != null) {
      try {
        final dt = DateTime.fromMillisecondsSinceEpoch(
            int.parse(ts.toString()));
        // e.g. "06 May 2026, Tuesday"
        const months = [
          'Jan','Feb','Mar','Apr','May','Jun',
          'Jul','Aug','Sep','Oct','Nov','Dec'
        ];
        const days = [
          'Monday','Tuesday','Wednesday',
          'Thursday','Friday','Saturday','Sunday'
        ];
        dateStr =
            '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}, ${days[dt.weekday - 1]}';
        final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        final m = dt.minute.toString().padLeft(2, '0');
        final ampm = dt.hour < 12 ? 'AM' : 'PM';
        timeStr = '$h:$m $ampm';
      } catch (_) {}
    }

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
          // ── Top row: avatar + name + rating + cancel btn ─────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 0),
            child: Row(
              children: [
                // Avatar circle
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
                  child: const Icon(Icons.person, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workerName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF1A1A2E)),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 3),
                          Text(
                            rating != null ? rating.toString() : '—',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Cancel / X button (shown always for pending/accepted)
                if (status == 'Pending' || status == 'Accepted')
                  GestureDetector(
                    onTap: onReject,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _kPrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 16),
                    ),
                  ),
              ],
            ),
          ),

          // ── Service name + price ─────────────────────────────────────────
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

          // ── Divider ──────────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),

          // ── Date / Time / Status row ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                // Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Date',
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 2),
                      Text(dateStr,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1A1A2E))),
                    ],
                  ),
                ),
                // Time
                if (timeStr.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Time',
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 2),
                      Text(timeStr,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1A1A2E))),
                    ],
                  ),
                ],
                const SizedBox(width: 12),
                // Status chip
                _StatusChip(status: status),
              ],
            ),
          ),

          // ── Rate button (only when accepted) ─────────────────────────────
          if (status == 'Accepted')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton.icon(
                  onPressed: onRate,
                  icon: const Icon(Icons.star_outline, size: 18),
                  label: const Text('Rate this Worker'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
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
        bg = const Color(0xFFE3F2FD);
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
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 13),
          const SizedBox(width: 4),
          Text(status,
              style: TextStyle(
                  color: fg,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}