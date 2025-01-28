import 'package:flutter/material.dart';

class LoadingPageRoute extends PageRouteBuilder {
  final Widget page;
  
  LoadingPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return Stack(
              children: [
                FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                FadeTransition(
                  opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
                    ),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        );
}
