import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Finspense/models/appointment_model.dart';

class AppointmentService {
  User? user = FirebaseAuth.instance.currentUser;

  // Function for patient to book an appointment
  Future bookAppointment(AppointmentModel appointment) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection('appointments').doc().set(appointment.toMap());
  }

  // Function for patient or therapist to retrieve their appointment list
  Future<List<AppointmentModel>> getAppointmentList(String? userType) async {
    List<AppointmentModel> appointmentList = [];
    FirebaseFirestore db = FirebaseFirestore.instance;

    if (userType == 'P') {
      await db.collection('appointments')
      .where("booked_by", isEqualTo: user!.email)
      .orderBy("date")
      .get().then((query) {
        for (var doc in query.docs) {
          appointmentList.add(AppointmentModel.fromMap(doc.data()));
        }
      });
    }
    else {  //userType == 'T'
      await db.collection('appointments')
      .where("therapist_email", isEqualTo: user!.email)
      .orderBy("date")
      .get().then((query) {
        for (var doc in query.docs) {
          appointmentList.add(AppointmentModel.fromMap(doc.data()));
        }
      });
    }

    return appointmentList;
  }

  // Function for patient or therapist to cancel an appointment
  Future cancelAppointment(AppointmentModel appointment) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    QuerySnapshot querySnap = await db.collection('appointments')
    .where('therapist_email', isEqualTo: appointment.therapist_email)
    .where('date', isEqualTo: appointment.date)
    .where('mode', isEqualTo: appointment.mode)
    .where('booked_by', isEqualTo: appointment.booked_by)
    .get();

    QueryDocumentSnapshot doc = querySnap.docs[0];  // Assumption: the query returns only one document
    DocumentReference docRef = doc.reference;
    await docRef.delete();
  }

  // Function to return available time slots for a specific date
  Future<List<int>> getAvailableTimeSlots(String therapist_email, DateTime selectedDate) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    List<AppointmentModel> appointmentList = [];
    List<int> availableTimeSlots = [0800, 1000, 1400, 1600];
    List<int> bookedTimeSlots = [];
    // print(selectedDate);

    await db.collection('appointments')
    .where("therapist_email", isEqualTo: therapist_email)
    // .where("date", isEqualTo: Timestamp.fromDate(selectedDate))
    .get().then((query) {
      for (var doc in query.docs) {
        appointmentList.add(AppointmentModel.fromMap(doc.data()));
      }
    });

    for (var data in appointmentList) {
      // If date from query matches the date selected by patient:
      if (data.date!.toDate().toLocal().toString().split(' ')[0] == selectedDate.toLocal().toString().split(' ')[0]) {
        String dateTime = data.date!.toDate().toLocal().toString(); // get date in 'yyyy-MM-dd hh:mm:ss.ms' format
        String timeOnly = dateTime.split(' ')[1]; // get time in 'hh:mm:ss.ms' format
        String hourMinOnly = timeOnly.split(':')[0] + timeOnly.split(':')[1];  // get just the hour and min in 'hhmm' (24H) format

        bookedTimeSlots.add(int.parse(hourMinOnly));
      }
    }

    for (var data in bookedTimeSlots) {
      availableTimeSlots.remove(data);
    }
    
    return availableTimeSlots;
  }
}