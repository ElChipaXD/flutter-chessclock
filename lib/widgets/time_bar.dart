import 'package:flutter/material.dart';

class TimeBar extends StatelessWidget {
  final double progress;
  final Alignment alignment;
  final Color barColor;

  TimeBar(
      {this.progress = 0,
      this.alignment = Alignment.centerLeft,
      required this.barColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      height: 8,
      color: Colors.grey[300],
      child: Container(
        color: barColor,
        height: 30,
        width: MediaQuery.of(context).size.width * progress,
      ),
    );
  }
}
