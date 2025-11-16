import 'package:flutter/material.dart';

class DashedDivider extends StatelessWidget {
  final double width;
  final double dashWidth;
  final double dashSpace;
  final double thickness;
  final Color color;

  const DashedDivider({
    super.key,
    required this.width,
    this.dashWidth = 5,
    this.dashSpace = 3,
    this.thickness = 1,
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: thickness,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boxWidth = constraints.constrainWidth();
          final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
          return Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dashCount, (_) {
              return SizedBox(
                width: dashWidth,
                height: thickness,
                child: DecoratedBox(decoration: BoxDecoration(color: color)),
              );
            }),
          );
        },
      ),
    );
  }
}
