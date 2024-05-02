import 'dart:io';

import 'package:cloi/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import '../../color.dart';

class infoPage extends StatefulWidget {
  const infoPage({super.key});

  @override
  State<infoPage> createState() => _infoPageState();
}

class _infoPageState extends State<infoPage> {
  File? _image;
  final picker = ImagePicker();
  String? uploadedImageUrl; // Add this line to hold the uploaded image URL

  Future<UploadTask> uploadImage(File imageFile) {
    String fileName = imageFile.path.split('/').last;
    Reference storageRef =
        FirebaseStorage.instance.ref().child('uploads/$fileName');
    UploadTask uploadTask = storageRef.putFile(imageFile);
    return Future.value(uploadTask); // Return the UploadTask
  }

  void showUploadProgressDialog(BuildContext context, UploadTask uploadTask) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black, // Set background color to black
          title: Text('Uploading Image',
              style: TextStyle(color: Colors.white)), // Text color to white
          content: StreamBuilder<TaskSnapshot>(
            stream: uploadTask.snapshotEvents,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final progress = (snapshot.data!.bytesTransferred /
                        snapshot.data!.totalBytes) *
                    100;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(
                      value: progress / 100,
                      backgroundColor:
                          Colors.grey, // Background color of the loader
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.red), // Loader color to red
                    ),
                    SizedBox(height: 20),
                    Text('${progress.toStringAsFixed(2)} %',
                        style: TextStyle(
                            color: Colors.white)), // Text color to white
                  ],
                );
              } else {
                return SizedBox(
                  height: 100,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.red), // Loader color to red
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  Future<void> saveImageUrlToFirestore(String imageUrl) async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .set({
      'storeLogo': imageUrl, // Save the image URL
    }, SetOptions(merge: true));
  }

  Future getImage() async {
    setState(() => _isLoading = true);
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      UploadTask uploadTask = await uploadImage(_image!);

      showUploadProgressDialog(
          context, uploadTask); // Show upload progress dialog

      final snapshot = await uploadTask;
      final imageUrl = await snapshot.ref.getDownloadURL();

      await saveImageUrlToFirestore(imageUrl); // Save URL to Firestore

      // Close the progress dialog and bottom sheet (if open)
      Navigator.of(context).pop();

      setState(() {
        uploadedImageUrl = imageUrl; // Update the uploaded image URL
        // Check if bottom sheet is currently displayed
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(); // Close the bottom sheet
        }
        _showBottomSheet(
            context); // Reopen the bottom sheet with updated content
      });
    } else {
      print('No image selected.');
    }

    setState(() => _isLoading = false);
  }

  void _showBottomSheet(BuildContext context) {
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
            height: h * 0.33,
            width: w * 0.95,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              child: Container(
                color: Colors.black, // Set the desired background color
                // Your bottom sheet UI goes here
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: h * 0.05,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Your Desired\n',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: w * 0.065,
                                      color: AppColors.primaryColor),
                                ),
                                TextSpan(
                                  text: 'App Name',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: w * 0.065,
                                      color: AppColors.secondaryColor),
                                ),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: ' APP',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: w * 0.04,
                                      color: AppColors.primaryColor),
                                ),
                                TextSpan(
                                  text: ' ICON',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: w * 0.04,
                                      color: AppColors.secondaryColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: h * 0.01,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: AppColors.fourthtextColor,
                            border: Border.all(
                              color: AppColors.secondaryColor,
                              width: 0.3,
                            ),
                          ),
                          width: w * 0.54,
                          child: Padding(
                            padding: EdgeInsets.only(left: w * 0.03),
                            child: TextField(
                              controller: storeNameController,
                              style: TextStyle(
                                fontSize: w * 0.05,
                                color: AppColors
                                    .thirdtextColor, // Set the text color to your primary color
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: ' Eg Amazon | Flipkart',
                                hintStyle: TextStyle(
                                    color: AppColors.secondarytextColor,
                                    fontSize: w * 0.05,
                                    fontWeight: FontWeight.w300),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: w * 0.02,
                        ),
                        GestureDetector(
                          onTap: getImage,
                          child: Container(
                            width: w * 0.17,
                            height: w * 0.17,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryColor,
                                width: 0.5,
                              ),
                              color: Colors.transparent,
                            ),
                            child: Center(
                              child: uploadedImageUrl != null
                                  ? ClipOval(
                                      child: Image.network(
                                        uploadedImageUrl!,
                                        width: w * 0.17,
                                        height: w * 0.17,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : (_image != null
                                      ? ClipOval(
                                          child: Image.file(
                                            _image!,
                                            width: w * 0.17,
                                            height: w * 0.17,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Lottie.asset(
                                          'assets/logo.json',
                                          width: w * 0.1,
                                          height: w * 0.1,
                                        )),
                            ),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Container(
                        width: w * 0.7,
                        height: h * 0.07,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(10), // small curve
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            if (businessNameController.text.isNotEmpty &&
                                storeNameController.text.isNotEmpty &&
                                businessAddressController.text.isNotEmpty &&
                                phoneNumberController.text.isNotEmpty) {
                              // Assuming 'users' is the collection in Firestore where user data is stored
                              String currentUserId =
                                  FirebaseAuth.instance.currentUser!.uid;

                              // Save the data to Firestore under the current user's document
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(currentUserId)
                                  .set({
                                'storeName': storeNameController.text,
                                'address': businessAddressController.text,
                                'name': businessNameController.text,
                                'phone': phoneNumberController.text,
                                'loginCompleted': true,
                                // Add more fields as needed
                                // For example, store the image URL if the image is uploaded to storage
                              }, SetOptions(merge: true));

                              Navigator.pushNamedAndRemoveUntil(
                                  context, 'sucessPage', (route) => false);
                            } else {
                              Fluttertoast.showToast(
                                msg: "Store Name is Empty",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            }
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

  AuthServices authServices = AuthServices();
  bool _isLoading = true;

  Future<void> _checkLocationPermissionAndSignIn() async {
    setState(() {
      _isLoading = true;
    });

    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      await authServices.signInWithGoogle(context);
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

  TextEditingController businessNameController = TextEditingController();
  TextEditingController businessAddressController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController storeNameController = TextEditingController();

  String address = ''; // Define a variable to store the address
  String name = '';
  String phone = '';
  String storeName = '';

  String? _name;
  String? storeLogoUrl;

  @override
  void initState() {
    super.initState();
    fetchAddress(); // Fetch the address when the widget initializes
  }

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
        storeName = userDoc['storeName'] ?? '';
        storeLogoUrl = userDoc['storeLogo']; // Fetching the store logo URL
      });

      // Populate text field controllers with fetched values
      businessNameController.text = name;
      businessAddressController.text = address;
      phoneNumberController.text = phone;
      storeNameController.text = storeName;

      // Assuming 'phoneNumber' is the field name in the Firestore document
      phoneNumberController.text = userDoc['phoneNumber'] ?? '';
    } catch (e) {
      print('Error fetching address: $e');
      setState(() {
        address = 'Address not found';
        name = 'name not found';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;

    void _showToast() {
      Fluttertoast.showToast(
        msg: 'Please fill in all the details.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1.0)),
      child: Scaffold(
        body: SafeArea(
            child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: h * 0.04,
                        ),
                        Container(
                          width: w * 0.6,
                          height: h * 0.085,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.07),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(6),
                              bottomRight: Radius.circular(6),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.thirdtextColor,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: w * 0.08),
                                child: Text(
                                  'Provide Valid',
                                  style: GoogleFonts.inter(
                                    color: AppColors.secondaryColor,
                                    fontSize: w * 0.045,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: w * 0.08),
                                child: Text(
                                  'Business Details below',
                                  style: GoogleFonts.inter(
                                    color: AppColors.primaryColor,
                                    fontSize: w * 0.04,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: h * 0.02,
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: w * 0.08, right: w * 0.08),
                          child: TextField(
                            controller: businessNameController,
                            style: TextStyle(
                              fontSize: w * 0.04,
                              color: AppColors
                                  .thirdtextColor, // Set the text color to your primary color
                            ),
                            decoration: InputDecoration(
                              labelText: 'Business Name',
                              labelStyle: TextStyle(
                                color: AppColors.secondarytextColor,
                                fontSize: w * 0.045,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: h * 0.04,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: w * 0.08,
                          ),
                          child: Text("Business Address",
                              style: GoogleFonts.inter(
                                color: AppColors.secondarytextColor,
                                fontSize: w * 0.037,
                              )),
                        ),
                        SizedBox(
                          height: h * 0.0085,
                        ),
                        Center(
                          child: Container(
                            width: w * 0.84,
                            height: h * 0.18,
                            decoration: BoxDecoration(
                              color: AppColors.fourthtextColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.secondaryColor,
                                width: 0.3,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: TextField(
                                controller: businessAddressController,
                                maxLines: 5,
                                style: TextStyle(
                                  fontSize: w * 0.04,
                                  color: AppColors
                                      .thirdtextColor, // Set the text color to your primary color
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintMaxLines: 5,
                                  hintText: 'Business Address',
                                  hintStyle: TextStyle(
                                      color: AppColors.secondarytextColor,
                                      fontSize: w * 0.045,
                                      fontWeight: FontWeight.w300),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: h * 0.02,
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: w * 0.08, right: w * 0.08),
                          child: TextField(
                            controller: phoneNumberController,
                            maxLength: 10,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              fontSize: w * 0.04,
                              color: AppColors
                                  .thirdtextColor, // Set the text color to your primary color
                            ),
                            decoration: InputDecoration(
                              prefixText: '+91',
                              labelText: 'Business Phone Number',
                              labelStyle: TextStyle(
                                color: AppColors.secondarytextColor,
                                fontSize: w * 0.045,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Lottie.asset(
                              'assets/world.json', // Replace with your Lottie animation file path
                              width: w * 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: h * 0.2,
                      color: AppColors.secondaryColor,
                      child: Column(children: [
                        Padding(
                          padding: EdgeInsets.all(30.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: h * 0.01,
                              ),
                              Center(
                                child: Text(
                                  "Provide Valid Details Above Will be stored in Store",
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w300,
                                      color: AppColors.primaryColor,
                                      fontSize: w * 0.03),
                                ),
                              ),
                              SizedBox(
                                height: h * 0.015,
                              ),
                              Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                    width: w * 0.85,
                                    height: h * 0.08,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          10), // small curve
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (businessNameController
                                                .text.isNotEmpty &&
                                            businessAddressController
                                                .text.isNotEmpty &&
                                            phoneNumberController
                                                .text.isNotEmpty) {
                                          _showBottomSheet(context);
                                        } else {}
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary:
                                            Colors.black, // background color
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10), // small curve
                                        ),
                                      ),
                                      child: Text(
                                        'Continue',
                                        style: GoogleFonts.inter(
                                          color: AppColors.primaryColor,
                                          fontSize: w * 0.055,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        )
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            height: 100, // Adjust as needed
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Lottie.asset('assets/loading.json'), // Your Lottie file
                Text("Loading..."),
              ],
            ),
          ),
        );
      },
    );
  }
}
