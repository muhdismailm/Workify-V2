import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:login_1/src/worker/features/profile/viewmodels/worker_profile_viewmodel.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final viewModel = Provider.of<WorkerProfileViewModel>(context, listen: false);
      if (viewModel.profileData == null && !viewModel.isLoading) {
        viewModel.loadProfile().then((_) => _prefillData(viewModel.profileData));
      } else if (viewModel.profileData != null) {
        _prefillData(viewModel.profileData);
      }
      _initialized = true;
    }
  }

  void _prefillData(Map<String, dynamic>? data) {
    if (data != null) {
      _nameController.text = data['name']?.toString() ?? '';
      _phoneController.text = data['phone']?.toString() ?? '';
      _emailController.text = data['email']?.toString() ?? '';
      _skillController.text = data['skill']?.toString() ?? '';
      _experienceController.text = data['experience']?.toString() ?? '';
      _placeController.text = data['place']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _skillController.dispose();
    _experienceController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final viewModel = Provider.of<WorkerProfileViewModel>(context, listen: false);
      
      final success = await viewModel.updateProfile(
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        skill: _skillController.text,
        experience: _experienceController.text,
        place: _placeController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: \${viewModel.errorMessage}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
        backgroundColor: Colors.amber,
      ),
      body: Consumer<WorkerProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_nameController.text.isEmpty && viewModel.profileData != null && viewModel.profileData!['name'] != null) {
            _prefillData(viewModel.profileData);
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      } else if (value.length != 10) {
                        return 'Phone number must be 10 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password (leave blank to keep current)'),
                    obscureText: true,
                    validator: (value) {
                      if (value != null && value.isNotEmpty && value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _skillController,
                    decoration: const InputDecoration(labelText: 'Skill'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your skill';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _experienceController,
                    decoration: const InputDecoration(labelText: 'Experience'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your experience';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _placeController,
                    decoration: const InputDecoration(labelText: 'Place'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your place';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => _updateProfile(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}