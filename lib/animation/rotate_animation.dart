import 'package:flutter/material.dart';

class RotateAnimation extends StatefulWidget {
  final Widget child;
  final bool rotate;
  const RotateAnimation({super.key, this.rotate = false, required this.child});

  @override
  State<RotateAnimation> createState() => _RotateAnimationState();
}

class _RotateAnimationState extends State<RotateAnimation> with SingleTickerProviderStateMixin {
  late AnimationController rotateController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    prepareAnimations();
    _runExpandCheck();
  }

  ///Setting up the animation
  void prepareAnimations() {
    rotateController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    animation = CurvedAnimation(parent: rotateController, curve: Curves.fastOutSlowIn);
  }

  void _runExpandCheck() {
    if (widget.rotate) {
      rotateController.forward();
    } else {
      rotateController.reverse();
    }
  }

  @override
  void didUpdateWidget(RotateAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    _runExpandCheck();
  }

  @override
  void dispose() {
    rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return SizeTransition(axisAlignment: 1.0, sizeFactor: animation, child: widget.child);
    return RotationTransition(
      turns: Tween(begin: 0.0, end: -0.5).animate(rotateController),
      child: widget.child,
    );
  }
}
