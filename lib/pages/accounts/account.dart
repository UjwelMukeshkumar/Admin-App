import 'package:cloi/auth.dart';
import 'package:cloi/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class accountPage extends StatefulWidget {
  @override
  _accountPageState createState() => _accountPageState();
}

class _accountPageState extends State<accountPage> {
  String address = ''; // Define a variable to store the address
  String name = ''; // Define a variable to store the address
  String phone = '';
  @override
  void initState() {
    super.initState();
    fetchAddress(); // Fetch the address when the widget initializes
  }

  TextEditingController businessNameController = TextEditingController();
  TextEditingController businessAddressController = TextEditingController();
  TextEditingController businessPhoneController = TextEditingController();
  String? _name;

  Future<void> fetchAddress() async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      setState(() {
        name = userDoc['name'] ?? '';
        address = userDoc['address'] ?? '';
        phone = userDoc['phone'] ?? '';
      });

      // Populate text field controllers with fetched values
      businessNameController.text = name;
      businessAddressController.text = address;
      businessPhoneController.text = phone;

      // Assuming 'phoneNumber' is the field name in the Firestore document
    } catch (e) {
      print('Error fetching address: $e');
      setState(() {
        address = 'Address not found';
        name = 'name not found';
      });
    }
  }

  void _showBottomSheetaddress(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        final h = MediaQuery.of(context).size.height;
        final w = MediaQuery.of(context).size.width;

        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            color: Colors.transparent,
            height: h * 0.63,
            width: w * 0.95,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              child: Container(
                color: AppColors.cardColor, // Set the desired background color
                // Your bottom sheet UI goes here
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: h * 0.05,
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: w * 0.14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'Business \n',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: w * 0.075,
                                        color: AppColors.primaryColor),
                                  ),
                                  TextSpan(
                                    text: 'Address here',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: w * 0.075,
                                        color: AppColors.secondaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: h * 0.02,
                    ),
                    Center(
                      child: Container(
                        width: w * 0.6,
                        child: Image.asset(
                          'assets/line.png',
                        ),
                      ),
                    ),
                    SizedBox(
                      height: h * 0.02,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: w * 0.03,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: AppColors.fourthtextColor,
                            border: Border.all(
                              color: AppColors.secondaryColor,
                              width: 0.3,
                            ),
                          ),
                          width: w * 0.68,
                          child: Padding(
                            padding: EdgeInsets.only(left: w * 0.03),
                            child: TextField(
                              keyboardType: TextInputType.streetAddress,
                              controller: businessNameController,
                              style: TextStyle(
                                fontSize: w * 0.05,
                                color: AppColors
                                    .thirdtextColor, // Set the text color to your primary color
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '   Business Name here',
                                hintStyle: TextStyle(
                                    color: AppColors.secondarytextColor,
                                    fontSize: w * 0.05,
                                    fontWeight: FontWeight.w300),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: h * 0.01,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: AppColors.fourthtextColor,
                            border: Border.all(
                              color: AppColors.secondaryColor,
                              width: 0.3,
                            ),
                          ),
                          width: w * 0.68,
                          child: Padding(
                            padding: EdgeInsets.only(left: w * 0.03),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              controller: businessPhoneController,
                              style: TextStyle(
                                fontSize: w * 0.05,
                                color: AppColors
                                    .thirdtextColor, // Set the text color to your primary color
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '   Support Phone here',
                                hintStyle: TextStyle(
                                    color: AppColors.secondarytextColor,
                                    fontSize: w * 0.05,
                                    fontWeight: FontWeight.w300),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: h * 0.01,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: AppColors.fourthtextColor,
                            border: Border.all(
                              color: AppColors.secondaryColor,
                              width: 0.3,
                            ),
                          ),
                          width: w * 0.68,
                          child: Padding(
                            padding: EdgeInsets.only(left: w * 0.03),
                            child: TextField(
                              maxLines: 4,
                              keyboardType: TextInputType.streetAddress,
                              controller: businessAddressController,
                              style: TextStyle(
                                fontSize: w * 0.05,
                                color: AppColors
                                    .thirdtextColor, // Set the text color to your primary color
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '   Address here',
                                hintMaxLines: 4,
                                hintStyle: TextStyle(
                                    color: AppColors.secondarytextColor,
                                    fontSize: w * 0.05,
                                    fontWeight: FontWeight.w300),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: h * 0.02,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        width: w * 0.7,
                        height: h * 0.07,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(10), // small curve
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            String currentUserId =
                                FirebaseAuth.instance.currentUser!.uid;

                            // Save the data to Firestore under the current user's document
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(currentUserId)
                                .set({
                              'address': businessAddressController.text,
                              'name': businessNameController.text,
                              'phone': businessPhoneController.text,
                              // Add more fields as needed
                              // For example, store the image URL if the image is uploaded to storage
                            }, SetOptions(merge: true));
                            Navigator.pushNamedAndRemoveUntil(
                                context, 'accountPage', (route) => false);
                          },
                          style: ElevatedButton.styleFrom(
                            primary:
                                AppColors.secondaryColor, // background color
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(100), // small curve
                            ),
                          ),
                          child: Text(
                            'Confirm',
                            style: GoogleFonts.inter(
                              color: AppColors.primaryColor,
                              fontSize: w * 0.05,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;
    AuthServices authServices = AuthServices();
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1.0)),
      child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              SafeArea(
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          'appPage',
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        child: Center(
                          child: Image.asset(
                            'assets/swipe.png',
                            width: w * 1,
                            height: h * 0.1,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: h * 0.04,
                    ),
                    Container(
                      width: w * 0.6,
                      height: h * 0.055,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(6),
                          bottomRight: Radius.circular(6),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondaryColor,
                          ),
                        ],
                      ),
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '| ',
                                style: GoogleFonts.inter(
                                  color: AppColors.thirdtextColor,
                                  fontSize: w * 0.045,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: 'My Account Info',
                                style: GoogleFonts.inter(
                                  color: AppColors.primaryColor,
                                  fontSize: w * 0.045,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: h * 0.015,
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: w * 0.12),
                        child: Row(
                          children: [
                            Container(
                              width: w * 0.5,
                              child: Text(
                                name,
                                style: GoogleFonts.inter(
                                  color: AppColors.primaryColor,
                                  fontSize: w * 0.04,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: w * 0.01,
                            ),
                            GestureDetector(
                              onTap: () {
                                _showBottomSheetaddress(context);
                              },
                              child: Padding(
                                padding: EdgeInsets.only(left: w * 0.12),
                                child: Container(
                                  width: w * 0.12,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: EdgeInsets.all(10),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: w * 0.01,
                            ),
                          ],
                        )),
                    SizedBox(
                      height: h * 0.01,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: w * 0.12),
                      child: Container(
                        width: w * 0.65,
                        child: Text(
                          phone,
                          style: GoogleFonts.inter(
                            color: AppColors.secondaryColor,
                            fontSize: w * 0.04,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: h * 0.005,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: w * 0.12),
                      child: Container(
                        width: w * 0.65,
                        child: Text(
                          address,
                          style: GoogleFonts.inter(
                            color: AppColors.secondarytextColor,
                            fontSize: w * 0.04,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: h * 0.02,
                    ),
                    Center(
                      child: Container(
                          width: w * 0.75,
                          child: Image.asset('assets/line.png')),
                    ),
                    SizedBox(
                      height: h * 0.02,
                    ),
                    InkWell(
                      onTap: () async {
                        await authServices.signOutOfGoogle(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.only(left: w * 0.12),
                        child: Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'SignOut',
                                    style: GoogleFonts.inter(
                                      color: AppColors.primaryColor,
                                      fontSize: w * 0.05,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' Now',
                                    style: GoogleFonts.inter(
                                      color: AppColors.secondaryColor,
                                      fontSize: w * 0.05,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: w * 0.02,
                            ),
                            SizedBox(
                                width: w * 0.05,
                                child: Image.asset('assets/icon6.png')),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: h * 0.04,
                    ),
                    GestureDetector(
                      onTap: () {
                        Fluttertoast.showToast(
                          msg: 'Feature will be available soon!',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.grey[800],
                          textColor: Colors.white,
                        );
                      },
                      child: Center(
                        child: Container(
                            width: w * 0.8,
                            child: Stack(
                              children: [
                                Image.asset(
                                  'assets/account2.png',
                                ),
                                Positioned(
                                  right: w * 0.03,
                                  top: h * 0.001,
                                  child: Center(
                                    child: Lottie.asset(
                                      'assets/bot.json', // Replace with your Lottie animation file path
                                      width: w * 0.2,
                                    ),
                                  ),
                                )
                              ],
                            )),
                      ),
                    ),
                    SizedBox(
                      height: h * 0.03,
                    ),
                    GestureDetector(
                      onTap: () => launch(
                        'https://wa.me/+91 77364 86790?text=${Uri.encodeFull('price regarding openstore')}',
                      ),
                      child: Center(
                        child: Container(
                          width: w * 0.45,
                          child: Image.asset(
                            'assets/account3.png',
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: h * 0.15,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.0), // fully transparent
                        Colors.black.withOpacity(1), // semi-transparent
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      const Spacer(),
                      const Spacer(),
                      const Spacer(),
                      Container(
                        width: w * 0.43,
                        height: h * 0.08,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(10), // small curve
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                                context, 'orderPage', (route) => false);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white, // background color
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10), // small curve
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                  width: w * 0.05,
                                  child: Image.asset('assets/icon5.png')),
                              SizedBox(
                                width: w * 0.02,
                              ),
                              // replace with your asset path
                              Text(
                                'To Orders',
                                style: GoogleFonts.inter(
                                  // replace 'roboto' with your desired Google font
                                  color: AppColors.thirdtextColor,
                                  fontSize: w * 0.048,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: w * 0.43,
                        height: h * 0.08,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(10), // small curve
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                                context, 'productPage', (route) => false);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFFF80000),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10), // small curve
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              // replace with your asset path
                              Text(
                                'Products',
                                style: GoogleFonts.inter(
                                  // replace 'roboto' with your desired Google font
                                  color: AppColors.primaryColor,
                                  fontSize: w * 0.05,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              SizedBox(
                                width: w * 0.02,
                              ),
                              SizedBox(
                                  width: w * 0.05,
                                  child: Image.asset('assets/icon2.png')),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Spacer(),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
