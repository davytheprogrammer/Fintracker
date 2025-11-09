import '../repositories/user_repository.dart';
import '../models/user_model.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  final UserRepository _userRepository = UserRepository();

  Future updateUserData(String? displayName, String? email, String type) async {
    if (uid == null) return;

    // Create or update user profile using UserRepository with direct Firestore queries
    final userModel = UserModel(
      uid: uid!,
      goals: [],
      currency: Currency(code: 'KES', symbol: 'KES'),
      incomeRange: 'Not specified',
      ageRange: 'Not specified',
      occupation: displayName ?? 'Not specified',
      location: Location(country: 'Kenya', city: 'Nairobi'),
      riskTolerance: 'Moderate',
    );

    await _userRepository.createOrUpdateUser(userModel);
  }

  // Stream user data from Firestore
  Stream<UserModel?> get users {
    if (uid == null) {
      return Stream.value(null);
    }
    return _userRepository.streamUserData(uid!);
  }
}
