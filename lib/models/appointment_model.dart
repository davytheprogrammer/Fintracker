import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  String? therapist_email;
  Timestamp? date;
  String? mode;
  String? booked_by;

  AppointmentModel({
    this.therapist_email,
    this.date,
    this.mode,
    this.booked_by,
  });

  // Receive data from database
  factory AppointmentModel.fromMap(map) {
    return AppointmentModel(
      therapist_email: map['therapist_email'],
      date: map['date'],
      mode: map['mode'],
      booked_by: map['booked_by'],
    );
  }

  // Send data to database
  Map<String, dynamic> toMap() {
    return {
      'therapist_email': therapist_email,
      'date': date,
      'mode': mode,
      'booked_by': booked_by,
    };
  }
}
