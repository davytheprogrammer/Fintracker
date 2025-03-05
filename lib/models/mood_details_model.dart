import 'package:cloud_firestore/cloud_firestore.dart';

class MoodDetailsModel {
  Timestamp? date;
  String? emoji;
  String? description;

  MoodDetailsModel({this.date, this.emoji, this.description});

  // Receive data from database
  factory MoodDetailsModel.fromMap(map) {
    return MoodDetailsModel(
      date: map['date'],
      emoji: map['emoji'],
      description: map['description'],
    );
  }

  // Send data to database
  Map<String,dynamic> toMap() {
    return {
      'date': date,
      'emoji': emoji,
      'description': description,
    };
  }
}