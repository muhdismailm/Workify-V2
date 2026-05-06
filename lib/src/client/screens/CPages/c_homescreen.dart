import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:login_1/src/client/features/home/viewmodels/client_home_viewmodel.dart';
import 'package:login_1/src/client/screens/CPages/request.dart';
import 'package:login_1/src/client/screens/CPages/c_navigation.dart';
import 'package:login_1/src/client/screens/CPages/C_worker_list.dart';

const Color kClientPrimary = Color(0xFF2196F3);
const Color kClientLight = Color(0xFFE3F2FD);
const Color kClientAccent = Color(0xFF03A9F4);

// ── Data models ────────────────────────────────────────────────────────────────

class _Category {
  final String label;
  final IconData icon;
  final String skill; // maps to Firestore skill value
  _Category(this.label, this.icon, this.skill);
}

class _PopularService {
  final String name;
  final String price;
  final IconData icon;
  final Color color;
  final String skill;
  _PopularService(this.name, this.price, this.icon, this.color, this.skill);
}

// ── Widget ─────────────────────────────────────────────────────────────────────

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  final List<_Category> _categories = [
    _Category('Electrician', FontAwesomeIcons.bolt,        'Electrician'),
    _Category('Plumber',     FontAwesomeIcons.faucet,      'Plumber'),
    _Category('Carpenter',   FontAwesomeIcons.hammer,      'Carpenter'),
    _Category('Painter',     FontAwesomeIcons.paintRoller, 'Painter'),
  ];

  final List<_PopularService> _popular = [
    _PopularService('Electrician', 'from \$40/hr', FontAwesomeIcons.bolt,        Color(0xFFE3F2FD), 'Electrician'),
    _PopularService('Plumber',     'from \$35/hr', FontAwesomeIcons.faucet,      Color(0xFFE8F5E9), 'Plumber'),
    _PopularService('Carpenter',   'from \$45/hr', FontAwesomeIcons.hammer,      Color(0xFFFFF3E0), 'Carpenter'),
    _PopularService('Painter',     'from \$30/hr', FontAwesomeIcons.paintRoller, Color(0xFFFCE4EC), 'Painter'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F8FF),
      drawer: Consumer<ClientHomeViewModel>(
        builder: (context, viewModel, child) =>
            ClientNavigationDrawer(userName: viewModel.clientName),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Gradient header ──────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader()),

            // ── Browse by Category ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('BROWSE BY CATEGORY',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E), letterSpacing: 0.5)),
                    GestureDetector(
                      onTap: () {},
                      child: const Text('View all >', style: TextStyle(color: kClientPrimary, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildCategoryGrid()),

            // ── Popular Services ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('POPULAR SERVICES',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E), letterSpacing: 0.5)),
                    GestureDetector(
                      onTap: () {},
                      child: const Text('View all >', style: TextStyle(color: kClientPrimary, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildPopularServices()),

            // ── Available Professionals ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Consumer<ClientHomeViewModel>(
                  builder: (context, viewModel, _) {
                    if (viewModel.selectedSkill == null) return const SizedBox.shrink();
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${viewModel.selectedSkill} Professionals',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E), letterSpacing: 0.5)),
                        const Text('See all', style: TextStyle(color: kClientPrimary, fontSize: 13)),
                      ],
                    );
                  },
                ),
              ),
            ),

            // Worker list as sliver
            SliverToBoxAdapter(
              child: Consumer<ClientHomeViewModel>(
                builder: (context, viewModel, _) {
                  if (viewModel.selectedSkill == null) return const SizedBox.shrink();
                  return const SizedBox(height: 400, child: WorkerList());
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kClientPrimary, kClientAccent],
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
                    child: Icon(Icons.person, color: Colors.white, size: 22),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                child: const Row(children: [
                  Icon(Icons.location_on, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text('Nearby', style: TextStyle(color: Colors.white, fontSize: 13)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer<ClientHomeViewModel>(
            builder: (context, viewModel, child) {
              final hour = DateTime.now().hour;
              final greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(greeting,
                      style: const TextStyle(color: Colors.white60, fontSize: 13, letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  Text('Hello, ${viewModel.clientName} 👋',
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
                  const SizedBox(height: 4),
                  const Text('What service do you need today?',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Category Grid ────────────────────────────────────────────────────────────

  Widget _buildCategoryGrid() {
    return Consumer<ClientHomeViewModel>(
      builder: (context, viewModel, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3.0,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, i) {
              final cat = _categories[i];
              final isSelected = viewModel.selectedSkill == cat.skill;
              return GestureDetector(
                onTap: () => viewModel.selectSkill(cat.skill),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? kClientPrimary : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected ? kClientPrimary.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white24 : kClientLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(cat.icon, size: 18, color: isSelected ? Colors.white : kClientPrimary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(cat.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF1A1A2E),
                            )),
                      ),
                      Icon(Icons.chevron_right, size: 18, color: isSelected ? Colors.white70 : Colors.grey[400]),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ── Popular Services ─────────────────────────────────────────────────────────

  Widget _buildPopularServices() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _popular.length,
        itemBuilder: (context, i) {
          final svc = _popular[i];
          return GestureDetector(
            onTap: () {
              final viewModel = Provider.of<ClientHomeViewModel>(context, listen: false);
              viewModel.selectSkill(svc.skill);
            },
            child: Container(
              width: 155,
              margin: const EdgeInsets.only(right: 14, bottom: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon area (instead of image)
                  Stack(
                    children: [
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: svc.color,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                        ),
                        child: Center(
                          child: Icon(svc.icon, size: 52, color: kClientPrimary.withValues(alpha: 0.7)),
                        ),
                      ),
                      // Arrow button top-right
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_outward, size: 14, color: kClientPrimary),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: Text(svc.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1A1A2E))),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt, size: 14, color: kClientPrimary),
                        const SizedBox(width: 2),
                        Text(svc.price, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Bottom Nav ───────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.house, size: 20),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.calendar, size: 20),
            activeIcon: FaIcon(FontAwesomeIcons.calendarCheck, size: 20),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.circleUser, size: 20),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: kClientPrimary,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ClientHomePage()));
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const BookedServicesPage()));
          } else if (index == 2) {
            _scaffoldKey.currentState?.openDrawer();
          }
        },
      ),
    );
  }
}
