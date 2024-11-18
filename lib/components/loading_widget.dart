import 'package:flutter/material.dart';
import "package:lottie/lottie.dart";

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/animation/KOQk61hFr3.json',
        width: 350, 
        height: 350, 
        fit: BoxFit.contain, 
      ),
    );
  }
}

    