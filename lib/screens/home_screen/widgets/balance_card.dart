// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// Constants for better maintainability
const double _kHorizontalMargin = 16.0;
const double _kCardPadding = 24.0;
const double _kBorderRadius = 24.0;
const Duration _kAnimationDuration = Duration(milliseconds: 200);

// Custom exception for balance card errors
class BalanceCardException implements Exception {
  final String message;
  BalanceCardException(this.message);

  @override
  String toString() => 'BalanceCardException: $message';
}

class BalanceCard extends StatefulWidget {
  final double totalBalance;
  final double totalIncome;
  final double totalExpenses;
  final bool isLoading;
  final String Function(double) formatCurrency;
  final String? currencyCode; // Added to handle currency preferences

  const BalanceCard({
    Key? key,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpenses,
    required this.isLoading,
    required this.formatCurrency,
    this.currencyCode = 'KES', // Default currency
  })  : assert(totalIncome >= 0, 'Total income cannot be negative'),
        assert(totalExpenses >= 0, 'Total expenses cannot be negative'),
        super(key: key);

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  bool _isHovering = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    try {
      _controller = AnimationController(
        duration: _kAnimationDuration,
        vsync: this,
      );

      _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut,
        ),
      );
    } catch (e) {
      _setError('Failed to initialize animations: $e');
    }
  }

  void _setError(String message) {
    setState(() {
      _hasError = true;
      _errorMessage = message;
    });
    debugPrint('BalanceCard Error: $message');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorCard();
    }

    return MouseRegion(
      onEnter: (_) => _handleHoverStart(),
      onExit: (_) => _handleHoverEnd(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => _buildCard(context, child),
      ),
    );
  }

  void _handleHoverStart() {
    setState(() => _isHovering = true);
    _controller.forward();
  }

  void _handleHoverEnd() {
    setState(() => _isHovering = false);
    _controller.reverse();
  }

  Widget _buildCard(BuildContext context, Widget? child) {
    return Transform.scale(
      scale: _scaleAnimation.value,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: _kHorizontalMargin),
        padding: const EdgeInsets.all(_kCardPadding),
        decoration: _buildCardDecoration(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_kBorderRadius - 4),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: _buildCardContent(),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color(0xFF6C63FF),
          Color(0xFF8B85FF),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(_kBorderRadius),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF6C63FF).withOpacity(0.4),
          blurRadius: 24,
          offset: const Offset(0, 12),
          spreadRadius: _isHovering ? 3 : 0,
        ),
      ],
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1.5,
      ),
    );
  }

  Widget _buildCardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        const SizedBox(height: 10),
        _buildBalance(),
        const SizedBox(height: 30),
        _buildDivider(),
        const SizedBox(height: 20),
        _buildTransactionSummary(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total Balance',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
          ),
        ),
        if (widget.currencyCode != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.currencyCode!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBalance() {
    if (widget.isLoading) {
      return _buildShimmer();
    }

    return Text(
      widget.formatCurrency(widget.totalBalance),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 36,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        shadows: [
          Shadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.4),
      highlightColor: Colors.white.withOpacity(0.2),
      child: Container(
        width: 150,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.0),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }

  Widget _buildTransactionSummary() {
    return FittedBox(
      fit: BoxFit.fitWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBalanceItem(
            Icons.trending_up_rounded,
            'Income',
            widget.formatCurrency(widget.totalIncome),
            Colors.green.shade400,
          ),
          const SizedBox(width: 16),
          _buildBalanceItem(
            Icons.trending_down_rounded,
            'Expenses',
            widget.formatCurrency(widget.totalExpenses),
            Colors.red.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(
    IconData icon,
    String label,
    String amount,
    Color iconColor,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: _kHorizontalMargin),
      padding: const EdgeInsets.all(_kCardPadding),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(_kBorderRadius),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage ?? 'An error occurred',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
