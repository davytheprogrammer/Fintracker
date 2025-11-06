import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';

class TransactionFAB extends StatefulWidget {
  final Function(bool isIncome) onTransactionSelected;
  final VoidCallback? onAnalyticsPressed;
  final bool showAnalytics;

  const TransactionFAB({
    Key? key,
    required this.onTransactionSelected,
    this.onAnalyticsPressed,
    this.showAnalytics = true,
  }) : super(key: key);

  @override
  State<TransactionFAB> createState() => _TransactionFABState();
}

class _TransactionFABState extends State<TransactionFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _blurAnimation;
  bool _isExpanded = false;

  // Micro-animation controllers
  final ValueNotifier<bool> _incomeHovered = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _expenseHovered = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _analyticsHovered = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubicEmphasized,
      reverseCurve: Curves.easeInOutCubicEmphasized.flipped,
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 0.125).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInBack,
      ),
    );

    _blurAnimation = Tween<double>(
      begin: 0,
      end: 3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  Future<void> _handleFABPressed() async {
    try {
      HapticFeedback.mediumImpact();
      setState(() => _isExpanded = !_isExpanded);
      if (_isExpanded) {
        await _controller.forward();
      } else {
        await _controller.reverse();
      }
    } catch (e) {
      debugPrint('Error in FAB animation: $e');
      _resetState();
    }
  }

  void _resetState() {
    setState(() => _isExpanded = false);
    _controller.reset();
  }

  Future<void> _handleTransactionType(bool isIncome) async {
    try {
      HapticFeedback.selectionClick();
      await _controller.reverse();
      setState(() => _isExpanded = false);
      widget.onTransactionSelected(isIncome);
    } catch (e) {
      debugPrint('Error handling transaction type: $e');
      _resetState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Blur overlay
        if (_isExpanded)
          AnimatedBuilder(
            animation: _blurAnimation,
            builder: (context, child) {
              return BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: _blurAnimation.value,
                  sigmaY: _blurAnimation.value,
                ),
                child: GestureDetector(
                  onTap: _handleFABPressed,
                  child: Container(color: Colors.black.withOpacity(0.1)),
                ),
              );
            },
          ),

        // FAB Menu
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Income FAB
              ScaleTransition(
                scale: _expandAnimation,
                child: _FloatingMenuItem(
                  icon: Icons.arrow_upward_rounded,
                  label: 'Income',
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  onPressed: () => _handleTransactionType(true),
                  hoveredNotifier: _incomeHovered,
                ),
              ),
              const SizedBox(height: 16),

              // Expense FAB
              ScaleTransition(
                scale: _expandAnimation,
                child: _FloatingMenuItem(
                  icon: Icons.arrow_downward_rounded,
                  label: 'Expense',
                  backgroundColor: colorScheme.errorContainer,
                  foregroundColor: colorScheme.onErrorContainer,
                  onPressed: () => _handleTransactionType(false),
                  hoveredNotifier: _expenseHovered,
                ),
              ),
              const SizedBox(height: 16),

              // Main FAB
              _buildMainFAB(colorScheme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainFAB(ColorScheme colorScheme) {
    return GestureDetector(
      onTap: _handleFABPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(_isExpanded ? 0.4 : 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  Color.lerp(colorScheme.primary, colorScheme.secondary, 0.5)!,
                ],
              ),
            ),
            child: RotationTransition(
              turns: _rotateAnimation,
              child: Icon(
                Icons.add_rounded,
                color: colorScheme.onPrimary,
                size: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _incomeHovered.dispose();
    _expenseHovered.dispose();
    _analyticsHovered.dispose();
    super.dispose();
  }
}

class _FloatingMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onPressed;
  final ValueNotifier<bool> hoveredNotifier;

  const _FloatingMenuItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    required this.hoveredNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => hoveredNotifier.value = true,
      onExit: (_) => hoveredNotifier.value = false,
      child: ValueListenableBuilder<bool>(
        valueListenable: hoveredNotifier,
        builder: (context, isHovered, child) {
          return AnimatedScale(
            scale: isHovered ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: backgroundColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: foregroundColor),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: TextStyle(
                          color: foregroundColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
