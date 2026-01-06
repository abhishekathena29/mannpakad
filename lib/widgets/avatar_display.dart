import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';

class AvatarDisplay extends StatelessWidget {
  final Avatar? avatar;
  final double size;
  final bool showLevel;

  const AvatarDisplay({
    super.key,
    required this.avatar,
    this.size = 64,
    this.showLevel = false,
  });

  @override
  Widget build(BuildContext context) {
    if (avatar == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.muted,
          shape: BoxShape.circle,
        ),
        child: const Center(child: Text('?')),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.primaryLight, AppColors.calmLight],
            ),
          ),
          child: Center(
            child: Text(
              avatar!.style.emoji,
              style: TextStyle(fontSize: size * 0.5),
            ),
          ),
        ),
        if (showLevel)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Lvl ${avatar!.level}',
              style: TextStyle(color: AppColors.mutedText, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
