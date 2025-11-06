import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AIInsightCard extends StatelessWidget {
  final String aiInsight;
  final bool isLoadingAIInsight;
  final VoidCallback performAIAnalysis;

  const AIInsightCard({
    Key? key,
    required this.aiInsight,
    required this.isLoadingAIInsight,
    required this.performAIAnalysis,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF6B9D).withOpacity(0.1),
            const Color(0xFFFF8FB5).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFF6B9D).withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B9D).withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: isLoadingAIInsight
            ? _buildAIInsightShimmer()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFFF6B9D).withOpacity(0.2),
                                  const Color(0xFFFF8FB5).withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFFF6B9D).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.tips_and_updates_rounded,
                              color: Color(0xFFFF6B9D),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Text(
                            'AI Insights',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B9D).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: Color(0xFFFF6B9D),
                          ),
                          onPressed: performAIAnalysis,
                          tooltip: 'Refresh insights',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF6B9D).withOpacity(0.3),
                          Colors.transparent,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  MarkdownBody(
                    data: aiInsight,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        fontSize: 15,
                        color: isDark ? const Color(0xFFB8B9BE) : const Color(0xFF374151),
                        height: 1.6,
                        letterSpacing: 0.3,
                      ),
                      strong: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF6B9D),
                      ),
                      listBullet: TextStyle(
                        color: const Color(0xFFFF6B9D).withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAIInsightShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Container(width: 100, height: 24, color: Colors.white),
            ],
          ),
          const SizedBox(height: 20),
          Container(width: double.infinity, height: 16, color: Colors.white),
          const SizedBox(height: 8),
          Container(width: double.infinity, height: 16, color: Colors.white),
          const SizedBox(height: 8),
          Container(width: double.infinity, height: 16, color: Colors.white),
          const SizedBox(height: 8),
          Container(width: 200, height: 16, color: Colors.white),
        ],
      ),
    );
  }
}
