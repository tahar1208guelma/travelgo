class AppValidators {
  AppValidators._();

  static String? validateRequired(String? value, String errorMessage) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage;
    }
    return null;
  }

  static String? validateEmail(String? value, {String? requiredMsg, String? invalidMsg}) {
    if (value == null || value.trim().isEmpty) {
      return requiredMsg ?? 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return invalidMsg ?? 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value, {String? requiredMsg, String? minLengthMsg}) {
    if (value == null || value.isEmpty) {
      return requiredMsg ?? 'Password is required';
    }
    if (value.length < 6) {
      return minLengthMsg ?? 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String? originalPassword, {String? matchMsg}) {
    if (value != originalPassword) {
      return matchMsg ?? 'Passwords do not match';
    }
    return null;
  }

  static bool validateAirportsDifferent(String originCode, String destinationCode) {
    if (originCode.isEmpty || destinationCode.isEmpty) return false;
    return originCode.trim().toUpperCase() != destinationCode.trim().toUpperCase();
  }

  static bool validateDateRange(DateTime departureDate, DateTime? returnDate) {
    if (returnDate == null) return true;
    final depOnly = DateTime(departureDate.year, departureDate.month, departureDate.day);
    final retOnly = DateTime(returnDate.year, returnDate.month, returnDate.day);
    return retOnly.isAfter(depOnly) || retOnly.isAtSameMomentAs(depOnly);
  }

  static bool validatePassengerCount(int adults, int children, int infants) {
    final total = adults + children + infants;
    return total > 0 && adults >= 1; // At least 1 adult required for infant/child travel
  }
}
