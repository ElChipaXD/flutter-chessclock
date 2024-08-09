import 'package:flutter/material.dart';

class DelayIndicator extends StatelessWidget {
  final double progress;
  final int player;
  DelayIndicator(this.progress, this.player);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
        child: Align(
            alignment: Alignment.center,
            child: Container(
              child: CircularProgressIndicator(
                value: progress == 0 ? 0 : 1 - progress,
                strokeWidth: 16,
                valueColor: AlwaysStoppedAnimation<Color>(
                    this.player == 2 ? Colors.white10 : Colors.black12),
              ),
              height: 280,
              width: 280,
            )));
  }
}
