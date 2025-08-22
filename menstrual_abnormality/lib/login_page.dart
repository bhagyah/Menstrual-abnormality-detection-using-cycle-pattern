import 'package:flutter/material.dart';
import 'package:menstrual_abnormality/auth_repository.dart';
import 'package:menstrual_abnormality/validators.dart';
import 'package:menstrual_abnormality/app_theme.dart';
import 'package:menstrual_abnormality/cycle_input_page.dart';

class LoginPageState extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  
  bool isLoading = false;
  bool obscurePassword = true;
  bool rememberMe = false;
  String? emailError;
  String? passwordError;
  
  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }
  
  void setRememberMe(bool value) {
    rememberMe = value;
    notifyListeners();
  }
  
  Future<bool> signIn(String email, String password, BuildContext context) async {
    emailError = Validators.validateEmail(email);
    passwordError = Validators.validatePassword(password);
    notifyListeners();
    
    if (emailError != null || passwordError != null) {
      return false;
    }
    
    isLoading = true;
    notifyListeners();
    
    try {
      final result = await _authRepository.signIn(email, password);
      
      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Authentication failed'),
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
  
  Future<void> signInWithGoogle(BuildContext context) async {
    isLoading = true;
    notifyListeners();
    
    try {
      final result = await _authRepository.signInWithGoogle();
      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Google sign-in failed'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google sign-in error: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> signInWithApple(BuildContext context) async {
    isLoading = true;
    notifyListeners();
    
    try {
      final result = await _authRepository.signInWithApple();
      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Apple sign-in failed'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Apple sign-in error: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _state = LoginPageState();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
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
                                'Welcome Back',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              const SizedBox(height: 8),
                              
                              const Text(
                                'Sign in to your account',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              const SizedBox(height: 32),
                              
                              // Email Field
                              TextFormField(
                                controller: _emailController,
                                focusNode: _emailFocusNode,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  hintText: 'Enter your email',
                                  prefixIcon: const Icon(Icons.email),
                                  errorText: _state.emailError,
                                ),
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(_passwordFocusNode);
                                },
                                onChanged: (_) {
                                  if (_state.emailError != null) {
                                    setState(() {
                                      _state.emailError = null;
                                    });
                                  }
                                },
                                validator: Validators.validateEmail,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                enabled: !_state.isLoading,
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Password Field
                              TextFormField(
                                controller: _passwordController,
                                focusNode: _passwordFocusNode,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  hintText: 'Enter your password',
                                  prefixIcon: const Icon(Icons.lock),
                                  errorText: _state.passwordError,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _state.obscurePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () => _state.togglePasswordVisibility(),
                                    tooltip: _state.obscurePassword
                                        ? 'Show password'
                                        : 'Hide password',
                                  ),
                                ),
                                obscureText: _state.obscurePassword,
                                textInputAction: TextInputAction.done,
                                onChanged: (_) {
                                  if (_state.passwordError != null) {
                                    setState(() {
                                      _state.passwordError = null;
                                    });
                                  }
                                },
                                validator: Validators.validatePassword,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                enabled: !_state.isLoading,
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Remember me and Forgot password
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _state.rememberMe,
                                        onChanged: _state.isLoading
                                            ? null
                                            : (value) => _state.setRememberMe(value ?? false),
                                        semanticLabel: 'Remember me',
                                      ),
                                      const Text('Remember me'),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: _state.isLoading ? null : () {
                                      // Implement forgot password functionality
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Forgot password functionality not implemented yet'),
                                        ),
                                      );
                                    },
                                    child: const Text('Forgot password?'),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Sign In Button
                              ElevatedButton(
                                onPressed: _state.isLoading
                                    ? null
                                    : () async {
                                        if (_formKey.currentState?.validate() ?? false) {
                                          final success = await _state.signIn(
                                            _emailController.text.trim(),
                                            _passwordController.text,
                                            context,
                                          );
                                          
                                          if (success && mounted) {
                                            // Navigate to home page after successful login
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Login successful!'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                            
                                            Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(builder: (_) => const CycleInputPage()),
                                            );
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
                                    : const Text('Sign In'),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Or divider
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
                              
                              const SizedBox(height: 24),
                              
                              // Social Login Buttons
                              OutlinedButton.icon(
                                onPressed: _state.isLoading
                                    ? null
                                    : () => _state.signInWithGoogle(context),
                                icon: const Icon(Icons.g_mobiledata, size: 24),
                                label: const Text('Continue with Google'),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              OutlinedButton.icon(
                                onPressed: _state.isLoading
                                    ? null
                                    : () => _state.signInWithApple(context),
                                icon: const Icon(Icons.apple, size: 24),
                                label: const Text('Continue with Apple'),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Sign Up
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Don't have an account?"),
                                  TextButton(
                                    onPressed: _state.isLoading ? null : () {
                                      // TODO: Navigate to sign up page
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Sign up functionality not implemented yet'),
                                        ),
                                      );
                                    },
                                    child: const Text('Sign Up'),
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
