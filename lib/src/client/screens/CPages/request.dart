import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:login_1/src/client/features/requests/viewmodels/client_requests_viewmodel.dart';
import 'package:login_1/src/client/screens/CPages/c_homescreen.dart';
import 'package:login_1/src/core/screens/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_1/src/core/services/database_service.dart';

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
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Cancel Request'),
                              content: const Text('ARE YOU SURE TO DELETE?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('No'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text('Yes', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                          
                          if (confirm == true) {
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
    int selectedRating = 0;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 20,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Text(
                  'Rate your experience',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'How was your service with $workerName?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 24),
                
                // Star Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    int starValue = index + 1;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedRating = starValue),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: AnimatedScale(
                          scale: selectedRating == starValue ? 1.2 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            selectedRating >= starValue ? Icons.star : Icons.star_border,
                            color: Colors.orange.shade600,
                            size: 52,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: (selectedRating == 0 || isSubmitting)
                        ? null
                        : () async {
                            setModalState(() => isSubmitting = true);
                            try {
                              final db = context.read<DatabaseService>();
                              final clientName = await db.getClientName();
                              
                              final success = await viewModel.submitRating(
                                requestKey: requestKey,
                                workerName: workerName,
                                rating: selectedRating,
                                review: '',
                                clientName: clientName,
                              );
                              
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(success ? 'Thank you for your feedback!' : 'Failed to submit rating.'),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: success ? Colors.green.shade600 : Colors.red.shade600,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                );
                              }
                            } finally {
                              if (context.mounted) setModalState(() => isSubmitting = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPrimary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Submit Rating', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
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

          // ── Action buttons (only when accepted) ─────────────────────────────
          if (status == 'Accepted')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final user = FirebaseAuth.instance.currentUser;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              requestKey: request['key'],
                              currentUserId: user?.uid ?? 'unknown',
                              currentUserName: request['clientName'] ?? user?.displayName ?? 'Client',
                              currentUserRole: 'client',
                              otherParticipantName: workerName,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: const Text('Chat with Vendor'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _kPrimary,
                        side: const BorderSide(color: _kPrimary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
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
                ],
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