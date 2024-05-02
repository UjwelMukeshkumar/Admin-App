import 'package:cloi/auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../color.dart';

class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  AuthServices authServices = AuthServices();
  bool _isLoading = true;
  bool _isNoInternetToastShown = false;

  Future<void> _checkLocationPermissionAndSignIn() async {
    setState(() {
      _isLoading = true;
    });

    // Check network connectivity
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      if (!_isNoInternetToastShown) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No internet connection available.')),
        );
        _isNoInternetToastShown =
            true; // Set the flag to true after showing toast
      }
      setState(() {
        _isLoading = false;
      });
      return; // Exit the function if there's no internet
    } else {
      _isNoInternetToastShown =
          false; // Reset the flag if internet is available
    }

    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.whileInUse) {
      await authServices.signInWithGoogle(context);

      final user = authServices.firebaseAuth.currentUser;

      // if (user != null) {
      //   Navigator.pushNamedAndRemoveUntil(
      //       context, 'productPage', (route) => false);
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //         content: Text('Failed to sign in. Please try again later.')),
      //   );
      // }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Location permission is required to proceed.')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;

    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1.0)),
      child: Scaffold(
        backgroundColor: AppColors.thirdtextColor,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: h * 0.07,
              ),
              Spacer(),
              Spacer(),
              Spacer(),
              Spacer(),
              Spacer(),
              RichText(
                text: TextSpan(
                  text: 'Open ',
                  style: GoogleFonts.mochiyPopOne(
                    color: AppColors.secondarytextColor,
                    fontSize: w * 0.1,
                    fontWeight: FontWeight.w500,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Store',
                        style: GoogleFonts.mochiyPopOne(
                          color: AppColors.primaryColor,
                          fontSize: w * 0.1,
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              ),
              SizedBox(
                height: h * 0.015,
              ),
              Text("The Ecom App Maker",
                  style: GoogleFonts.inter(
                    color: AppColors.secondarytextColor,
                    fontSize: w * 0.04,
                    fontWeight: FontWeight.w400,
                  )),
              Spacer(),
              Spacer(),
              Spacer(),
              Spacer(),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    width: w * 0.70,
                    height: h * 0.07,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), // small curve
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        _checkLocationPermissionAndSignIn();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white, // background color
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10), // small curve
                        ),
                      ),
                      child: FutureBuilder(
                        future: _checkLocationPermissionAndSignIn(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: 'Auto Sign ',
                                    style: GoogleFonts.inter(
                                      color: AppColors.secondaryColor,
                                      fontSize: w * 0.04,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: 'In with Google',
                                          style: GoogleFonts.inter(
                                            color: AppColors.thirdtextColor,
                                            fontSize: w * 0.04,
                                            fontWeight: FontWeight.w500,
                                          )),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: w * 0.04,
                                ),
                                Container(
                                  width: w * 0.045,
                                  height: h * 0.02,
                                  child: CircularProgressIndicator(
                                    color: Colors
                                        .red, // Set the color of the progress indicator
                                    strokeWidth:
                                        3.0, // Set the width of the progress indicator
                                    backgroundColor: AppColors
                                        .secondaryColor, // Set the background color of the progress indicator
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.thirdtextColor,
                                    ), // Set the color of the progress indicator's value
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Text(
                              '',
                              style: GoogleFonts.inter(
                                color: AppColors.primaryColor,
                                fontSize: w * 0.05,
                                fontWeight: FontWeight.w300,
                              ),
                            );
                          }
                        },
                      ),
                    )),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
