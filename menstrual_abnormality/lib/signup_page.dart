import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:menstrual_abnormality/auth_repository.dart';
import 'package:menstrual_abnormality/user_details_dialog.dart';
import 'package:menstrual_abnormality/validators.dart';
import 'package:menstrual_abnormality/cycle_input_page.dart';

import 'dashboard_page.dart';

class SignupPageState extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  bool isLoading = false;
  bool obscurePassword = true;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  Future<bool> signUp(String email, String password, String confirmPassword, BuildContext context) async {
    emailError = Validators.validateEmail(email);
    passwordError = Validators.validatePassword(password);

    if (password != confirmPassword) {
      confirmPasswordError = "Passwords do not match";
    } else {
      confirmPasswordError = null;
    }

    notifyListeners();

    if (emailError != null || passwordError != null || confirmPasswordError != null) {
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      final result = await _authRepository.signUp(email, password);
      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Signup failed'),
            backgroundColor: Colors.red.shade700,
          ),
        );
        return false;
      }

      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUpWithGoogle(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await _authRepository.signUpWithGoogle();
      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Google sign-up failed'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully with Google!'),
            backgroundColor: Colors.green,
          ),
        );

        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardPage()),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google sign-up error: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _state = SignupPageState();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: AnimatedBuilder(
                  animation: _state,
                  builder: (context, _) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Logo
                              Padding(
                                padding: const EdgeInsets.only(bottom: 24.0),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  height: 80,
                                  semanticLabel: 'App Logo',
                                ),
                              ),

                              const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Sign up to get started',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),

                              // Email
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: const Icon(Icons.email),
                                  errorText: _state.emailError,
                                ),
                                validator: Validators.validateEmail,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                enabled: !_state.isLoading,
                              ),
                              const SizedBox(height: 16),

                              // Password
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock),
                                  errorText: _state.passwordError,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _state.obscurePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: _state.togglePasswordVisibility,
                                  ),
                                ),
                                obscureText: _state.obscurePassword,
                                validator: Validators.validatePassword,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                enabled: !_state.isLoading,
                              ),
                              const SizedBox(height: 16),

                              // Confirm Password
                              TextFormField(
                                controller: _confirmPasswordController,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  prefixIcon: const Icon(Icons.lock),
                                  errorText: _state.confirmPasswordError,
                                ),
                                obscureText: _state.obscurePassword,
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return "Passwords do not match";
                                  }
                                  return null;
                                },
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                enabled: !_state.isLoading,
                              ),
                              const SizedBox(height: 24),

                              // Sign Up Button
                              ElevatedButton(
                                onPressed: _state.isLoading
                                    ? null
                                    : () async {
                                  if (_formKey.currentState?.validate() ?? false) {
                                    final success = await _state.signUp(
                                      _emailController.text.trim(),
                                      _passwordController.text,
                                      _confirmPasswordController.text,
                                      context,
                                    );
                                    if (success && mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Account Created successful!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );

                                      final user = FirebaseAuth.instance.currentUser;
                                      if (user != null) {
                                        final String userId = user.uid; // Get the Firestore document ID

                                        // Navigate to UserDetailsPage, which shows the dialog automatically
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (_) => UserDetailsPage(userId: userId),
                                          ),
                                        );
                                      } else {
                                        print("No user signed up");
                                      }
                                    }
                                  }
                                },
                                child: _state.isLoading
                                    ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : const Text('Sign Up'),
                              ),

                              const SizedBox(height: 24),

                              // OR Divider
                              Row(
                                children: [
                                  Expanded(child: Divider(color: Colors.grey.shade400)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'OR',
                                      style: TextStyle(color: Colors.grey.shade600),
                                    ),
                                  ),
                                  Expanded(child: Divider(color: Colors.grey.shade400)),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Google Sign Up
                              OutlinedButton.icon(
                                onPressed: _state.isLoading
                                    ? null
                                    : () => _state.signUpWithGoogle(context),
                                icon: const Icon(Icons.g_mobiledata, size: 24),
                                label: const Text('Sign Up with Google'),
                              ),

                              const SizedBox(height: 16),

                              // Go to Login
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Already have an account?"),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Back to login
                                    },
                                    child: const Text("Login"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
