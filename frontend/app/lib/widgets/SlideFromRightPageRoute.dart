import 'package:flutter/material.dart';

class SlideFromRightPageRoute extends PageRouteBuilder {
  final Widget widget;

  SlideFromRightPageRoute({required this.widget})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) {
            final size = MediaQuery.of(context).size;
            final width = size.width / 3;
            final height = size.height;

            return Scaffold(
              body: Container(
                width: width,
                height: height,
                child: widget,
              ),
            );
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final size = MediaQuery.of(context).size;
            final width = size.width / 3;

            const begin = Offset(1.0, 0.0); 
            final end = Offset((size.width - width) / size.width, 0.0); // End at the position where the page covers one-third of the screen
            const curve = Curves.ease;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}
