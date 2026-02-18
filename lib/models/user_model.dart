// usermodel.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Currency {
  final String code;
  final String symbol;

  Currency({required this.code, required this.symbol});

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      code: json['code'] as String? ?? 'KES',
      symbol: json['symbol'] as String? ?? 'KES',
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
      country: json['country'] as String? ?? '',
      city: json['city'] as String? ?? '',
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
  final String? displayName;
  final String? email;
  final String? photoURL;
  final List<String> goals;
  final Currency? currency;
  final String? incomeRange;
  final String? ageRange;
  final String? occupation;
  final Location? location;
  final String? riskTolerance;
  final double? monthlyBudget;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    this.displayName,
    this.email,
    this.photoURL,
    this.goals = const [],
    this.currency,
    this.incomeRange,
    this.ageRange,
    this.occupation,
    this.location,
    this.riskTolerance,
    this.monthlyBudget,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {required String uid}) {
    return UserModel(
      uid: uid,
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      photoURL: json['photoURL'] as String?,
      goals: List<String>.from(json['goals'] ?? []),
      currency:
          json['currency'] != null ? Currency.fromJson(json['currency']) : null,
      incomeRange: json['incomeRange'] as String?,
      ageRange: json['ageRange'] as String?,
      occupation: json['occupation'] as String?,
      location:
          json['location'] != null ? Location.fromJson(json['location']) : null,
      riskTolerance: json['riskTolerance'] as String?,
      monthlyBudget: (json['monthlyBudget'] as num?)?.toDouble(),
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is Timestamp
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.parse(json['createdAt'] as String))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
      'goals': goals,
      'currency': currency?.toJson(),
      'incomeRange': incomeRange,
      'ageRange': ageRange,
      'occupation': occupation,
      'location': location?.toJson(),
      'riskTolerance': riskTolerance,
      'monthlyBudget': monthlyBudget,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson(data, uid: doc.id);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
      'goals': goals,
      'currency': currency?.toJson(),
      'incomeRange': incomeRange,
      'ageRange': ageRange,
      'occupation': occupation,
      'location': location?.toJson(),
      'riskTolerance': riskTolerance,
      'monthlyBudget': monthlyBudget,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoURL,
    List<String>? goals,
    Currency? currency,
    String? incomeRange,
    String? ageRange,
    String? occupation,
    Location? location,
    String? riskTolerance,
    double? monthlyBudget,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      goals: goals ?? this.goals,
      currency: currency ?? this.currency,
      incomeRange: incomeRange ?? this.incomeRange,
      ageRange: ageRange ?? this.ageRange,
      occupation: occupation ?? this.occupation,
      location: location ?? this.location,
      riskTolerance: riskTolerance ?? this.riskTolerance,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
