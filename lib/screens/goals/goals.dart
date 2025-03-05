import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';


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
    'Vehicle'
  ];

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
              .map((doc) => {
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id,
          })
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
        title: const Text('Add New Goal'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Goal Title'),
                  validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter a title' : null,
                  onSaved: (value) => title = value ?? '',
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Target Amount (KES)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onSaved: (value) => targetAmount = double.parse(value ?? '0'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Category'),
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
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Deadline'),
                  subtitle: Text(
                    DateFormat('yyyy-MM-dd').format(deadline),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: deadline,
                      firstDate: _currentDate,
                      lastDate: _currentDate.add(const Duration(days: 3650)),
                    );
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
            child: const Text('Cancel'),
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
            child: const Text('Add Goal'),
          ),
        ],
      ),
    );
  }

  void _showUpdateProgressDialog(String goalId, double currentAmount, double targetAmount) {
    final formKey = GlobalKey<FormState>();
    double newAmount = currentAmount;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Progress'),
        content: Form(
          key: formKey,
          child: TextFormField(
            initialValue: currentAmount.toString(),
            decoration: const InputDecoration(labelText: 'Current Amount (KES)'),
            keyboardType: TextInputType.number,
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
            onSaved: (value) => newAmount = double.parse(value ?? '0'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                _updateGoalProgress(goalId, newAmount);
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> goal) {
    final double targetAmount = (goal['targetAmount'] as num).toDouble();
    final double currentAmount = (goal['currentAmount'] as num).toDouble();
    final DateTime deadline = (goal['deadline'] as Timestamp).toDate();
    final double progress = targetAmount > 0 ? (currentAmount / targetAmount) : 0;
    final bool isCompleted = currentAmount >= targetAmount;
    final daysLeft = deadline.difference(_currentDate).inDays;

    final Color statusColor = isCompleted
        ? Colors.green
        : daysLeft < 0
        ? Colors.red
        : daysLeft < 30
        ? Colors.orange
        : Colors.blue;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        goal['category'],
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteGoal(goal['id']),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircularPercentIndicator(
                  radius: 45.0,
                  lineWidth: 8.0,
                  percent: progress,
                  center: Text('${(progress * 100).toInt()}%'),
                  progressColor: statusColor,
                  backgroundColor: Colors.grey[200]!,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KES ${NumberFormat('#,##0').format(currentAmount)} / ${NumberFormat('#,##0').format(targetAmount)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  daysLeft < 0
                      ? 'Overdue by ${-daysLeft} days'
                      : '$daysLeft days left',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: isCompleted
                      ? null
                      : () => _showUpdateProgressDialog(
                    goal['id'],
                    currentAmount,
                    targetAmount,
                  ),
                  child: const Text('Update Progress'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddGoalDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _goals.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.flag_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No goals set yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _showAddGoalDialog,
              child: const Text('Add Your First Goal'),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _goals.length,
        itemBuilder: (context, index) => _buildGoalCard(_goals[index]),
      ),
    );
  }
}