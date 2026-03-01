import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'c_login.dart';

class CSignUpForm extends StatefulWidget {
  const CSignUpForm({super.key});

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<CSignUpForm> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

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

  Future<String> _generateUniqueClientId(String name) async {
    final random = Random();
    String idPrefix = name.trim().toUpperCase().substring(0, min(3, name.length));
    String clientId = '';
    bool exists = true;

    while (exists) {
      String randomDigits = (10 + random.nextInt(90)).toString(); // 2-digit number
      clientId = idPrefix + randomDigits;

      final doc = await _firestore.collection('client').doc(clientId).get();
      exists = doc.exists;
    }

    return clientId;
  }

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;
      final name = _nameController.text.trim();

      if (password == confirmPassword) {
        try {
          final userCredential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          if (userCredential.user != null) {
            String clientId = await _generateUniqueClientId(name);

            await _firestore.collection('client').doc(clientId).set({
              'name': name,
              'email': email,
              'phone': _phoneController.text,
              'role': 'client',
              'clientId': clientId,
              'uid': userCredential.user!.uid,
              'createdAt': FieldValue.serverTimestamp(),
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Client created. ID: $clientId')),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CLogin()),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User creation failed: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
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
                child: ElevatedButton(
                  onPressed: _signup,
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
