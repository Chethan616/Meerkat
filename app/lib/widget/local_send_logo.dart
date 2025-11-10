import 'package:flutter/material.dart';
import 'package:localsend_app/gen/assets.gen.dart';
import 'package:lottie/lottie.dart';

class LocalSendLogo extends StatelessWidget {
  final bool withText;

  const LocalSendLogo({required this.withText});

  @override
  Widget build(BuildContext context) {
    final logo = SizedBox(
      width: 200,
      height: 200,
      child: Lottie.asset(
        'assets/img/meerkat-animation.json',
        width: 200,
        height: 200,
        fit: BoxFit.contain,
        repeat: true,
        animate: true,
        // Enable hardware acceleration for better gradient rendering
        options: LottieOptions(
          enableMergePaths: true,
        ),
      ),
    );

    if (withText) {
      return Column(
        children: [
          logo,
          const Text(
            'Meerkat',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      return logo;
    }
  }
}
