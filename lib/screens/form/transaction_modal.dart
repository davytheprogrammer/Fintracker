import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Custom color scheme
const kPrimaryColor = Color(0xFFF8BBD0); // Light pink
const kSecondaryColor = Color(0xFFFCE4EC); // Very light pink
const kAccentColor = Color(0xFF7986CB); // Indigo accent
const kTextColor = Color(0xFF2C3E50); // Dark blue-grey for text
const kBackgroundColor = Color(0xFFFAFAFA); // Almost white background

class TransactionFormPage extends StatefulWidget {
  final bool isIncome;

  const TransactionFormPage({Key? key, required this.isIncome})
    : super(key: key);

  @override
  _TransactionFormPageState createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage>
    with SingleTickerProviderStateMixin {
  // Keeping all the existing controllers and variables
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double _amount = 0;
  String _description = '';
  DateTime _date = DateTime.now();
  String _category = '';
  bool _isLoading = false;

  // Existing category lists
  final List<Map<String, dynamic>> _expenseCategories = [
    {'name': 'Food', 'icon': Icons.restaurant},
    {'name': 'Transport', 'icon': Icons.directions_car},
    {'name': 'Shopping', 'icon': Icons.shopping_bag},
    {'name': 'Bills', 'icon': Icons.receipt},
    {'name': 'Entertainment', 'icon': Icons.movie},
    {'name': 'Health', 'icon': Icons.medical_services},
    {'name': 'Education', 'icon': Icons.school},
    {'name': 'Other', 'icon': Icons.more_horiz},
  ];

  final List<Map<String, dynamic>> _incomeCategories = [
    {'name': 'Salary', 'icon': Icons.work},
    {'name': 'Freelance', 'icon': Icons.laptop},
    {'name': 'Investments', 'icon': Icons.trending_up},
    {'name': 'Gifts', 'icon': Icons.card_giftcard},
    {'name': 'Rental', 'icon': Icons.home},
    {'name': 'Refunds', 'icon': Icons.replay},
    {'name': 'Other', 'icon': Icons.more_horiz},
  ];

  @override
  void initState() {
    super.initState();
    _category = widget.isIncome
        ? _incomeCategories[0]['name']
        : _expenseCategories[0]['name'];
  }

  List<Map<String, dynamic>> get _categories {
    return widget.isIncome ? _incomeCategories : _expenseCategories;
  }

  // Keeping all existing methods unchanged
  Future<void> _saveTransaction() async {
    // Existing save transaction logic remains the same
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        final user = _auth.currentUser;
        if (user != null) {
          await _firestore.collection('transactions').add({
            'userId': user.uid,
            'type': widget.isIncome ? 'income' : 'expense',
            'category': _category,
            'amount': _amount,
            'description': _description,
            'date': Timestamp.fromDate(_date),
            'createdAt': FieldValue.serverTimestamp(),
          });

          DocumentReference userRef = _firestore
              .collection('users')
              .doc(user.uid);

          await _firestore.runTransaction((transaction) async {
            DocumentSnapshot userDoc = await transaction.get(userRef);

            if (!userDoc.exists) {
              transaction.set(userRef, {
                'balance': _amount * (widget.isIncome ? 1 : -1),
                'lastUpdated': FieldValue.serverTimestamp(),
              });
            } else {
              double currentBalance =
                  (userDoc.data() as Map<String, dynamic>)['balance'] ?? 0;
              transaction.update(userRef, {
                'balance':
                    currentBalance + (_amount * (widget.isIncome ? 1 : -1)),
                'lastUpdated': FieldValue.serverTimestamp(),
              });
            }
          });

          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${widget.isIncome ? "Income" : "Expense"} saved successfully',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: kAccentColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(10),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving transaction: $e'),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(10),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: kAccentColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: kTextColor,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          widget.isIncome ? 'Add Income' : 'Add Expense',
          style: const TextStyle(
            color: kTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kTextColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kSecondaryColor.withOpacity(0.3), kBackgroundColor],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Amount Input Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: kPrimaryColor.withOpacity(0.5)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Amount',
                          style: TextStyle(
                            color: kTextColor.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _amountController,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: kTextColor,
                          ),
                          decoration: InputDecoration(
                            prefixText: 'KES ',
                            prefixStyle: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: kAccentColor.withOpacity(0.7),
                            ),
                            border: InputBorder.none,
                            hintText: '0.00',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an amount';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            if (double.parse(value) <= 0) {
                              return 'Amount must be greater than 0';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _amount = double.parse(value!);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Categories
                const Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: kTextColor,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _category == category['name'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _category = category['name'];
                          });
                        },
                        child: Container(
                          width: 85,
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? kAccentColor
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? kAccentColor.withOpacity(0.3)
                                          : Colors.grey.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  category['icon'],
                                  color: isSelected ? Colors.white : kTextColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category['name'],
                                style: TextStyle(
                                  color: isSelected ? kAccentColor : kTextColor,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Description Field
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      hintText: 'Description',
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.description_outlined,
                        color: kAccentColor.withOpacity(0.7),
                      ),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _description = value!;
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Date Picker
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: kAccentColor.withOpacity(0.7),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('EEEE, MMM dd, yyyy').format(_date),
                            style: const TextStyle(
                              fontSize: 16,
                              color: kTextColor,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: kTextColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Save ${widget.isIncome ? 'Income' : 'Expense'}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
