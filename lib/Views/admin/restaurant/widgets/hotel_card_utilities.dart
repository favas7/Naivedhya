class RestaurantCardUtils {
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  static String formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phone);
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String getStatusText(int managerCount, int locationCount, int menuItemCount) {
    if (managerCount > 0 && locationCount > 0 && menuItemCount > 0) {
      return 'Complete Setup';
    } else if (managerCount > 0 && locationCount > 0) {
      return 'Basic Setup Complete';
    } else if (managerCount > 0 || locationCount > 0) {
      return 'Partial Setup';
    } else {
      return 'Setup Required';
    }
  }
}