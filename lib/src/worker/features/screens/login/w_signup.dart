import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:login_1/src/worker/features/auth/viewmodels/worker_auth_viewmodel.dart';
import 'w_login.dart';
import 'package:login_1/src/worker/features/screens/widgets/w_appbar.dart';

class WSignUpForm extends StatefulWidget {
  const WSignUpForm({super.key});

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<WSignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WAppbar(title: 'Worker Sign Up'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email ID',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter your email ID' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your phone number';
                  if (value.length != 10) return 'Phone number must be 10 digits';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                obscureText: true,
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter your password' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please confirm your password';
                  if (value != _passwordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 40),
              Center(
                child: Consumer<WorkerAuthViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.isLoading) {
                      return const CircularProgressIndicator();
                    }
                    return ElevatedButton(
                      onPressed: () => _signup(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amberAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text('Sign Up'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signup(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final viewModel = Provider.of<WorkerAuthViewModel>(context, listen: false);

      final success = await viewModel.signup(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Worker registered successfully')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WLogin()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(viewModel.errorMessage ?? 'Registration failed')),
        );
      }
    }
  }
}
