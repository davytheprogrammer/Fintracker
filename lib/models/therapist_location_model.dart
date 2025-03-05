class TherapistLocationModel {
  double? latitude;
  String? location;
  double? longitude;
  String? therapist_email;

  TherapistLocationModel({this.latitude, this.location, this.longitude, this.therapist_email});

  // Receive data from database
  factory TherapistLocationModel.fromMap(map) {
    return TherapistLocationModel(
      latitude: map['latitude'],
      location: map['location'],
      longitude: map['longitude'],
      therapist_email: map['therapist_email'],
    );
  }

  // Send data to database
  Map<String,dynamic> toMap() {
    return {
      'latitude': latitude,
      'location': location,
      'longitude': longitude,
      'therapist_email': therapist_email,
    };
  }
}