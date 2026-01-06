import 'package:flutter/material.dart';
import '../theme.dart';

class SUDSSlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final String label;

  const SUDSSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'SUDs level',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value.toDouble(),
                min: 0,
                max: 100,
                divisions: 20,
                activeColor: AppColors.primary,
                onChanged: (newValue) => onChanged(newValue.round()),
              ),
            ),
            SizedBox(
              width: 48,
              child: Text(
                value.toString(),
                textAlign: TextAlign.end,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
