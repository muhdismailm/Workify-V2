import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:login_1/src/worker/features/profile/viewmodels/worker_profile_viewmodel.dart';

// ── Amber worker theme ───────────────────────────────────────────────────────
const Color _kPrimary = Color(0xFFFFA000);
const Color _kAccent  = Color(0xFFFFD54F);
const Color _kBg      = Color(0xFFFFFBF0);

// ── Skill options ────────────────────────────────────────────────────────────
const List<String> _kSkills = [
  'Painter',
  'Carpenter',
  'Plumber',
  'Electrician',
];

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl       = TextEditingController();
  final _phoneCtrl      = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _passwordCtrl   = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _placeCtrl      = TextEditingController();

  String? _selectedSkill;
  bool _obscurePassword = true;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final vm = Provider.of<WorkerProfileViewModel>(context, listen: false);
      if (vm.profileData == null && !vm.isLoading) {
        vm.loadProfile().then((_) => _prefill(vm.profileData));
      } else if (vm.profileData != null) {
        _prefill(vm.profileData);
      }
      _initialized = true;
    }
  }

  void _prefill(Map<String, dynamic>? data) {
    if (data == null) return;
    _nameCtrl.text       = data['name']?.toString()       ?? '';
    _phoneCtrl.text      = data['phone']?.toString()      ?? '';
    _emailCtrl.text      = data['email']?.toString()      ?? '';
    _experienceCtrl.text = data['experience']?.toString() ?? '';
    _placeCtrl.text      = data['place']?.toString()      ?? '';

    final savedSkill = data['skill']?.toString();
    if (savedSkill != null && _kSkills.contains(savedSkill)) {
      setState(() => _selectedSkill = savedSkill);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _experienceCtrl.dispose();
    _placeCtrl.dispose();
    super.dispose();
  }

  // ── Save ─────────────────────────────────────────────────────────────────

  Future<void> _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    // Capture context-dependent objects before the await gap
    final messenger = ScaffoldMessenger.of(context);
    final navigator  = Navigator.of(context);

    final vm = Provider.of<WorkerProfileViewModel>(context, listen: false);
    final success = await vm.updateProfile(
      name:       _nameCtrl.text.trim(),
      phone:      _phoneCtrl.text.trim(),
      email:      _emailCtrl.text.trim(),
      skill:      _selectedSkill ?? '',
      experience: _experienceCtrl.text.trim(),
      place:      _placeCtrl.text.trim(),
      password:   _passwordCtrl.text,
    );

    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Profile saved successfully!'
            : 'Failed to save: ${vm.errorMessage}'),
        backgroundColor: success ? Colors.green : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    if (success) navigator.maybePop();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Consumer<WorkerProfileViewModel>(
        builder: (context, vm, _) {
          // Prefill once data arrives if not already done
          if (_nameCtrl.text.isEmpty &&
              vm.profileData != null &&
              vm.profileData!['name'] != null) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _prefill(vm.profileData));
          }

          return Column(
            children: [
              // ── Gradient header ──────────────────────────────────────────
              _buildHeader(vm),

              // ── Scrollable form sections ─────────────────────────────────
              Expanded(
                child: vm.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: _kPrimary))
                    : Form(
                        key: _formKey,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                          children: [
                            const SizedBox(height: 20),

                            // Personal Information
                            _sectionLabel('Personal Information'),
                            _buildSection([
                              _InfoRow(
                                icon: Icons.person_outline,
                                label: 'Name',
                                child: _field(
                                  controller: _nameCtrl,
                                  hint: 'John Adams',
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Enter your name'
                                      : null,
                                ),
                              ),
                              _divider(),
                              _InfoRow(
                                icon: Icons.email_outlined,
                                label: 'Email',
                                child: _field(
                                  controller: _emailCtrl,
                                  hint: 'email@example.com',
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Enter your email'
                                      : null,
                                ),
                              ),
                              _divider(),
                              _InfoRow(
                                icon: Icons.phone_outlined,
                                label: 'Mobile',
                                child: _field(
                                  controller: _phoneCtrl,
                                  hint: '09XXXXXXXXX',
                                  keyboardType: TextInputType.phone,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Enter phone number';
                                    }
                                    if (v.length != 10) {
                                      return '10 digits required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              _divider(),
                              _InfoRow(
                                icon: Icons.location_on_outlined,
                                label: 'Place',
                                child: _field(
                                  controller: _placeCtrl,
                                  hint: 'City, State',
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Enter your place'
                                      : null,
                                ),
                              ),
                            ]),

                            const SizedBox(height: 20),

                            // Work Details
                            _sectionLabel('Work Details'),
                            _buildSection([
                              // ── Skill Dropdown ─────────────────────────
                              _InfoRow(
                                icon: Icons.build_outlined,
                                label: 'Skill',
                                child: _SkillDropdown(
                                  value: _selectedSkill,
                                  onChanged: (v) =>
                                      setState(() => _selectedSkill = v),
                                ),
                              ),
                              _divider(),
                              _InfoRow(
                                icon: Icons.workspace_premium_outlined,
                                label: 'Experience',
                                child: _field(
                                  controller: _experienceCtrl,
                                  hint: 'e.g. 3 years',
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Enter experience'
                                      : null,
                                ),
                              ),
                            ]),

                            const SizedBox(height: 20),

                            // Security
                            _sectionLabel('Security'),
                            _buildSection([
                              _InfoRow(
                                icon: Icons.lock_outline,
                                label: 'Password',
                                child: TextFormField(
                                  controller: _passwordCtrl,
                                  obscureText: _obscurePassword,
                                  style: const TextStyle(
                                      fontSize: 14, color: Color(0xFF1A1A2E)),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Leave blank to keep current',
                                    hintStyle: const TextStyle(
                                        fontSize: 13, color: Colors.grey),
                                    suffixIcon: GestureDetector(
                                      onTap: () => setState(
                                          () => _obscurePassword =
                                              !_obscurePassword),
                                      child: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: _kPrimary,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v != null &&
                                        v.isNotEmpty &&
                                        v.length < 6) {
                                      return 'Min 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ]),

                            const SizedBox(height: 32),

                            // ── Save button ────────────────────────────────
                            _SaveButton(
                              isLoading: vm.isLoading,
                              onPressed: () => _save(context),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(WorkerProfileViewModel vm) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 12, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kPrimary, _kAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // back + title row
          Row(
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
                'Profile',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20)),
                child: const Text('Help',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Avatar + name
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white24,
                  border: Border.all(color: Colors.white54, width: 2),
                ),
                child: const Icon(Icons.engineering_rounded,
                    color: Colors.white, size: 36),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _nameCtrl.text.isNotEmpty
                        ? _nameCtrl.text
                        : (vm.profileData?['name']?.toString() ?? 'Worker'),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _selectedSkill ?? vm.profileData?['skill']?.toString() ?? 'Skill not set',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
            letterSpacing: 0.4),
      ),
    );
  }

  Widget _buildSection(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() =>
      const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFF0F0F0));

  Widget _field({
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
      ),
      validator: validator,
    );
  }
}

// ── Info row ────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _kPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _kPrimary, size: 20),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ── Skill Dropdown ───────────────────────────────────────────────────────────

class _SkillDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const _SkillDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(
        border: InputBorder.none,
        hintText: 'Select skill',
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
        contentPadding: EdgeInsets.zero,
      ),
      icon: const Icon(Icons.keyboard_arrow_down, color: _kPrimary),
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(16),
      items: _kSkills
          .map((s) => DropdownMenuItem(
                value: s,
                child: Row(
                  children: [
                    Icon(_skillIcon(s), color: _kPrimary, size: 18),
                    const SizedBox(width: 10),
                    Text(s),
                  ],
                ),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (v) =>
          (v == null || v.isEmpty) ? 'Please select a skill' : null,
    );
  }

  IconData _skillIcon(String skill) {
    switch (skill) {
      case 'Painter':      return Icons.brush_outlined;
      case 'Carpenter':    return Icons.carpenter;
      case 'Plumber':      return Icons.plumbing;
      case 'Electrician':  return Icons.bolt_outlined;
      default:             return Icons.build_outlined;
    }
  }
}

// ── Save Button ───────────────────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _SaveButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kPrimary, _kAccent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _kPrimary.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.save_outlined, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}