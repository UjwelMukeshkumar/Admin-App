import 'package:cloi/color.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class appPage extends StatefulWidget {
  const appPage({super.key});

  @override
  State<appPage> createState() => _appPageState();
}

class _appPageState extends State<appPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/bot.json', // Replace with your Lottie animation file path
              ),
              Text(
                " App Editing Coming Soon",
                style: TextStyle(color: AppColors.primaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
