// usermodel.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Currency {
  final String code;
  final String symbol;

  Currency({required this.code, required this.symbol});

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      code: json['code'] as String,
      symbol: json['symbol'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'symbol': symbol,
    };
  }
}

class Location {
  final String country;
  final String city;

  Location({required this.country, required this.city});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      country: json['country'] as String,
      city: json['city'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'city': city,
    };
  }
}

class UserModel {
  final String uid;
  final DateTime soberDate;
  final int streakDays;
  final List<DateTime> relapses;
  final List<String> goals;
  final List<String> supportNetwork;
  final List<String> emergencyContacts;
  final Currency? currency;
  final String? incomeRange;
  final String? ageRange;
  final String? occupation;
  final Location? location;
  final String? riskTolerance;

  UserModel({
    required this.uid,
    DateTime? soberDate,
    this.streakDays = 0,
    this.relapses = const [],
    this.goals = const [],
    this.supportNetwork = const [],
    this.emergencyContacts = const [],
    this.currency,
    this.incomeRange,
    this.ageRange,
    this.occupation,
    this.location,
    this.riskTolerance,
  }) : soberDate = soberDate ?? DateTime.now();

  factory UserModel.fromJson(Map<String, dynamic> json, {required String uid}) {
    return UserModel(
      uid: uid,
      soberDate: json['soberDate'] != null
          ? (json['soberDate'] is Timestamp
              ? (json['soberDate'] as Timestamp).toDate()
              : DateTime.parse(json['soberDate'] as String))
          : DateTime.now(),
      streakDays: json['streakDays'] ?? 0,
      relapses: (json['relapses'] as List<dynamic>?)
              ?.map((x) =>
                  (x is Timestamp ? x.toDate() : DateTime.parse(x as String)))
              .toList() ??
          [],
      goals: List<String>.from(json['goals'] ?? []),
      supportNetwork: List<String>.from(json['supportNetwork'] ?? []),
      emergencyContacts: List<String>.from(json['emergencyContacts'] ?? []),
      currency:
          json['currency'] != null ? Currency.fromJson(json['currency']) : null,
      incomeRange: json['incomeRange'] as String?,
      ageRange: json['ageRange'] as String?,
      occupation: json['occupation'] as String?,
      location:
          json['location'] != null ? Location.fromJson(json['location']) : null,
      riskTolerance: json['riskTolerance'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'soberDate': soberDate.toIso8601String(),
      'streakDays': streakDays,
      'relapses': relapses.map((date) => date.toIso8601String()).toList(),
      'goals': goals,
      'supportNetwork': supportNetwork,
      'emergencyContacts': emergencyContacts,
      'currency': currency?.toJson(),
      'incomeRange': incomeRange,
      'ageRange': ageRange,
      'occupation': occupation,
      'location': location?.toJson(),
      'riskTolerance': riskTolerance,
    };
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson(data, uid: doc.id);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'soberDate': Timestamp.fromDate(soberDate),
      'streakDays': streakDays,
      'relapses': relapses.map((date) => Timestamp.fromDate(date)).toList(),
      'goals': goals,
      'supportNetwork': supportNetwork,
      'emergencyContacts': emergencyContacts,
      'currency': currency?.toJson(),
      'incomeRange': incomeRange,
      'ageRange': ageRange,
      'occupation': occupation,
      'location': location?.toJson(),
      'riskTolerance': riskTolerance,
    };
  }

  UserModel copyWith({
    String? uid,
    DateTime? soberDate,
    int? streakDays,
    List<DateTime>? relapses,
    List<String>? goals,
    List<String>? supportNetwork,
    List<String>? emergencyContacts,
    Currency? currency,
    String? incomeRange,
    String? ageRange,
    String? occupation,
    Location? location,
    String? riskTolerance,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      soberDate: soberDate ?? this.soberDate,
      streakDays: streakDays ?? this.streakDays,
      relapses: relapses ?? this.relapses,
      goals: goals ?? this.goals,
      supportNetwork: supportNetwork ?? this.supportNetwork,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      currency: currency ?? this.currency,
      incomeRange: incomeRange ?? this.incomeRange,
      ageRange: ageRange ?? this.ageRange,
      occupation: occupation ?? this.occupation,
      location: location ?? this.location,
      riskTolerance: riskTolerance ?? this.riskTolerance,
    );
  }
}
