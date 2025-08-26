import 'dart:convert';

// Medication Model
class MedicationModel {
  final String id;
  final String name;
  final String dosage;
  final List<String> times;
  final List<bool> isCompleted;
  final DateTime createdAt;

  MedicationModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.times,
    required this.isCompleted,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'times': jsonEncode(times),
      'isCompleted': jsonEncode(isCompleted),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MedicationModel.fromMap(Map<String, dynamic> map) {
    return MedicationModel(
      id: map['id'],
      name: map['name'],
      dosage: map['dosage'],
      times: List<String>.from(jsonDecode(map['times'])),
      isCompleted: List<bool>.from(jsonDecode(map['isCompleted'])),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

// Health Entry Model
class HealthEntryModel {
  final String id;
  final DateTime date;
  final int? bloodPressureSystolic;
  final int? bloodPressureDiastolic;
  final int? bloodSugar;
  final double? weight;
  final String? notes;
  final DateTime createdAt;

  HealthEntryModel({
    required this.id,
    required this.date,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.bloodSugar,
    this.weight,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'bloodPressureSystolic': bloodPressureSystolic,
      'bloodPressureDiastolic': bloodPressureDiastolic,
      'bloodSugar': bloodSugar,
      'weight': weight,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory HealthEntryModel.fromMap(Map<String, dynamic> map) {
    return HealthEntryModel(
      id: map['id'],
      date: DateTime.parse(map['date']),
      bloodPressureSystolic: map['bloodPressureSystolic'],
      bloodPressureDiastolic: map['bloodPressureDiastolic'],
      bloodSugar: map['bloodSugar'],
      weight: map['weight']?.toDouble(),
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

// Appointment Model
class AppointmentModel {
  final String id;
  final String title;
  final DateTime date;
  final String time;
  final String location;
  final String type;
  final String? notes;
  final bool isCompleted;
  final DateTime createdAt;

  AppointmentModel({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.type,
    this.notes,
    required this.isCompleted,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'time': time,
      'location': location,
      'type': type,
      'notes': notes,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      time: map['time'],
      location: map['location'],
      type: map['type'],
      notes: map['notes'],
      isCompleted: map['isCompleted'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

// Badge Model
class BadgeModel {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String color;
  final DateTime? dateEarned;
  final int progress;
  final int target;

  BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.dateEarned,
    this.progress = 0,
    this.target = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'dateEarned': dateEarned?.toIso8601String(),
      'progress': progress,
      'target': target,
    };
  }

  factory BadgeModel.fromMap(Map<String, dynamic> map) {
    return BadgeModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      icon: map['icon'],
      color: map['color'],
      dateEarned:
          map['dateEarned'] != null ? DateTime.parse(map['dateEarned']) : null,
      progress: map['progress'] ?? 0,
      target: map['target'] ?? 1,
    );
  }
}

// Streak Model
class StreakModel {
  final String id;
  final String type;
  final int count;
  final DateTime lastUpdate;

  StreakModel({
    required this.id,
    required this.type,
    required this.count,
    required this.lastUpdate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'count': count,
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }

  factory StreakModel.fromMap(Map<String, dynamic> map) {
    return StreakModel(
      id: map['id'],
      type: map['type'],
      count: map['count'],
      lastUpdate: DateTime.parse(map['lastUpdate']),
    );
  }
}

// User Profile Model
class UserProfileModel {
  final String? name;
  final String? dateOfBirth;
  final String? gender;
  final String? bloodType;
  final List<String>? chronicConditions;
  final List<String>? allergies;
  final String? preferredLanguage;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfileModel({
    this.name,
    this.dateOfBirth,
    this.gender,
    this.bloodType,
    this.chronicConditions,
    this.allergies,
    this.preferredLanguage,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'bloodType': bloodType,
      'chronicConditions':
          chronicConditions != null ? jsonEncode(chronicConditions) : null,
      'allergies': allergies != null ? jsonEncode(allergies) : null,
      'preferredLanguage': preferredLanguage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      name: map['name'],
      dateOfBirth: map['dateOfBirth'],
      gender: map['gender'],
      bloodType: map['bloodType'],
      chronicConditions: map['chronicConditions'] != null
          ? List<String>.from(jsonDecode(map['chronicConditions']))
          : null,
      allergies: map['allergies'] != null
          ? List<String>.from(jsonDecode(map['allergies']))
          : null,
      preferredLanguage: map['preferredLanguage'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  UserProfileModel copyWith({
    String? name,
    String? dateOfBirth,
    String? gender,
    String? bloodType,
    List<String>? chronicConditions,
    List<String>? allergies,
    String? preferredLanguage,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodType: bloodType ?? this.bloodType,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      allergies: allergies ?? this.allergies,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

// Emergency Contact Model
class EmergencyContactModel {
  final String id;
  final String name;
  final String relationship;
  final String phone;
  final String? email;
  final bool isPrimary;

  EmergencyContactModel({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phone,
    this.email,
    this.isPrimary = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'relationship': relationship,
      'phone': phone,
      'email': email,
      'isPrimary': isPrimary,
    };
  }

  factory EmergencyContactModel.fromMap(Map<String, dynamic> map) {
    return EmergencyContactModel(
      id: map['id'],
      name: map['name'],
      relationship: map['relationship'],
      phone: map['phone'],
      email: map['email'],
      isPrimary: map['isPrimary'] ?? false,
    );
  }
}

// Education Content Model
class EducationContentModel {
  final String id;
  final String category;
  final String titleEn;
  final String titleCeb;
  final String contentEn;
  final String contentCeb;
  final String icon;
  final String color;
  final List<String>? tipsEn;
  final List<String>? tipsCeb;
  final int priority;
  final DateTime createdAt;

  EducationContentModel({
    required this.id,
    required this.category,
    required this.titleEn,
    required this.titleCeb,
    required this.contentEn,
    required this.contentCeb,
    required this.icon,
    required this.color,
    this.tipsEn,
    this.tipsCeb,
    this.priority = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'titleEn': titleEn,
      'titleCeb': titleCeb,
      'contentEn': contentEn,
      'contentCeb': contentCeb,
      'icon': icon,
      'color': color,
      'tipsEn': tipsEn != null ? jsonEncode(tipsEn) : null,
      'tipsCeb': tipsCeb != null ? jsonEncode(tipsCeb) : null,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory EducationContentModel.fromMap(Map<String, dynamic> map) {
    return EducationContentModel(
      id: map['id'],
      category: map['category'],
      titleEn: map['titleEn'],
      titleCeb: map['titleCeb'],
      contentEn: map['contentEn'],
      contentCeb: map['contentCeb'],
      icon: map['icon'],
      color: map['color'],
      tipsEn: map['tipsEn'] != null
          ? List<String>.from(jsonDecode(map['tipsEn']))
          : null,
      tipsCeb: map['tipsCeb'] != null
          ? List<String>.from(jsonDecode(map['tipsCeb']))
          : null,
      priority: map['priority'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
