import 'package:flutter/widgets.dart';

/// Double-tap guard for navigation.
///
/// `Navigator.push` / `pop` update the route stack synchronously, so a second
/// tap delivered before the transition starts finds its route no longer on
/// top. Navigation handlers bail out when [isTopRoute] is false: no second
/// push of the same screen, no second pop removing the screen underneath.
extension RouteGuard on BuildContext {
  bool get isTopRoute => ModalRoute.of(this)?.isCurrent ?? true;
}
