import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({Key? key}) : super(key: key);

  @override
  _GoalsPageState createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DateTime _currentDate = DateTime.utc(2025, 2, 17, 14, 31, 42);

  bool _isLoading = true;
  List<Map<String, dynamic>> _goals = [];
  String _selectedCategory = 'Savings';

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

  // Theme colors
  static final Color primaryPink = Colors.pink[400]!;
  static final Color lightPink = Colors.pink[50]!;
  static final Color darkPink = Colors.pink[900]!;
  static const Color white = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user != null) {
        final snapshot = await _firestore
            .collection('goals')
            .where('userId', isEqualTo: user.uid)
            .orderBy('deadline')
            .get();

        setState(() {
          _goals = snapshot.docs
              .map(
                (doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id},
              )
              .toList();
        });
      }
    } catch (e) {
      print('Error loading goals: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addGoal(Map<String, dynamic> goalData) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('goals').add({
          ...goalData,
          'userId': user.uid,
          'createdAt': Timestamp.now(),
          'currentAmount': 0.0,
        });
        _loadGoals();
      }
    } catch (e) {
      print('Error adding goal: $e');
    }
  }

  Future<void> _updateGoalProgress(String goalId, double amount) async {
    try {
      await _firestore.collection('goals').doc(goalId).update({
        'currentAmount': amount,
        'lastUpdated': Timestamp.now(),
      });
      _loadGoals();
    } catch (e) {
      print('Error updating goal: $e');
    }
  }

  Future<void> _deleteGoal(String goalId) async {
    try {
      await _firestore.collection('goals').doc(goalId).delete();
      _loadGoals();
    } catch (e) {
      print('Error deleting goal: $e');
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
        backgroundColor: lightPink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Create New Goal',
          style: TextStyle(
            color: darkPink,
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
                  label: 'Target Amount (KES)',
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
                    color: white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryPink.withOpacity(0.3)),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: category,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: TextStyle(color: darkPink),
                      prefixIcon: Icon(Icons.category, color: primaryPink),
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
            child: Text('Cancel', style: TextStyle(color: darkPink)),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                _addGoal({
                  'title': title,
                  'targetAmount': targetAmount,
                  'deadline': Timestamp.fromDate(deadline),
                  'category': category,
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Create Goal', style: TextStyle(color: white)),
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
        backgroundColor: lightPink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Update Progress',
          style: TextStyle(
            color: darkPink,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Form(
          key: formKey,
          child: _buildInputField(
            label: 'Current Amount (KES)',
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
            child: Text('Cancel', style: TextStyle(color: darkPink)),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                _updateGoalProgress(goalId, newAmount);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Update', style: TextStyle(color: white)),
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
        color: white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryPink.withOpacity(0.3)),
      ),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: darkPink),
          prefixIcon: Icon(icon, color: primaryPink),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        keyboardType: keyboardType,
        validator: validator,
        onSaved: onSaved,
        style: TextStyle(color: darkPink),
      ),
    );
  }

  Widget _buildDatePicker({
    required DateTime deadline,
    required Function(DateTime?) onPicked,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryPink.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: Icon(Icons.calendar_today, color: primaryPink),
        title: Text(
          'Deadline',
          style: TextStyle(color: darkPink, fontSize: 14),
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
                    primary: primaryPink,
                    onPrimary: white,
                    surface: lightPink,
                    onSurface: darkPink,
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

  Widget _buildGoalCard(Map<String, dynamic> goal) {
    final double targetAmount = (goal['targetAmount'] as num).toDouble();
    final double currentAmount = (goal['currentAmount'] as num).toDouble();
    final DateTime deadline = (goal['deadline'] as Timestamp).toDate();
    final double progress = targetAmount > 0
        ? (currentAmount / targetAmount)
        : 0;
    final bool isCompleted = currentAmount >= targetAmount;
    final daysLeft = deadline.difference(_currentDate).inDays;

    final Color statusColor = isCompleted
        ? Colors.green
        : daysLeft < 0
        ? Colors.red
        : daysLeft < 30
        ? Colors.orange
        : primaryPink;

    return Card(
          elevation: 8,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [lightPink, white],
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
                              goal['title'],
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: darkPink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: primaryPink.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                goal['category'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: darkPink,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: darkPink,
                        onPressed: () => _deleteGoal(goal['id']),
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
                            color: darkPink,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        progressColor: statusColor,
                        backgroundColor: lightPink,
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
                                color: darkPink.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'KES ${NumberFormat('#,##0').format(currentAmount)} / ${NumberFormat('#,##0').format(targetAmount)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: darkPink,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: lightPink,
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
                                goal['id'],
                                currentAmount,
                                targetAmount,
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryPink,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Financial Goals',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryPink,
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
            colors: [lightPink, white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryPink),
                ),
              )
            : _goals.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 80,
                      color: darkPink.withOpacity(0.3),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No goals set yet',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: darkPink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Start by creating your first financial goal',
                      style: TextStyle(
                        fontSize: 16,
                        color: darkPink.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _showAddGoalDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Your First Goal'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPink,
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
              )
            : ListView.builder(
                padding: const EdgeInsets.only(top: 16, bottom: 100),
                itemCount: _goals.length,
                itemBuilder: (context, index) {
                  return _buildGoalCard(_goals[index]);
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalDialog,
        backgroundColor: primaryPink,
        child: const Icon(Icons.add, color: white),
      ),
    );
  }
}
