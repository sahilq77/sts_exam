import 'package:flutter/material.dart';

class DottedDivider extends StatelessWidget {
  final double height;
  final double dotWidth;
  final double spacing;
  final Color color;

  const DottedDivider({
    Key? key,
    this.height = 1,
    this.dotWidth = 4,
    this.spacing = 4,
    this.color = Colors.black12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxCount = (constraints.maxWidth / (dotWidth + spacing)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(boxCount, (_) {
            return Container(
              width: dotWidth,
              height: height,
              color: color,
            );
          }),
        );
      },
    );
  }
}
