import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';

class Executeratingdisplay extends StatefulWidget {
  final double rate;
  const Executeratingdisplay({super.key, required this.rate});

  @override
  State<Executeratingdisplay> createState() => _ExecuteratingdisplayState();
}

class _ExecuteratingdisplayState extends State<Executeratingdisplay> {
  @override
  Widget build(BuildContext context) {
    return RatingStars(
      axis: Axis.horizontal,
      value: widget.rate,
      starCount: 5,
      starSize: 20,
      // valueLabelColor: const Color(0xff9b9b9b),
      // valueLabelTextStyle: const TextStyle(
      //   color: Colors.white,
      //   fontWeight: FontWeight.w400,
      //   fontStyle: FontStyle.normal,
      //   fontSize: 12.0,
      // ),
      // valueLabelRadius: 10,
      maxValue: 5,
      starSpacing: 2,
      maxValueVisibility: true,
      valueLabelVisibility: false,
      animationDuration: Duration(milliseconds: 1000),
      // valueLabelPadding: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
      // valueLabelMargin: const EdgeInsets.only(right: 8),
      starOffColor: const Color(0xffe7e8ea),
      starColor: Colors.amberAccent,
      angle: 12,
    );
  }
}
