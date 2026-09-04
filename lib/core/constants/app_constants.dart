class AppConstants {
  static const String userBox = 'user_box';
  static const String fastingBox = 'fasting_box';
  static const String mealsBox = 'meals_box';

  static const String activeSessionKey = 'active_session';
  static const String currentUserKey = 'current_user';

  static const List<Map<String, dynamic>> defaultProtocols = [
    {'name': '16:8', 'fastingHours': 16, 'eatingHours': 8},
    {'name': '18:6', 'fastingHours': 18, 'eatingHours': 6},
    {'name': '20:4', 'fastingHours': 20, 'eatingHours': 4},
  ];
}