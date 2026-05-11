import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:login_1/src/worker/features/home/viewmodels/worker_home_viewmodel.dart';
import 'package:login_1/src/worker/features/screens/pages/w_navigation.dart';
import 'package:login_1/src/worker/features/screens/pages/w_requests.dart';
import 'package:firebase_database/firebase_database.dart';

const Color kWorkerPrimary = Color(0xFFFFA000);
const Color kWorkerAccent = Color(0xFFFFD54F);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  // Calendar-related variables
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _showCalendar = false;
  bool _showRatings = false;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 0) {
      // Already on Home
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WorkerRequestsPage()),
      );
    } else if (index == 2) {
      _scaffoldKey.currentState?.openDrawer();
      setState(() => _selectedIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<WorkerHomeViewModel>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F8FF),
      drawer: WorkerNavigationDrawer(
        userName: viewModel.workerName,
        workerSkill: viewModel.workerSkill,
      ),
      body: SafeArea(
        child: StreamBuilder<DatabaseEvent>(
          stream: viewModel.getRequestsStream(),
          builder: (context, snapshot) {
            // Calculate Stats and Recent Requests
            int pendingCount = 0;
            int activeCount = 0;
            double totalEarnings = 0.0;
            List<Map<String, dynamic>> recentRequests = [];

            if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
              final raw = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
              raw.forEach((key, value) {
                if (value['workerName'] == viewModel.workerName) {
                  final status = value['status'] ?? 'Pending';
                  if (status == 'Pending') pendingCount++;
                  if (status == 'Accepted') activeCount++;
                  if (status == 'Completed' || status == 'Accepted') {
                    final price = double.tryParse(value['price']?.toString() ?? '0') ?? 0;
                    totalEarnings += price;
                  }
                  
                  recentRequests.add({
                    'key': key,
                    'status': status,
                    'clientName': value['clientName'] ?? 'Client',
                    'timestamp': value['timestamp'],
                  });
                }
              });

              recentRequests.sort((a, b) {
                final t1 = a['timestamp']?.toString() ?? '';
                final t2 = b['timestamp']?.toString() ?? '';
                return t2.compareTo(t1);
              });

              if (recentRequests.length > 3) {
                recentRequests = recentRequests.sublist(0, 3);
              }
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  // 1. Header with Availability Toggle
                  _buildHeader(viewModel),

                  // 2. Quick Stats Row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    child: Row(
                      children: [
                        Expanded(child: _buildStatCard('Pending', pendingCount.toString(), Icons.pending_actions, Colors.orange)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard('Active', activeCount.toString(), Icons.play_circle_outline, Colors.blue)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard('Earned', '\$$totalEarnings', Icons.attach_money, Colors.green)),
                      ],
                    ),
                  ),

                  // 3. Recent Requests Preview
                  if (recentRequests.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Recent Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: () => _onItemTapped(1),
                            child: const Text('View All', style: TextStyle(color: kWorkerPrimary)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: recentRequests.length,
                        itemBuilder: (ctx, i) => _buildMiniRequestCard(recentRequests[i], viewModel),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // 4. Calendar Section
                  _buildCalendarSection(),

                  const SizedBox(height: 16),

                  // 5. Interactive Ratings Section
                  _buildRatingsSection(viewModel),
                  
                  const SizedBox(height: 30),
                ],
              ),
            );
          }
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, -4)),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.house, size: 20), label: 'Home'),
            BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.clipboardList, size: 20), label: 'Requests'),
            BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.helmetSafety, size: 20), label: 'Account'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: kWorkerPrimary,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildHeader(WorkerHomeViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kWorkerPrimary, kWorkerAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white54, width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white24,
                    child: FaIcon(FontAwesomeIcons.helmetSafety, color: Colors.white, size: 18),
                  ),
                ),
              ),
              // Availability Toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      viewModel.isAvailable ? 'Online' : 'Offline',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 24,
                      width: 40,
                      child: Switch(
                        value: viewModel.isAvailable,
                        onChanged: (val) => viewModel.toggleAvailability(val),
                        activeColor: Colors.greenAccent,
                        inactiveThumbColor: Colors.grey.shade300,
                        inactiveTrackColor: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${viewModel.workerName ?? 'Worker'} 👋',
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Manage your jobs & requests',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildMiniRequestCard(Map<String, dynamic> request, WorkerHomeViewModel viewModel) {
    final status = request['status'] as String;
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12, bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: kWorkerPrimary.withOpacity(0.2),
                child: const Icon(Icons.person, size: 16, color: kWorkerPrimary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  request['clientName'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(status, style: TextStyle(color: status == 'Pending' ? Colors.orange : Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (status == 'Pending')
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await viewModel.acceptRequest(request['key']);
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Accepted!')));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kWorkerPrimary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 30),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Accept', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            )
          else
            ElevatedButton(
              onPressed: () => _onItemTapped(1),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade100,
                foregroundColor: Colors.black,
                padding: EdgeInsets.zero,
                minimumSize: const Size(double.infinity, 30),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('View', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_month, color: kWorkerPrimary),
            title: const Text('My Calendar', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: IconButton(
              icon: Icon(_showCalendar ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
              onPressed: () => setState(() => _showCalendar = !_showCalendar),
            ),
            onTap: () => setState(() => _showCalendar = !_showCalendar),
          ),
          if (_showCalendar)
            Padding(
              padding: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
              child: TableCalendar(
                firstDay: DateTime.utc(2000, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (sDay, fDay) => setState(() { _selectedDay = sDay; _focusedDay = fDay; }),
                onFormatChanged: (format) => setState(() => _calendarFormat = format),
                onPageChanged: (fDay) => _focusedDay = fDay,
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(color: kWorkerAccent, shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(color: kWorkerPrimary, shape: BoxShape.circle),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRatingsSection(WorkerHomeViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.star_rounded, color: Colors.amber),
            title: const Text('My Ratings', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: IconButton(
              icon: Icon(_showRatings ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
              onPressed: () => setState(() => _showRatings = !_showRatings),
            ),
            onTap: () => setState(() => _showRatings = !_showRatings),
          ),
          StreamBuilder<DatabaseEvent>(
            stream: viewModel.getRTDBRatingsStream(),
            builder: (context, snapshot) {
              double avg = 0;
              if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                final ratings = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                double total = 0;
                int count = 0;
                ratings.forEach((k, v) {
                  if (v['workerName'] == viewModel.workerName) {
                    total += v['rating'] ?? 0;
                    count++;
                  }
                });
                if (count > 0) avg = total / count;
              }
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Average Rating: ', style: TextStyle(color: Colors.grey)),
                    Text('\${avg.toStringAsFixed(1)} / 5.0', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Icon(Icons.star, color: Colors.orange.shade600, size: 20),
                  ],
                ),
              );
            },
          ),
          if (_showRatings)
            StreamBuilder<DatabaseEvent>(
              stream: viewModel.getRTDBRatingsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return const Padding(padding: EdgeInsets.all(16), child: Text('No reviews yet.', style: TextStyle(color: Colors.grey)));
                }

                final raw = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                final reviews = raw.values.where((v) => v['workerName'] == viewModel.workerName).toList();

                if (reviews.isEmpty) {
                  return const Padding(padding: EdgeInsets.all(16), child: Text('No reviews yet.', style: TextStyle(color: Colors.grey)));
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return ListTile(
                      title: Text(review['clientName'] ?? 'Client', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: (review['review'] != null && review['review'].toString().isNotEmpty)
                        ? Text(review['review'], style: const TextStyle(fontSize: 13))
                        : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(review['rating']?.toString() ?? '0', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Icon(Icons.star, color: Colors.orange.shade600, size: 16),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}