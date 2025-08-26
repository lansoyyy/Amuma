import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:amuma/models/data_models.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Base user document reference
  DocumentReference? get _userDocRef {
    final userId = currentUserId;
    return userId != null ? _firestore.collection('users').doc(userId) : null;
  }

  // ==================== MEDICATION MANAGEMENT ====================

  // Add medication
  Future<bool> addMedication(MedicationModel medication) async {
    try {
      final userDoc = _userDocRef;
      if (userDoc == null) return false;

      await userDoc
          .collection('medications')
          .doc(medication.id)
          .set(medication.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get all medications for user
  Stream<List<MedicationModel>> getMedications() {
    final userDoc = _userDocRef;
    if (userDoc == null) return Stream.value([]);

    return userDoc
        .collection('medications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(
                (doc) => MedicationModel.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Update medication completion status
  Future<bool> updateMedicationCompletion(
      String medicationId, List<bool> isCompleted) async {
    try {
      final userDoc = _userDocRef;
      if (userDoc == null) return false;

      await userDoc.collection('medications').doc(medicationId).update({
        'isCompleted': isCompleted.map((e) => e).toList(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete medication
  Future<bool> deleteMedication(String medicationId) async {
    try {
      final userDoc = _userDocRef;
      if (userDoc == null) return false;

      await userDoc.collection('medications').doc(medicationId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get medication adherence stats
  Future<Map<String, dynamic>> getMedicationStats() async {
    try {
      final userDoc = _userDocRef;
      if (userDoc == null) return {};

      final snapshot = await userDoc.collection('medications').get();
      int totalDoses = 0;
      int completedDoses = 0;

      for (var doc in snapshot.docs) {
        final med = MedicationModel.fromMap({...doc.data(), 'id': doc.id});
        totalDoses += med.times.length;
        completedDoses +=
            med.isCompleted.where((completed) => completed).length;
      }

      return {
        'totalDoses': totalDoses,
        'completedDoses': completedDoses,
        'adherenceRate':
            totalDoses > 0 ? (completedDoses / totalDoses * 100).round() : 0,
      };
    } catch (e) {
      return {};
    }
  }

  // ==================== HEALTH DIARY ====================

  // Add health entry
  Future<bool> addHealthEntry(HealthEntryModel entry) async {
    try {
      final userDoc = _userDocRef;
      if (userDoc == null) return false;

      await userDoc
          .collection('healthEntries')
          .doc(entry.id)
          .set(entry.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get health entries
  Stream<List<HealthEntryModel>> getHealthEntries({int limit = 30}) {
    final userDoc = _userDocRef;
    if (userDoc == null) return Stream.value([]);

    return userDoc
        .collection('healthEntries')
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                HealthEntryModel.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Get health entry by date
  Future<HealthEntryModel?> getHealthEntryByDate(DateTime date) async {
    try {
      final userDoc = _userDocRef;
      if (userDoc == null) return null;

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final snapshot = await userDoc
          .collection('healthEntries')
          .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('date', isLessThanOrEqualTo: endOfDay.toIso8601String())
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return HealthEntryModel.fromMap(
            {...snapshot.docs.first.data(), 'id': snapshot.docs.first.id});
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update health entry
  Future<bool> updateHealthEntry(String entryId, HealthEntryModel entry) async {
    try {
      final userDoc = _userDocRef;
      if (userDoc == null) return false;

      await userDoc
          .collection('healthEntries')
          .doc(entryId)
          .update(entry.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete health entry
  Future<bool> deleteHealthEntry(String entryId) async {
    try {
      final userDoc = _userDocRef;
      if (userDoc == null) return false;

      await userDoc.collection('healthEntries').doc(entryId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get health trends
  Future<Map<String, List<double>>> getHealthTrends({int days = 30}) async {
    try {
      final userDoc = _userDocRef;
      if (userDoc == null) return {};

      final startDate = DateTime.now().subtract(Duration(days: days));
      final snapshot = await userDoc
          .collection('healthEntries')
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .orderBy('date')
          .get();

      List<double> systolicBP = [];
      List<double> diastolicBP = [];
      List<double> bloodSugar = [];
      List<double> weight = [];

      for (var doc in snapshot.docs) {
        final entry = HealthEntryModel.fromMap({...doc.data(), 'id': doc.id});
        if (entry.bloodPressureSystolic != null)
          systolicBP.add(entry.bloodPressureSystolic!.toDouble());
        if (entry.bloodPressureDiastolic != null)
          diastolicBP.add(entry.bloodPressureDiastolic!.toDouble());
        if (entry.bloodSugar != null)
          bloodSugar.add(entry.bloodSugar!.toDouble());
        if (entry.weight != null) weight.add(entry.weight!);
      }

      return {
        'systolicBP': systolicBP,
        'diastolicBP': diastolicBP,
        'bloodSugar': bloodSugar,
        'weight': weight,
      };
    } catch (e) {
      return {};
    }
  }

  // ==================== APPOINTMENTS ====================

  // Add appointment
  Future<bool> addAppointment(AppointmentModel appointment) async {
    try {
      final userDoc = _userDocRef;
      if (userDoc == null) return false;

      await userDoc
          .collection('appointments')
          .doc(appointment.id)
          .set(appointment.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get appointments
  Stream<List<AppointmentModel>> getAppointments() {
    final userDoc = _userDocRef;
    if (userDoc == null) return Stream.value([]);

    return userDoc.collection('appointments').orderBy('date').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) =>
                AppointmentModel.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Get appointments by date
  Future<List<AppointmentModel>> getAppointmentsByDate(DateTime date) async {
    try {
      final userDoc = _userDocRef;
      if (userDoc == null) return [];

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final snapshot = await userDoc
          .collection('appointments')
          .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('date', isLessThanOrEqualTo: endOfDay.toIso8601String())
          .get();

      return snapshot.docs
          .map((doc) => AppointmentModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Update appointment
  Future<bool> updateAppointment(
      String appointmentId, AppointmentModel appointment) async {
    try {
      final userDoc = _userDocRef;
      if (userDoc == null) return false;

      await userDoc
          .collection('appointments')
          .doc(appointmentId)
          .update(appointment.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Mark appointment as completed
  Future<bool> markAppointmentCompleted(String appointmentId) async {
    try {
      final userDoc = _userDocRef;
      if (userDoc == null) return false;

      await userDoc.collection('appointments').doc(appointmentId).update({
        'isCompleted': true,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete appointment
  Future<bool> deleteAppointment(String appointmentId) async {
    try {
      final userDoc = _userDocRef;
      if (userDoc == null) return false;

      await userDoc.collection('appointments').doc(appointmentId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== GAMIFICATION ====================

  // Add or update badge
  Future<bool> saveBadge(BadgeModel badge) async {
    try {
      final userDoc = _userDocRef;
      if (userDoc == null) return false;

      await userDoc
          .collection('badges')
          .doc(badge.id)
          .set(badge.toMap(), SetOptions(merge: true));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get all badges
  Stream<List<BadgeModel>> getBadges() {
    final userDoc = _userDocRef;
    if (userDoc == null) return Stream.value([]);

    return userDoc.collection('badges').snapshots().map((snapshot) => snapshot
        .docs
        .map((doc) => BadgeModel.fromMap({...doc.data(), 'id': doc.id}))
        .toList());
  }

  // Award badge
  Future<bool> awardBadge(String badgeId) async {
    try {
      final userDoc = _userDocRef;
      if (userDoc == null) return false;

      await userDoc.collection('badges').doc(badgeId).update({
        'dateEarned': DateTime.now().toIso8601String(),
        'progress': FieldValue.increment(1),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get all streaks
  Stream<List<StreakModel>> getStreaks() {
    final userDoc = _userDocRef;
    if (userDoc == null) return Stream.value([]);

    return userDoc.collection('streaks').snapshots().map((snapshot) => snapshot
        .docs
        .map((doc) => StreakModel.fromMap({...doc.data(), 'id': doc.id}))
        .toList());
  }

  // Add or update streak
  Future<bool> saveStreak(StreakModel streak) async {
    try {
      final userDoc = _userDocRef;
      if (userDoc == null) return false;

      await userDoc
          .collection('streaks')
          .doc(streak.id)
          .set(streak.toMap(), SetOptions(merge: true));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get streak by type
  Future<StreakModel?> getStreakByType(String type) async {
    try {
      final userDoc = _userDocRef;
      if (userDoc == null) return null;

      final snapshot = await userDoc
          .collection('streaks')
          .where('type', isEqualTo: type)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return StreakModel.fromMap(
            {...snapshot.docs.first.data(), 'id': snapshot.docs.first.id});
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update streak count
  Future<bool> updateStreak(String streakId, int newCount) async {
    try {
      final userDoc = _userDocRef;
      if (userDoc == null) return false;

      await userDoc.collection('streaks').doc(streakId).update({
        'count': newCount,
        'lastUpdate': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get user stats for gamification
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final userDoc = _userDocRef;
      if (userDoc == null) return {};

      // Get streaks
      final streaksSnapshot = await userDoc.collection('streaks').get();
      int totalStreak = 0;
      for (var doc in streaksSnapshot.docs) {
        final streak = StreakModel.fromMap({...doc.data(), 'id': doc.id});
        totalStreak += streak.count;
      }

      // Get earned badges
      final badgesSnapshot = await userDoc
          .collection('badges')
          .where('dateEarned', isNotEqualTo: null)
          .get();
      int earnedBadges = badgesSnapshot.docs.length;

      // Calculate health score (example calculation)
      final medicationStats = await getMedicationStats();
      int healthScore =
          (medicationStats['adherenceRate'] ?? 0) + (totalStreak * 2);
      if (healthScore > 100) healthScore = 100;

      return {
        'healthScore': healthScore,
        'totalStreak': totalStreak,
        'earnedBadges': earnedBadges,
        'medicationAdherence': medicationStats['adherenceRate'] ?? 0,
      };
    } catch (e) {
      return {};
    }
  }

  // ==================== EDUCATION ====================

  // Add educational content
  Future<bool> addEducationalContent(Map<String, dynamic> content) async {
    try {
      final docRef = _firestore.collection('education').doc();
      await docRef.set({
        ...content,
        'id': docRef.id,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get educational content by category
  Stream<List<Map<String, dynamic>>> getEducationalContent({String? category}) {
    Query query = _firestore
        .collection('education')
        .orderBy('priority', descending: true)
        .orderBy('createdAt', descending: true);

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
        .toList());
  }

  // Get educational content using EducationContentModel
  Stream<List<EducationContentModel>> getEducationContent({String? category}) {
    Query query = _firestore
        .collection('education')
        .orderBy('priority', descending: true)
        .orderBy('createdAt', descending: true);

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => EducationContentModel.fromMap(
            {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
        .toList());
  }

  // Add educational content using model
  Future<bool> addEducationContent(EducationContentModel content) async {
    try {
      await _firestore
          .collection('education')
          .doc(content.id)
          .set(content.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get health tip of the day
  Future<Map<String, dynamic>?> getHealthTipOfTheDay() async {
    try {
      final snapshot = await _firestore
          .collection('education')
          .where('type', isEqualTo: 'tip')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return {...snapshot.docs.first.data(), 'id': snapshot.docs.first.id};
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Track content engagement
  Future<bool> trackContentEngagement(String contentId, String action) async {
    try {
      final userDoc = _userDocRef;
      if (userDoc == null) return false;

      await userDoc.collection('engagement').add({
        'contentId': contentId,
        'action': action, // 'view', 'like', 'share', etc.
        'timestamp': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== EMERGENCY PROFILE ====================

  // Save user profile
  Future<bool> saveUserProfile(UserProfileModel profile) async {
    try {
      final userDoc = _userDocRef;
      if (userDoc == null) return false;

      await userDoc.set({
        'profile': profile.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get user profile
  Future<UserProfileModel?> getUserProfile() async {
    try {
      final userDoc = _userDocRef;
      if (userDoc == null) return null;

      final snapshot = await userDoc.get();
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;
        if (data['profile'] != null) {
          return UserProfileModel.fromMap(data['profile']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Add emergency contact
  Future<bool> addEmergencyContact(EmergencyContactModel contact) async {
    try {
      final userDoc = _userDocRef;
      if (userDoc == null) return false;

      await userDoc
          .collection('emergencyContacts')
          .doc(contact.id)
          .set(contact.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get emergency contacts
  Stream<List<EmergencyContactModel>> getEmergencyContacts() {
    final userDoc = _userDocRef;
    if (userDoc == null) return Stream.value([]);

    return userDoc
        .collection('emergencyContacts')
        .orderBy('isPrimary', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                EmergencyContactModel.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Update emergency contact
  Future<bool> updateEmergencyContact(
      String contactId, EmergencyContactModel contact) async {
    try {
      final userDoc = _userDocRef;
      if (userDoc == null) return false;

      await userDoc
          .collection('emergencyContacts')
          .doc(contactId)
          .update(contact.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete emergency contact
  Future<bool> deleteEmergencyContact(String contactId) async {
    try {
      final userDoc = _userDocRef;
      if (userDoc == null) return false;

      await userDoc.collection('emergencyContacts').doc(contactId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== ACTIVITY TRACKING ====================

  // Log user activity
  Future<bool> logActivity(String type, String description,
      {Map<String, dynamic>? data}) async {
    try {
      final userDoc = _userDocRef;
      if (userDoc == null) return false;

      await userDoc.collection('activities').add({
        'type': type,
        'description': description,
        'data': data,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get recent activities
  Stream<List<Map<String, dynamic>>> getRecentActivities({int limit = 10}) {
    final userDoc = _userDocRef;
    if (userDoc == null) return Stream.value([]);

    return userDoc
        .collection('activities')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  // ==================== DASHBOARD DATA ====================

  // Get comprehensive dashboard data
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final medicationStats = await getMedicationStats();
      final userStats = await getUserStats();

      return {
        'medicationStats': medicationStats,
        'userStats': userStats,
        'greeting': _getGreeting(),
      };
    } catch (e) {
      return {};
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning!';
    if (hour < 17) return 'Good afternoon!';
    return 'Good evening!';
  }
}
