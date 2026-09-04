class AppConstants {
  AppConstants._(); 

  static const String userBox = 'user_box';
  static const String fastingBox = 'fasting_box';
  static const String mealsBox = 'meals_box';
  static const String bloodGlucoseBox = 'blood_glucose_box';
  static const String insulinBox = 'insulin_box';
  static const String remindersBox = 'reminders_box';

  static const String activeSessionKey = 'active_session';
  static const String currentUserKey = 'current_user';

  static const List<Map<String, dynamic>> defaultProtocols = [
    {
      'name': '12:12',
      'fastingHours': 12,
      'eatingHours': 12,
      'description': 'Iniciante - Ideal para adaptação e rotinas diárias normais',
    },
    {
      'name': '16:8',
      'fastingHours': 16,
      'eatingHours': 8,
      'description': 'Intermediário - O protocolo mais popular e sustentável',
    },
    {
      'name': '18:6',
      'fastingHours': 18,
      'eatingHours': 6,
      'description': 'Avançado - Maior foco em cetose e autofagia',
    },
  ];
}