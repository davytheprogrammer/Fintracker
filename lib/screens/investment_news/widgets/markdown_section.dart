import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../shared/constants.dart';

class MarkdownSection extends StatelessWidget {
  final Map<String, dynamic> roadmapData;

  const MarkdownSection({super.key, required this.roadmapData});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: glassCardDecoration(isDark: isDarkMode),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Investment Analysis',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.download, color: AppColors.primary),
                  onPressed: () {},
                  tooltip: 'Download markdown file',
                ),
              ],
            ),
            const Divider(color: AppColors.divider),
            const SizedBox(height: AppSpacing.sm),
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: isDarkMode ? AppColors.borderDark : AppColors.border,
                ),
              ),
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Markdown(
                data: roadmapData['markdown_content'] ??
                    '## No Markdown Content Available\n\nPlease generate markdown content first.',
                selectable: true,
                padding: EdgeInsets.zero,
                physics: const AlwaysScrollableScrollPhysics(),
                styleSheet: MarkdownStyleSheet(
                  h1: AppTypography.headlineMedium
                      .copyWith(color: AppColors.primary),
                  h2: AppTypography.titleLarge
                      .copyWith(color: AppColors.primary),
                  h3: AppTypography.titleMedium
                      .copyWith(fontWeight: FontWeight.bold),
                  p: AppTypography.bodyMedium,
                  a: const TextStyle(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                  listBullet: AppTypography.bodyMedium,
                  code: AppTypography.bodySmall.copyWith(
                    fontFamily: 'monospace',
                    fontFamilyFallback: const ['NotoColorEmoji'],
                    backgroundColor:
                        isDarkMode ? AppColors.surfaceDark : AppColors.surface,
                    color: AppColors.success,
                  ),
                  blockquote: AppTypography.bodyMedium.copyWith(
                    color: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                  blockquotePadding: const EdgeInsets.all(AppSpacing.sm),
                  blockquoteDecoration: BoxDecoration(
                    color:
                        isDarkMode ? AppColors.surfaceDark : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                    border: Border(
                      left: BorderSide(color: AppColors.primary, width: 4),
                    ),
                  ),
                  tableBorder: TableBorder.all(
                    color: isDarkMode ? AppColors.borderDark : AppColors.border,
                    width: 1,
                  ),
                  tableHead: AppTypography.labelLarge
                      .copyWith(fontWeight: FontWeight.bold),
                  tableBody: AppTypography.bodyMedium,
                ),
                onTapLink: (text, href, title) {
                  if (href != null) {
                    // Handle link tapping here (e.g., launchUrl)
                  }
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Note: A detailed markdown file has been generated instead of a JSON structure due to API limitations. You can download this file for a comprehensive analysis.',
              style: AppTypography.bodySmall.copyWith(
                fontStyle: FontStyle.italic,
                color: isDarkMode
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
