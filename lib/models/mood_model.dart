import 'package:Finspense/models/mood_details_model.dart';

class MoodModel {
  String? email;
  List<MoodDetailsModel>? moodDetails;

  MoodModel({this.email, this.moodDetails});

  // Receive data from database
  factory MoodModel.fromMap(map) {
    List<MoodDetailsModel> moodDetails = map['moodDetails']
        .map((data) => MoodDetailsModel.fromMap(data))
        .toList();
    return MoodModel(
      email: map['email'],
      moodDetails: moodDetails.cast<MoodDetailsModel>(),
    );
  }

  // Send data to database
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'moodDetails': moodDetails!.map((data) => data.toMap()).toList(),
    };
  }
}
