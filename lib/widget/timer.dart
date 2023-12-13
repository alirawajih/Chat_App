import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Timer extends StatelessWidget {
  const Timer({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Duration>(
      duration: const Duration(minutes: 10),
      tween: Tween(begin: const Duration(minutes: 10), end: Duration.zero),
      onEnd: () async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        final email = prefs.getString('email');
        // FirebaseAuth.instance.currentUser!.delete();
        FirebaseAuth.instance.signOut();
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('sign out account ${email} delet from firebase '),
          ),
        );
      },
      builder: (BuildContext context, Duration value, Widget? child) {
        final minutes = value.inMinutes;
        final seconds = value.inSeconds % 60;
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text('$minutes:$seconds',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: seconds < 15 ? Colors.red : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)));
      },
    );
  }
}
