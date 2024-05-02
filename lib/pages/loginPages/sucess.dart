import 'package:cloi/color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lottie/lottie.dart';

class sucessPage extends StatefulWidget {
  const sucessPage({super.key});

  @override
  State<sucessPage> createState() => _sucessPageState();
}

class _sucessPageState extends State<sucessPage> {
  @override
  void initState() {
    super.initState();

    // Delay the navigation by 4 seconds
    Future.delayed(const Duration(seconds: 10), () {
      Navigator.pushNamedAndRemoveUntil(
          context, 'productPage', (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Scaffold(
        backgroundColor: AppColors.thirdtextColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(),
            Spacer(),
            Spacer(),
            Spacer(),
            Spacer(),
            Spacer(),
            Spacer(),
            Spacer(),
            Spacer(),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.asset(
                  'assets/logo.png', // Replace with the path to your image asset
                  width: w * 0.63, // Set the desired width of the image
                ),
              ],
            ),
            Center(
              child: SizedBox(
                width: w * 0.9, // Set the desired width of the container
                // Set the desired height of the container
                // Container background color
                child: Lottie.asset(
                  'assets/load.json', // Replace with the path to your Lottie animation
                ),
              ),
            ),
            Spacer(),
            Spacer(),
            Spacer(),
            Center(
              child: Text(
                "Your E-commerce App ",
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: w * 0.055,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: h * 0.01,
            ),
            Center(
              child: Text(
                "Building process Started",
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    color: AppColors.secondaryColor,
                    fontSize: w * 0.04,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
            Center(
              child: Lottie.asset(
                'assets/loading.json', // Replace with your Lottie animation file path
                width: 100,
              ),
            ),
            Spacer(),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
