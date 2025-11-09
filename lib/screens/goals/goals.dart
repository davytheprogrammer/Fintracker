import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../services/user_services.dart';
import '../../providers/user_provider.dart';
import '../../repositories/goal_repository.dart';
import '../../models/goal_model.dart';

// Custom color scheme for the app - Pink theme for body, Blue for header
class AppColors {
  static const primaryBlue = Color(0xFF6C63FF); // Primary blue for header
  static const primaryPink = Color(0xFFFF80AB); // Light pink for body
  static const secondaryPink = Color(0xFFFCE4EC); // Very light pink
  static const accentPink = Color(0xFFF48FB1); // Medium pink
  static const backgroundPink = Color(0xFFFFF5F8); // Subtle pink background
  static const errorRed = Color(0xFFFF5252);
  static const successGreen = Color(0xFF4CAF50);

  // Gradient colors
  static const gradientStart = Color(0xFFFCE4EC); // Very light pink
  static const gradientEnd = Color(0xFFF8BBD0); // Slightly darker pink
}

class GoalsPage extends StatefulWidget {
  const GoalsPage({Key? key}) : super(key: key);

  @override
  _GoalsPageState createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();
  final GoalRepository _goalRepository = GoalRepository();
  final DateTime _currentDate = DateTime.now();

  // Provider
  late UserProvider _userProvider;

  List<GoalModel> _goals = [];
  final String _selectedCategory = 'Savings';
  late String _currencySymbol;

  final List<String> _categories = [
    'Savings',
    'Investment',
    'Debt Repayment',
    'Emergency Fund',
    'Education',
    'Travel',
    'Home',
    'Vehicle',
  ];

