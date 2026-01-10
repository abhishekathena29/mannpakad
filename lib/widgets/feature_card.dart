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
    final color = accentColor ?? AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(20), // Glassmorphism
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withAlpha(30)),
          ),
          child: Row(
            children: [
              if (leading != null)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color.withAlpha(50), color.withAlpha(80)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withAlpha(100)),
                  ),
                  child: Center(child: leading),
                ),
              if (leading != null) const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: -0.3,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withAlpha(180),
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    gradient: badge == 'NEW'
                        ? LinearGradient(colors: AppColors.gradientPrimary)
                        : null,
                    color: badge != 'NEW' ? Colors.white.withAlpha(30) : null,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withAlpha(100),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
