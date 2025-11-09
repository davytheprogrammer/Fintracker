import 'package:flutter/material.dart';
import 'package:Finspense/models/user_model.dart';

class OnboardingProvider with ChangeNotifier {
  Currency? _selectedCurrency;
  List<String> _selectedGoals = [];
  String? _incomeRange;
  String? _ageRange;
  String? _occupation;
  Location? _location;
  String? _riskTolerance;

  // Getters
  Currency? get selectedCurrency => _selectedCurrency;
  List<String> get selectedGoals => _selectedGoals;
  String? get incomeRange => _incomeRange;
  String? get ageRange => _ageRange;
  String? get occupation => _occupation;
  Location? get location => _location;
  String? get riskTolerance => _riskTolerance;

  // Setters
  void setCurrency(Currency currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }

  void setGoals(List<String> goals) {
    _selectedGoals = goals;
    notifyListeners();
  }

  void setIncomeRange(String range) {
    _incomeRange = range;
    notifyListeners();
  }

  void setAgeRange(String range) {
    _ageRange = range;
    notifyListeners();
  }

  void setOccupation(String occupation) {
    _occupation = occupation;
    notifyListeners();
  }

  void setLocation(Location location) {
    _location = location;
    notifyListeners();
  }

  void setRiskTolerance(String tolerance) {
    _riskTolerance = tolerance;
    notifyListeners();
  }

  // Validation
  bool get isCurrencyValid => _selectedCurrency != null;
  bool get isGoalsValid => _selectedGoals.isNotEmpty;
  bool get isIncomeValid => _incomeRange != null && _incomeRange!.isNotEmpty;
  bool get isProfileValid =>
      _ageRange != null &&
      _ageRange!.isNotEmpty &&
      _occupation != null &&
      _occupation!.isNotEmpty &&
      _location != null &&
      _riskTolerance != null &&
      _riskTolerance!.isNotEmpty;

  bool get isComplete =>
      isCurrencyValid && isGoalsValid && isIncomeValid && isProfileValid;

  // Reset
  void reset() {
    _selectedCurrency = null;
    _selectedGoals = [];
    _incomeRange = null;
    _ageRange = null;
    _occupation = null;
    _location = null;
    _riskTolerance = null;
    notifyListeners();
  }
}
