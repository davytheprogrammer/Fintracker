import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BalanceCard extends StatefulWidget {
  final double totalBalance;
  final double totalIncome;
  final double totalExpenses;
  final bool isLoading;
  final String Function(double) formatCurrency;

  BalanceCard({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpenses,
    required this.isLoading,
    required this.formatCurrency,
  });

  @override
  _BalanceCardState createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovering = true;
        });
        _controller.forward();
      },
      onExit: (_) {
        setState(() {
          _isHovering = false;
        });
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFCE4EC), // Light pink gradient start
                    Color(0xFFF8BBD0), // Light pink gradient end
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFF8BBD0).withOpacity(0.5),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                    spreadRadius: _isHovering ? 5 : 0,
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Balance',
                        style: TextStyle(
                          color: Color(0xFF424242),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 10),
                      widget.isLoading
                          ? Shimmer.fromColors(
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
                      )
                          : Text(
                        widget.formatCurrency(widget.totalBalance),
                        style: TextStyle(
                          color: Color(0xFF424242),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.pink.withOpacity(0.05),
                              Colors.pink.withOpacity(0.2),
                              Colors.pink.withOpacity(0.05),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Wrap in a FittedBox to prevent horizontal overflow
                      FittedBox(
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
                            SizedBox(width: 16),
                            _buildBalanceItem(
                              Icons.trending_down_rounded,
                              'Expenses',
                              widget.formatCurrency(widget.totalExpenses),
                              Colors.red.shade300,
                            ),
                          ],
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

  Widget _buildBalanceItem(IconData icon, String label, String amount, Color iconColor) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Important: minimize row width
      children: [
        Container(
          padding: EdgeInsets.all(6), // Reduced from 10
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8), // Reduced from 12
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(0.1),
                blurRadius: 4, // Reduced from 8
                offset: Offset(0, 1), // Reduced from Offset(0, 2)
              ),
            ],
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 14, // Reduced from 20
          ),
        ),
        SizedBox(width: 8), // Reduced from 14
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Color(0xFF616161),
                fontSize: 10, // Reduced from 14
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 2), // Reduced from 5
            Text(
              amount,
              style: TextStyle(
                color: Color(0xFF424242),
                fontSize: 12, // Reduced from 18
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}