  @override
  void initState() {
    super.initState();
    _currencySymbol = 'KES'; // default
    _loadUserPreferences();

    // Initialize provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _userProvider = Provider.of<UserProvider>(context, listen: false);
    });
  }

  Future<void> _loadUserPreferences() async {
    try {
      final userModel = await _userService.getCurrentUserData();
      if (!mounted) return;
      setState(() {
        _currencySymbol = userModel.currency?.symbol ?? 'KES';
      });
    } catch (e) {
      print('Error loading user preferences: $e');
    }
  }

  Future<void> _addGoal(Map<String, dynamic> goalData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      final goal = GoalModel(
        uid: user.uid,
        name: goalData['title'],
        targetAmount: goalData['targetAmount'],
        deadline: goalData['deadline'],
        currentAmount: 0.0,
      );

      await _goalRepository.createGoal(goal, user.uid);
      // UI will update automatically via stream
    } catch (e) {
      print('Error adding goal: $e');
      rethrow;
    }
  }

  Future<void> _updateGoalProgress(String goalId, double amount) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      await _goalRepository.updateGoalProgress(goalId, user.uid, amount);
      // UI will update automatically via stream
    } catch (e) {
      print('Error updating goal: $e');
      rethrow;
    }
  }

  Future<void> _deleteGoal(String goalId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      await _goalRepository.deleteGoal(goalId, user.uid);
      // UI will update automatically via stream
    } catch (e) {
      print('Error deleting goal: $e');
      rethrow;
    }
  }

  void _showAddGoalDialog() {
    final formKey = GlobalKey<FormState>();
    String title = '';
    double targetAmount = 0;
    DateTime deadline = _currentDate.add(const Duration(days: 30));
    String category = _selectedCategory;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.secondaryPink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Create New Goal',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInputField(
                  label: 'Goal Title',
                  icon: Icons.title,
                  onSaved: (value) => title = value ?? '',
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  label: 'Target Amount ($_currencySymbol)',
                  icon: Icons.monetization_on,
                  keyboardType: TextInputType.number,
                  onSaved: (value) => targetAmount = double.parse(value ?? '0'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.primaryBlue.withOpacity(0.3)),
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: TextStyle(color: AppColors.primaryBlue),
                      prefixIcon:
                          Icon(Icons.category, color: AppColors.primaryBlue),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                    items: _categories.map((String category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      category = value ?? _selectedCategory;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildDatePicker(
                  deadline: deadline,
                  onPicked: (picked) {
                    if (picked != null) {
                      deadline = picked;
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('Cancel', style: TextStyle(color: AppColors.primaryBlue)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                try {
                  await _addGoal({
                    'title': title,
                    'targetAmount': targetAmount,
                    'deadline': deadline,
                    'category': category,
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Goal created successfully'),
                      backgroundColor: AppColors.successGreen,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to create goal: $e'),
                      backgroundColor: AppColors.errorRed,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Create Goal',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showUpdateProgressDialog(
    String goalId,
    double currentAmount,
    double targetAmount,
  ) {
    final formKey = GlobalKey<FormState>();
    double newAmount = currentAmount;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.secondaryPink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Update Progress',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Form(
          key: formKey,
          child: _buildInputField(
            label: 'Current Amount ($_currencySymbol)',
            icon: Icons.monetization_on,
            keyboardType: TextInputType.number,
            initialValue: currentAmount.toString(),
            onSaved: (value) => newAmount = double.parse(value ?? '0'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              final amount = double.tryParse(value);
              if (amount == null) {
                return 'Please enter a valid number';
              }
              if (amount > targetAmount) {
                return 'Amount cannot exceed target';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('Cancel', style: TextStyle(color: AppColors.primaryBlue)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                try {
                  await _updateGoalProgress(goalId, newAmount);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Progress updated successfully'),
                      backgroundColor: AppColors.successGreen,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update progress: $e'),
                      backgroundColor: AppColors.errorRed,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required Function(String?) onSaved,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    String? initialValue,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
      ),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.primaryBlue),
          prefixIcon: Icon(icon, color: AppColors.primaryBlue),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        keyboardType: keyboardType,
        validator: validator,
        onSaved: onSaved,
        style: TextStyle(color: AppColors.primaryBlue),
      ),
    );
  }

  Widget _buildDatePicker({
    required DateTime deadline,
    required Function(DateTime?) onPicked,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: Icon(Icons.calendar_today, color: AppColors.primaryBlue),
        title: Text(
          'Deadline',
          style: TextStyle(color: AppColors.primaryBlue, fontSize: 14),
        ),
        subtitle: Text(
          DateFormat('yyyy-MM-dd').format(deadline),
          style: const TextStyle(fontSize: 16),
        ),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: deadline,
            firstDate: _currentDate,
            lastDate: _currentDate.add(const Duration(days: 3650)),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: AppColors.primaryBlue,
                    onPrimary: Colors.white,
                    surface: AppColors.secondaryPink,
                    onSurface: AppColors.primaryBlue,
                  ),
                ),
                child: child!,
              );
            },
          );
          onPicked(picked);
        },
      ),
    );
  }

  Widget _buildGoalCard(GoalModel goal) {
    final double targetAmount = goal.targetAmount;
    final double currentAmount = goal.currentAmount;
    final DateTime deadline =
        goal.deadline ?? _currentDate.add(const Duration(days: 365));
    final double progress = goal.progressPercentage;
    final bool isCompleted = goal.isCompleted;
    final daysLeft = deadline.difference(_currentDate).inDays;

    final Color statusColor = isCompleted
        ? AppColors.successGreen
        : daysLeft < 0
            ? AppColors.errorRed
            : daysLeft < 30
                ? Colors.orange
                : AppColors.primaryBlue;

    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.secondaryPink, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Savings', // For now, all goals are savings type
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: AppColors.primaryBlue,
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Goal'),
                          content: const Text(
                              'Are you sure you want to delete this goal?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        try {
                          await _deleteGoal(goal.id!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Goal deleted successfully'),
                              backgroundColor: AppColors.successGreen,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to delete goal: $e'),
                              backgroundColor: AppColors.errorRed,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  CircularPercentIndicator(
                    radius: 50.0,
                    lineWidth: 10.0,
                    percent: progress,
                    center: Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    progressColor: statusColor,
                    backgroundColor: AppColors.secondaryPink,
                    animation: true,
                    animationDuration: 1000,
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.primaryBlue.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_currencySymbol ${NumberFormat('#,##0').format(currentAmount)} / ${NumberFormat('#,##0').format(targetAmount)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.secondaryPink,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              statusColor,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      daysLeft < 0
                          ? 'Overdue by ${-daysLeft} days'
                          : '$daysLeft days left',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: isCompleted
                        ? null
                        : () => _showUpdateProgressDialog(
                              goal.id!,
                              currentAmount,
                              targetAmount,
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Update Progress'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 500))
        .slideX(begin: 0.2, end: 0);
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Financial Goals',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddGoalDialog,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.secondaryPink, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: user == null
            ? Center(
                child: Text(
                  'Please sign in to continue',
                  style: TextStyle(color: AppColors.primaryBlue),
                ),
              )
            : StreamBuilder<List<GoalModel>>(
                stream: _goalRepository.streamUserGoals(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppColors.errorRed,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Something went wrong',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: AppColors.primaryBlue,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.primaryBlue.withOpacity(0.7),
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => setState(() {}),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                            ),
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting &&
                      _goals.isEmpty) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryBlue),
                      ),
                    );
                  }

                  final goals = snapshot.data ?? _goals;

                  if (goals.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.flag_outlined,
                            size: 80,
                            color: AppColors.primaryBlue.withOpacity(0.3),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No goals set yet',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Start by creating your first financial goal',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.primaryBlue.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _showAddGoalDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Your First Goal'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 16, bottom: 100),
                    itemCount: goals.length,
                    itemBuilder: (context, index) {
                      return _buildGoalCard(goals[index]);
                    },
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalDialog,
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
