import 'package:flutter/material.dart';
import 'package:swat/OnlineComplainForum/OnlineComplainForum.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Using a Future.delayed to navigate to the second page after 2 seconds
    Future.delayed(Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        CustomPageRoute(child: OnlineComplainForum()), // Use CustomPageRoute
      );
    });

    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.white,
          height: 150,
          child: Image.asset(
            "assets/images/logo.jpeg",
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}

class CustomPageRoute extends PageRouteBuilder {
  final Widget child;

  CustomPageRoute({required this.child})
      : super(
          transitionDuration: Duration(seconds: 1),
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
}
