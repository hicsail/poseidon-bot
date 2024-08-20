import 'package:flutter/material.dart';

class SlideFromRightMenuRoute extends PageRouteBuilder {
  final Widget menuWidget;

  SlideFromRightMenuRoute({required this.menuWidget})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) {
            final size = MediaQuery.of(context).size;
            final width = size.width / 3;
            final height = size.height;

            return Scaffold(
              body: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: Colors.transparent, // Background color of main content
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: width,
                      height: height,
                      child: menuWidget,
                    ),
                  ),
                ],
              ),
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
