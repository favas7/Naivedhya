class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Phone validation
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter phone number';
    }
    if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  // Hotel name validation
  static String? validateHotelName(String? value) {
    return validateRequired(value, 'hotel name');
  }

  // Address validation
  static String? validateAddress(String? value) {
    return validateRequired(value, 'address');
  }

  // City validation
  static String? validateCity(String? value) {
    return validateRequired(value, 'city');
  }

  // State validation
  static String? validateState(String? value) {
    return validateRequired(value, 'state');
  }

  // Country validation
  static String? validateCountry(String? value) {
    return validateRequired(value, 'country');
  }

  // Postal code validation
  static String? validatePostalCode(String? value) {
    return validateRequired(value, 'postal code');
  }

  // Manager name validation
  static String? validateManagerName(String? value) {
    return validateRequired(value, 'manager name');
  }

  // Minimum length validation
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    if (value.trim().length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }
    return null;
  }

  // Maximum length validation
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.trim().length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }
    return null;
  }

  // Combined validation
  static String? validateWithLength(String? value, String fieldName, {int? minLength, int? maxLength}) {
    // Check if required
    final requiredResult = validateRequired(value, fieldName);
    if (requiredResult != null) return requiredResult;

    // Check minimum length
    if (minLength != null) {
      final minResult = validateMinLength(value, minLength, fieldName);
      if (minResult != null) return minResult;
    }

    // Check maximum length
    if (maxLength != null) {
      final maxResult = validateMaxLength(value, maxLength, fieldName);
      if (maxResult != null) return maxResult;
    }

    return null;
  }
}