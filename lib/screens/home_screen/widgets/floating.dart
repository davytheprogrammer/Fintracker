import 'package:flutter/material.dart';
import '../../form/transaction_modal.dart';

class FloatingActionButtonWidget extends StatefulWidget {
  const FloatingActionButtonWidget({Key? key}) : super(key: key);

  @override
  _FloatingActionButtonWidgetState createState() =>
      _FloatingActionButtonWidgetState();
}

class _FloatingActionButtonWidgetState extends State<FloatingActionButtonWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _navigateToTransactionForm(bool isIncome) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionFormPage(isIncome: isIncome),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Income Button
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(-70 * _animation.value, -60 * _animation.value),
              child: Transform.scale(
                scale: _animation.value,
                child: Opacity(
                  opacity: _animation.value,
                  child: FloatingActionButton(
                    heroTag: "income",
                    backgroundColor: Colors.green.shade400,
                    onPressed: () {
                      print('Income button pressed');
                      _navigateToTransactionForm(true);
                    },
                    child: const Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        // Expense Button
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(70 * _animation.value, -60 * _animation.value),
              child: Transform.scale(
                scale: _animation.value,
                child: Opacity(
                  opacity: _animation.value,
                  child: FloatingActionButton(
                    heroTag: "expense",
                    backgroundColor: Colors.redAccent,
                    onPressed: () {
                      print('Expense button pressed');
                      _navigateToTransactionForm(false);
                    },
                    child: const Icon(
                      Icons.arrow_downward,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        // Main FAB
        FloatingActionButton(
          backgroundColor: const Color(0xFF2C3E50),
          elevation: 8,
          onPressed: _toggleExpanded,
          child: AnimatedRotation(
            turns: _isExpanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 300),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
