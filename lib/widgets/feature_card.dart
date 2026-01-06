import 'package:flutter/material.dart';
import '../theme.dart';

class FeatureCard extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String description;
  final VoidCallback? onTap;
  final String? badge;
  final Color? accentColor;

  const FeatureCard({
    super.key,
    this.leading,
    required this.title,
    required this.description,
    this.onTap,
    this.badge,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            if (leading != null)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (accentColor ?? AppColors.primary).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: leading),
              ),
            if (leading != null) const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(description,
                      style: TextStyle(color: AppColors.mutedText, fontSize: 12)),
                ],
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(badge!,
                    style:
                        TextStyle(color: AppColors.mutedText, fontSize: 11)),
              ),
          ],
        ),
      ),
    );
  }
}
