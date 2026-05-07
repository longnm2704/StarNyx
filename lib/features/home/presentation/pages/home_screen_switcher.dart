import 'package:flutter/material.dart';

/// Wraps any [child] in an [AnimatedSwitcher] that uses a combined fade +
/// subtle upward-slide transition when a new child arrives, and a plain fade
/// when the old child leaves.
///
/// Giving the outgoing child any translation while both are stacked causes a
/// visible "jump-up then drop" artifact, so only the incoming child slides.
class HomeScreenSwitcher extends StatelessWidget {
  const HomeScreenSwitcher({required this.child, super.key});

  final Widget child;

  static const Duration _duration = Duration(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: _duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: _buildTransition,
      layoutBuilder: _buildLayout,
      child: child,
    );
  }

  static Widget _buildTransition(
    Widget child,
    Animation<double> animation,
  ) {
    final isIncoming =
        animation.status == AnimationStatus.forward ||
        animation.status == AnimationStatus.completed;

    if (!isIncoming) {
      // Outgoing: plain fade, no movement.
      return FadeTransition(opacity: animation, child: child);
    }

    // Incoming: fade + subtle rise from ~4% below.
    final slideOffset = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(position: slideOffset, child: child),
    );
  }

  static Widget _buildLayout(
    Widget? currentChild,
    List<Widget> previousChildren,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[...previousChildren, ?currentChild],
    );
  }
}
