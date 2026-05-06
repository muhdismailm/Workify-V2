import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:login_1/src/client/features/auth/viewmodels/client_auth_viewmodel.dart';
import 'c_login.dart';

class CSignUpForm extends StatefulWidget {
  const CSignUpForm({super.key});

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<CSignUpForm> {
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

  void _signup(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final viewModel = Provider.of<ClientAuthViewModel>(context, listen: false);

      final success = await viewModel.signup(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Client created successfully')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CLogin()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(viewModel.errorMessage ?? 'Sign up failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Client Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('Name', _nameController),
              const SizedBox(height: 20),
              _buildTextField('Email ID', _emailController),
              const SizedBox(height: 20),
              _buildTextField('Phone Number', _phoneController, inputType: TextInputType.number, inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ]),
              const SizedBox(height: 20),
              _buildTextField('Password', _passwordController, obscureText: true),
              const SizedBox(height: 20),
              _buildTextField('Confirm Password', _confirmPasswordController, obscureText: true),
              const SizedBox(height: 40),
              Center(
                child: Consumer<ClientAuthViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.isLoading) {
                      return const CircularProgressIndicator();
                    }
                    return ElevatedButton(
                      onPressed: () => _signup(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
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

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false,
      TextInputType inputType = TextInputType.text,
      List<TextInputFormatter>? inputFormatters}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: inputType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter your $label';
        if (label == 'Phone Number' && value.length != 10) return 'Phone number must be 10 digits';
        if (label == 'Confirm Password' && value != _passwordController.text) return 'Passwords do not match';
        return null;
      },
    );
  }
}
