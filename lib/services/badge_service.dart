import 'package:amuma/models/data_models.dart';
import 'package:amuma/services/firebase_service.dart';
import 'package:uuid/uuid.dart';

class BadgeService {
  static final BadgeService _instance = BadgeService._internal();
  factory BadgeService() => _instance;
  BadgeService._internal();

  final FirebaseService _firebaseService = FirebaseService();
  final Uuid _uuid = Uuid();

  Future<void> initializeDefaultBadges() async {
    try {
      // Get existing badges
      final existingBadges = await _firebaseService.getBadges().first;

      // Check if check-in badges already exist
      final hasCheckInBadges = existingBadges.any((badge) =>
          badge.name.toLowerCase().contains('check-in') ||
          badge.name.toLowerCase().contains('attendance'));

      // If no check-in badges exist, create default ones
      if (!hasCheckInBadges) {
        await _createCheckInBadges();
      }
    } catch (e) {
      // Handle error silently or log it
      print('Error initializing badges: $e');
    }
  }

  Future<void> _createCheckInBadges() async {
    final checkInBadges = [
      BadgeModel(
        id: _uuid.v4(),
        name: 'First Check-in',
        description: 'Complete your first daily check-in',
        icon: 'emoji_events',
        color: 'green',
        target: 1,
      ),
      BadgeModel(
        id: _uuid.v4(),
        name: 'Week Warrior',
        description: 'Check in for 7 consecutive days',
        icon: 'local_fire_department',
        color: 'orange',
        target: 7,
      ),
      BadgeModel(
        id: _uuid.v4(),
        name: 'Monthly Champion',
        description: 'Check in for 30 consecutive days',
        icon: 'military_tech',
        color: 'purple',
        target: 30,
      ),
      BadgeModel(
        id: _uuid.v4(),
        name: 'Consistency King',
        description: 'Check in for 100 consecutive days',
        icon: 'star',
        color: 'amber',
        target: 100,
      ),
      BadgeModel(
        id: _uuid.v4(),
        name: 'Health Legend',
        description: 'Check in for 365 consecutive days',
        icon: 'health_and_safety',
        color: 'blue',
        target: 365,
      ),
    ];

    // Save all check-in badges
    for (final badge in checkInBadges) {
      await _firebaseService.saveBadge(badge);
    }
  }
}
