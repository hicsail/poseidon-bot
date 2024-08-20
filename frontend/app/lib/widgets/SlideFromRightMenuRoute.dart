import 'package:flutter/material.dart';

class SlideFromRightMenuRoute extends PageRouteBuilder {
  final Widget menuWidget;

  SlideFromRightMenuRoute({required this.menuWidget})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) {
            final size = MediaQuery.of(context).size;
            final width = size.width / 3;

            return Stack(
              children: [
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: width,
                  child: menuWidget,
                ),
              ],
            );
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            final end = Offset(0.0, 0.0);
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}
