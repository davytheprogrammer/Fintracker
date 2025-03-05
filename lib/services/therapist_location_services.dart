import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Finspense/models/therapist_location_model.dart';

class TherapistLocationService {
  Future<List<TherapistLocationModel>> getAllTherapistLocations() async {
    List<TherapistLocationModel> therapistLocationList = [];

    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection('therapist_locations')
    .orderBy("therapist_email")
    .get().then((query) {
      for (var doc in query.docs) {
        therapistLocationList.add(TherapistLocationModel.fromMap(doc.data()));
      }
    });

    return therapistLocationList;
  }

  Future<TherapistLocationModel> getLocationByTherapistEmail(String therapistEmail) async {
    List<TherapistLocationModel> therapistLocationList = [];

    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection('therapist_locations')
    .where("therapist_email", isEqualTo: therapistEmail)
    .get().then((query) {
      for (var doc in query.docs) {
        therapistLocationList.add(TherapistLocationModel.fromMap(doc.data()));
      }
    });

    return therapistLocationList[0];
  }
}