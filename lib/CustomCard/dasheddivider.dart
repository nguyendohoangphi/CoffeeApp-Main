import 'package:flutter/material.dart';

class DashedDivider extends StatelessWidget {
  final double dashWidth;
  final double dashSpace;
  final double thickness;
  final Color color;
  final double? width; // Thêm tham số width

  const DashedDivider({
    super.key,
    this.dashWidth = 5,
    this.dashSpace = 3,
    this.thickness = 1,
    this.color = Colors.grey,
    this.width, // Cập nhật constructor
  });

  @override
  Widget build(BuildContext context) {
    // Sử dụng SizedBox để cố định chiều rộng nếu 'width' được truyền vào.
    // Nếu 'width' là null, SizedBox sẽ không giới hạn chiều rộng (bằng với widget cha).
    return SizedBox(
      width: width, 
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // boxWidth sẽ là giá trị của 'width' nếu nó được truyền vào, 
          // hoặc là chiều rộng tối đa của widget cha nếu 'width' là null.
          final boxWidth = constraints.constrainWidth();
          final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
          
          return Flex(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            direction: Axis.horizontal,
            children: List.generate(dashCount, (_) {
              return SizedBox(
                width: dashWidth,
                height: thickness,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: color),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}