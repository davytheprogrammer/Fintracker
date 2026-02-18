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
  // Optimistic local updates for immediate UI feedback when adding savings
  final Map<String, double> _optimisticProgress = {};
  late String _currencySymbol;
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
      debugPrint('Error loading user preferences: $e');
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
      debugPrint('Error adding goal: $e');
      rethrow;
    }
  }

  Future<void> _updateGoal(String goalId, Map<String, dynamic> goalData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      // Fetch existing goal first to preserve creation date/current amount if needed
      // But we have the goal object usually.
      // Actually, we should just update the fields we changed.

      final updatedGoal = GoalModel(
        id: goalId,
        uid: user.uid,
        name: goalData['title'],
        targetAmount: goalData['targetAmount'],
        deadline: goalData['deadline'],
        currentAmount: goalData['currentAmount'] ?? 0.0,
        // Preserve original creation date if possible, but here we construct new object
        // The repository update might replace the doc.
        // Let's ensure we keep the creation date.
        // We'll trust the repository handles it or we pass it if we have it.
        // Actually, GoalModel constructor makes a new createdAt if null.
        // We should pass the original createdAt.
        createdAt: goalData['createdAt'],
      );

      await _goalRepository.updateGoal(goalId, updatedGoal, user.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Goal updated successfully'),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating goal: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update goal: $e'),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showGoalDialog({GoalModel? goal}) {
    final isEditing = goal != null;
    final formKey = GlobalKey<FormState>();

    String title = goal?.name ?? '';
    double targetAmount = goal?.targetAmount ?? 0;
    double currentAmount = goal?.currentAmount ?? 0;
    DateTime deadline =
        goal?.deadline ?? _currentDate.add(const Duration(days: 30));

    // Wait, GoalModel doesn't have 'category'. The UI had a dropdown but the model didn't store it!
    // The previous implementation of _addGoal used 'category': category in the map but GoalModel ignored it.
    // We should probably add category to GoalModel in a comprehensive fix, but for now I'll stick to what the model supports
    // or just let the user pick it even if it's not saved (which is bad UX).
    // The model has 'name', 'targetAmount', 'currentAmount', 'deadline'.
    // I'll skip category since it doesn't persist, or I should update the model.
    // Updating the model requires migration which might be risky without checking usage.
    // I'll check GoalModel again. It does NOT have category.
    // So the category dropdown in the original code was fake/temporary!
    // I will REMOVE the category dropdown to avoid confusion, or I should add it.
    // Given the user wants "UX is good generally", having a dropdown that does nothing is bad.
    // I will remove it for now.

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.secondaryPink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEditing ? 'Edit Goal' : 'Create New Goal',
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
                  initialValue: title,
                  onSaved: (value) => title = value ?? '',
                  validator: (value) => value?.trim().isEmpty ?? true
                      ? 'Please enter a title'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  label: 'Target Amount ($_currencySymbol)',
                  icon: Icons.monetization_on,
                  keyboardType: TextInputType.number,
                  initialValue:
                      targetAmount > 0 ? targetAmount.toString() : null,
                  onSaved: (value) => targetAmount = double.parse(value ?? '0'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null) {
                      return 'Please enter a valid number';
                    }
                    if (amount <= 0) {
                      return 'Target must be greater than 0';
                    }
                    if (isEditing && amount < currentAmount) {
                      return 'Target cannot be less than current progress';
                    }
                    return null;
                  },
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
                  Navigator.pop(context); // Close dialog first

                  if (isEditing) {
                    await _updateGoal(goal.id!, {
                      'title': title,
                      'targetAmount': targetAmount,
                      'deadline': deadline,
                      'currentAmount': currentAmount,
                      'createdAt': goal.createdAt,
                    });
                  } else {
                    await _addGoal({
                      'title': title,
                      'targetAmount': targetAmount,
                      'deadline': deadline,
                    });
                  }
                } catch (e) {
                  // Error handling is done in _addGoal/_updateGoal
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
            child: Text(
              isEditing ? 'Save Changes' : 'Create Goal',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateProgressDialog(GoalModel goal) {
    final formKey = GlobalKey<FormState>();
    double addAmount = 0;
    bool isAdding = true; // Toggle between adding amount or setting total

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.secondaryPink,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Current: $_currencySymbol${NumberFormat('#,##0').format(goal.currentAmount)} / $_currencySymbol${NumberFormat('#,##0').format(goal.targetAmount)}',
                      style: TextStyle(
                        color: AppColors.primaryBlue.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      label: 'Amount to Add ($_currencySymbol)',
                      icon: Icons.savings,
                      keyboardType: TextInputType.number,
                      onSaved: (value) =>
                          addAmount = double.parse(value ?? '0'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null) {
                          return 'Please enter a valid number';
                        }
                        if (amount <= 0) {
                          return 'Amount must be positive';
                        }
                        if (goal.currentAmount + amount > goal.targetAmount) {
                          return 'Cannot exceed target amount';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel',
                      style: TextStyle(color: AppColors.primaryBlue)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      formKey.currentState?.save();
                      try {
                        // Apply optimistic UI update so the user sees immediate feedback
                        if (goal.id != null) {
                          setState(() {
                            _optimisticProgress[goal.id!] =
                                goal.currentAmount + addAmount;
                          });
                        }

                        await _updateGoalProgress(
                            goal.id!, goal.currentAmount + addAmount);

                        // Close dialog after successful update
                        Navigator.pop(context);

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  const Text('Progress updated successfully'),
                              backgroundColor: AppColors.successGreen,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } catch (e) {
                        // Remove optimistic update on error
                        if (goal.id != null) {
                          setState(() {
                            _optimisticProgress.remove(goal.id!);
                          });
                        }
                        // Error handling is already in _updateGoalProgress
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Add to Savings',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateGoalProgress(String goalId, double newAmount) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      await _goalRepository.updateGoalProgress(goalId, user.uid, newAmount);
      // UI updates via stream
    } catch (e) {
      debugPrint('Error updating goal progress: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update progress: $e'),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteGoal(String goalId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      await _goalRepository.deleteGoal(goalId, user.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Goal deleted successfully'),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error deleting goal: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete goal: $e'),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Target: $_currencySymbol${NumberFormat('#,##0').format(targetAmount)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primaryBlue.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: AppColors.primaryBlue),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        _showGoalDialog(goal: goal);
                      } else if (value == 'delete') {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Goal'),
                            content: Text(
                                'Are you sure you want to delete "${goal.name}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await _deleteGoal(goal.id!);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    const Text('Goal deleted successfully'),
                                backgroundColor: AppColors.successGreen,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit, size: 20),
                          title: Text('Edit Goal'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: ListTile(
                          leading:
                              Icon(Icons.delete, color: Colors.red, size: 20),
                          title: Text('Delete Goal',
                              style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  CircularPercentIndicator(
                    radius: 45.0,
                    lineWidth: 8.0,
                    percent: progress,
                    center: Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    progressColor: statusColor,
                    backgroundColor: Colors.white,
                    circularStrokeCap: CircularStrokeCap.round,
                    animation: true,
                    animationDuration: 1000,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saved so far',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primaryBlue.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_currencySymbol${NumberFormat('#,##0').format(currentAmount)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(statusColor),
                            minHeight: 6,
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          daysLeft < 0 ? 'Overdue' : '$daysLeft days left',
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isCompleted)
                    ElevatedButton.icon(
                      onPressed: () => _showUpdateProgressDialog(goal),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Savings'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
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
        .slideX(begin: 0.1, end: 0);
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
            onPressed: () => _showGoalDialog(),
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

                  // Merge any optimistic progress updates so UI reflects changes immediately
                  final displayedGoals = goals.map((g) {
                    if (g.id != null && _optimisticProgress.containsKey(g.id)) {
                      return g.copyWith(
                          currentAmount: _optimisticProgress[g.id]);
                    }
                    return g;
                  }).toList();

                  // Clean up optimistic entries when the stream contains the persisted value
                  if (snapshot.hasData) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      bool changed = false;
                      final keys = List<String>.from(_optimisticProgress.keys);
                      for (final key in keys) {
                        final persistedList =
                            goals.where((x) => x.id == key).toList();
                        if (persistedList.isEmpty) continue;
                        final persisted = persistedList.first;
                        final optimistic = _optimisticProgress[key];
                        if (optimistic != null) {
                          if (persisted.currentAmount >= optimistic) {
                            _optimisticProgress.remove(key);
                            changed = true;
                          }
                        }
                      }
                      if (changed && mounted) setState(() {});
                    });
                  }

                  if (displayedGoals.isEmpty) {
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
                            onPressed: () => _showGoalDialog(),
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
                    itemCount: displayedGoals.length,
                    itemBuilder: (context, index) {
                      return _buildGoalCard(displayedGoals[index]);
                    },
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showGoalDialog(),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
