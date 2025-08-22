class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    // Simple RFC-style email validation
    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    final hasNumber = RegExp(r'[0-9]').hasMatch(value);
    if (!hasNumber) {
      return 'Password must contain at least one number';
    }
    
    return null;
  }
}