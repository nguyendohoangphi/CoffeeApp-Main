import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AnimatedIconVideo extends StatefulWidget {
  final VideoPlayerController controller;
  final double width;
  final double height;

  const AnimatedIconVideo({
    super.key,
    required this.controller,
    this.width = 32,
    this.height = 32,
  });

  @override
  State<AnimatedIconVideo> createState() => _AnimatedIconVideoState();
}

class _AnimatedIconVideoState extends State<AnimatedIconVideo> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: VideoPlayer(widget.controller),
    );
  }
}
