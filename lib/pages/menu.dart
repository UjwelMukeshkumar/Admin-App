import 'dart:io';
import 'dart:ui';

import 'package:cloi/color.dart';
import 'package:cloi/pages/products/productAdd.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:share/share.dart';

import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';

class menuPage extends StatefulWidget {
  @override
  _menuPageState createState() => _menuPageState();
}

class _menuPageState extends State<menuPage> {
  final Stream<QuerySnapshot> products =
      FirebaseFirestore.instance.collection('products').snapshots();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  File? _image;
  final picker = ImagePicker();
  String? uploadedImageUrl; // Add this line to hold the uploaded image URL

  late String currentUserId; // Variable to hold current user ID

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    fetchAddress();
    fetchDispatchTime(); // Fetch the address when the widget initializes
  }

  void getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid; // Assign the current user's UID
      });
    }
  }

  void fetchDispatchTime() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      setState(() {
        selectedDispatchTime =
            userDoc['shippingDetails'] ?? 'Same Day Dispatch';
        selectedPayment = address = userDoc['paymentMethod'] ?? 'COD';
        razorpayKeyController =
            TextEditingController(text: userDoc['paymentkey']);
      });
    } catch (e) {
      print('Error fetching dispatch time: $e');
      setState(() {
        selectedDispatchTime =
            'Same Day Dispatch'; // Default value if fetch fails
        selectedPayment = 'COD';
      });
    }
  }

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

      Navigator.of(context).pop(); // Close the progress dialog

      setState(() {
        uploadedImageUrl = imageUrl; // Update the uploaded image URL
        storeLogoUrl = imageUrl; // Update the storeLogoUrl with new image URL
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(); // Close the bottom sheet if it's open
        }
        _showBottomSheet(
            context); // Reopen the bottom sheet with updated content
      });
    } else {
      print('No image selected.');
    }

    setState(() => _isLoading = false);
  }

  bool _isLoading = true;
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
                color: Colors.black87, // Set the desired background color
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
                              child: storeLogoUrl != null &&
                                      storeLogoUrl!.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        storeLogoUrl!,
                                        width: w * 0.17,
                                        height: w * 0.17,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Lottie.asset(
                                      'assets/logo.json',
                                      width: w * 0.1,
                                      height: w * 0.1,
                                    ),
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

                                // Add more fields as needed
                                // For example, store the image URL if the image is uploaded to storage
                              }, SetOptions(merge: true));

                              Navigator.pop(context);
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

  void _showBottomSheetextracharge(BuildContext context) {
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
                color: Colors.black87, // Set the desired background color
                // Your bottom sheet UI goes here
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: h * 0.05,
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: w * 0.17),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'Extra ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: w * 0.075,
                                        color: AppColors.primaryColor),
                                  ),
                                  TextSpan(
                                    text: 'Charge',
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
                      height: h * 0.03,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Extra Shipping \n',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: w * 0.04,
                                    color: AppColors.primaryColor),
                              ),
                              TextSpan(
                                text: 'Charge',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: w * 0.04,
                                    color: AppColors.secondaryColor),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: w * 0.02,
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
                          width: w * 0.34,
                          child: Padding(
                            padding: EdgeInsets.only(left: w * 0.03),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              controller: extraChargeController,
                              style: TextStyle(
                                fontSize: w * 0.05,
                                color: AppColors
                                    .thirdtextColor, // Set the text color to your primary color
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '   Rs 500',
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
                      height: h * 0.001,
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
                            String currentUserId =
                                FirebaseAuth.instance.currentUser!.uid;
                            int extraChargeValue =
                                int.tryParse(extraChargeController.text) ?? 0;

                            // Save the data to Firestore under the current user's document
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(currentUserId)
                                .set({
                              'extraCharge': extraChargeValue,
                              // Add more fields as needed
                              // For example, store the image URL if the image is uploaded to storage
                            }, SetOptions(merge: true));
                            Navigator.pushNamedAndRemoveUntil(
                                context, 'menuPage', (route) => false);
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

  String selectedDispatchTime = '';

  void _showBottomSheetdipatchTime(BuildContext context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          final h = MediaQuery.of(context).size.height;
          final w = MediaQuery.of(context).size.width;

          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            // Your code here

            // Add a return statement at the end
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                color: Colors.transparent,
                height: h * 0.44,
                width: w * 0.95,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                  child: Container(
                    color:
                        AppColors.cardColor, // Set the desired background color
                    // Your bottom sheet UI goes here
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            top: h * 0.05,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'Dispatch ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: w * 0.075,
                                          color: AppColors.primaryColor),
                                    ),
                                    TextSpan(
                                      text: 'Time',
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
                        SizedBox(
                          height: h * 0.03,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: w * 0.01),
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'Select an Option ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: w * 0.03,
                                        color: AppColors.primaryColor),
                                  ),
                                  TextSpan(
                                    text: 'Below',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: w * 0.03,
                                        color: AppColors.secondaryColor),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: h * 0.02,
                            ),
                            GestureDetector(
                              onTap: () => setState(() {
                                selectedDispatchTime = 'Same Day Dispatch';
                              }),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: AppColors.thirdtextColor,
                                  border: Border.all(
                                    color: selectedDispatchTime ==
                                            'Same Day Dispatch'
                                        ? Colors.red
                                        : AppColors.cardColor,
                                    width: 0.8,
                                  ),
                                ),
                                width: w * 0.81,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text(
                                      'Same Day Dispatch',
                                      style: TextStyle(
                                        fontSize: w * 0.045,
                                        color: AppColors
                                            .primaryColor, // Set the text color to your primary color
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: h * 0.01,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: w * 0.04,
                                ),
                                GestureDetector(
                                  onTap: () => setState(() {
                                    selectedDispatchTime = '1 to 2 Days';
                                  }),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: AppColors.thirdtextColor,
                                      border: Border.all(
                                        color: selectedDispatchTime ==
                                                '1 to 2 Days'
                                            ? Colors.red
                                            : AppColors.cardColor,
                                        width: 0.25,
                                      ),
                                    ),
                                    width: w * 0.25,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Text(
                                          '1 to 2 Days',
                                          style: TextStyle(
                                            fontSize: w * 0.038,
                                            color: AppColors
                                                .primaryColor, // Set the text color to your primary color
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: w * 0.02,
                                ),
                                GestureDetector(
                                  onTap: () => setState(() {
                                    selectedDispatchTime = '2 to 3 Days';
                                  }),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: AppColors.thirdtextColor,
                                      border: Border.all(
                                        color: selectedDispatchTime ==
                                                '2 to 3 Days'
                                            ? Colors.red
                                            : AppColors.cardColor,
                                        width: 0.26,
                                      ),
                                    ),
                                    width: w * 0.26,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Text(
                                          '2 to 3 Days',
                                          style: TextStyle(
                                            fontSize: w * 0.038,
                                            color: AppColors
                                                .primaryColor, // Set the text color to your primary color
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: w * 0.02,
                                ),
                                GestureDetector(
                                  onTap: () => setState(() {
                                    selectedDispatchTime = '3 to 5 Days';
                                  }),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: AppColors.thirdtextColor,
                                      border: Border.all(
                                        color: selectedDispatchTime ==
                                                '3 to 5 Days'
                                            ? Colors.red
                                            : AppColors.cardColor,
                                        width: 0.26,
                                      ),
                                    ),
                                    width: w * 0.26,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Text(
                                          '3 to 5 Days',
                                          style: TextStyle(
                                            fontSize: w * 0.038,
                                            color: AppColors
                                                .primaryColor, // Set the text color to your primary color
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: w * 0.04,
                                ),
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: h * 0.02,
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
                                String currentUserId =
                                    FirebaseAuth.instance.currentUser!.uid;

                                // Save the data to Firestore under the current user's document
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(currentUserId)
                                    .set({
                                  'shippingDetails': selectedDispatchTime,

                                  // Add more fields as needed
                                  // For example, store the image URL if the image is uploaded to storage
                                }, SetOptions(merge: true));
                                Navigator.pushNamedAndRemoveUntil(
                                    context, 'menuPage', (route) => false);
                              },
                              style: ElevatedButton.styleFrom(
                                primary: AppColors
                                    .secondaryColor, // background color
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
            // Replace 'Container()' with the appropriate Widget
          });
        });
  }

  String selectedPayment = '';
  TextEditingController razorpayKeyController = TextEditingController();

  void _showBottomSheetpayment(BuildContext context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          final h = MediaQuery.of(context).size.height;
          final w = MediaQuery.of(context).size.width;

          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            // Your code here

            // Add a return statement at the end
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                color: Colors.transparent,
                height: h * 0.43,
                width: w * 0.95,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                  child: Container(
                    color: Colors.black87, // Set the desired background color
                    // Your bottom sheet UI goes here
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            top: h * 0.05,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'Payment ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: w * 0.075,
                                          color: AppColors.primaryColor),
                                    ),
                                    TextSpan(
                                      text: 'Method',
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
                        SizedBox(
                          height: h * 0.03,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: w * 0.01),
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // RichText(
                            //   text: TextSpan(
                            //     children: <TextSpan>[
                            //       TextSpan(
                            //         text: 'Select an Option ',
                            //         style: TextStyle(
                            //             fontWeight: FontWeight.w500,
                            //             fontSize: w * 0.03,
                            //             color: AppColors.primaryColor),
                            //       ),
                            //       TextSpan(
                            //         text: 'Below',
                            //         style: TextStyle(
                            //             fontWeight: FontWeight.w500,
                            //             fontSize: w * 0.03,
                            //             color: AppColors.secondaryColor),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            SizedBox(
                              height: h * 0.01,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: w * 0.04,
                                ),
                                GestureDetector(
                                  onTap: () => setState(() {
                                    selectedPayment = 'COD';
                                  }),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: AppColors.thirdtextColor,
                                      border: Border.all(
                                        color: selectedPayment == 'COD'
                                            ? AppColors.secondaryColor
                                            : AppColors.cardColor,
                                        width: 0.25,
                                      ),
                                    ),
                                    width: w * 0.25,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Text(
                                          'COD',
                                          style: TextStyle(
                                            fontSize: w * 0.045,
                                            color: AppColors
                                                .primaryColor, // Set the text color to your primary color
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: w * 0.02,
                                ),
                                GestureDetector(
                                  onTap: () => setState(() {
                                    selectedPayment = 'Razorpay';
                                  }),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: AppColors.thirdtextColor,
                                      border: Border.all(
                                        color: selectedPayment == 'Razorpay'
                                            ? Colors.red
                                            : AppColors.cardColor,
                                        width: 0.26,
                                      ),
                                    ),
                                    width: w * 0.26,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Text(
                                          'Razorpay',
                                          style: TextStyle(
                                            fontSize: w * 0.045,
                                            color: AppColors
                                                .primaryColor, // Set the text color to your primary color
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: w * 0.02,
                                ),
                                GestureDetector(
                                  onTap: () => setState(() {
                                    selectedPayment = 'Paytm';
                                  }),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: AppColors.thirdtextColor,
                                      border: Border.all(
                                        color: selectedPayment == 'Paytm'
                                            ? Colors.red
                                            : AppColors.cardColor,
                                        width: 0.26,
                                      ),
                                    ),
                                    width: w * 0.26,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Text(
                                          'Paytm',
                                          style: TextStyle(
                                            fontSize: w * 0.045,
                                            color: AppColors
                                                .primaryColor, // Set the text color to your primary color
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: w * 0.04,
                                ),
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: h * 0.02,
                        ),
                        if (selectedPayment == 'Razorpay')
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 25, vertical: 8),
                            child: TextField(
                              style: TextStyle(
                                  color: AppColors
                                      .secondaryColor // Set text color to white
                                  ),
                              controller: razorpayKeyController,
                              decoration: InputDecoration(
                                labelText: 'Razorpay Key',
                                labelStyle: TextStyle(
                                  color: Colors
                                      .white, // Set label text color to white
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Colors.white), // White border
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Colors
                                          .white), // White border when focused
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        if (selectedPayment == 'COD')
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'Activate ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: w * 0.03,
                                        color: AppColors.primaryColor),
                                  ),
                                  TextSpan(
                                    text: 'Cash on Delivery',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: w * 0.03,
                                        color: AppColors.secondaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (selectedPayment == 'Paytm')
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text: '    \n\n Paytm ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: w * 0.055,
                                        color: AppColors.primaryColor),
                                  ),
                                  TextSpan(
                                    text: 'ComingSoon',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: w * 0.055,
                                        color: AppColors.secondaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        SizedBox(
                          height: h * 0.01,
                        ),
                        if (selectedPayment != 'Paytm')
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
                                  if (selectedPayment == 'Razorpay' &&
                                      razorpayKeyController.text.isEmpty) {
                                    Fluttertoast.showToast(
                                      msg: "Please enter Razorpay key",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0,
                                    );
                                    return;
                                  }
                                  String currentUserId =
                                      FirebaseAuth.instance.currentUser!.uid;
                                  FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(currentUserId)
                                      .set({
                                    'paymentMethod': selectedPayment,
                                    // If Razorpay is selected, also save the key
                                    if (selectedPayment == 'Razorpay')
                                      'paymentkey': razorpayKeyController.text,
                                  }, SetOptions(merge: true)).then((_) {
                                    Fluttertoast.showToast(
                                      msg: "Payment method updated",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.green,
                                      textColor: Colors.white,
                                      fontSize: 16.0,
                                    );
                                    Navigator.of(context).pop();
                                  }).catchError((error) {
                                    Fluttertoast.showToast(
                                      msg:
                                          "Error updating payment method: $error",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0,
                                    );
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: AppColors
                                      .secondaryColor, // background color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        100), // small curve
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
            // Replace 'Container()' with the appropriate Widget
          });
        });
  }

  void _showBottomSheethelp(BuildContext context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          final h = MediaQuery.of(context).size.height;
          final w = MediaQuery.of(context).size.width;

          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            // Your code here

            // Add a return statement at the end
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                color: Colors.transparent,
                height: h * 0.13,
                width: w * 0.95,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                  child: Container(
                    color: Colors.black87, // Set the desired background color
                    // Your bottom sheet UI goes here
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            top: h * 0.05,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.message,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                onPressed: () => launch(
                                  'https://wa.me/+91 77364 86790?text=${Uri.encodeFull('help regarding openstore')}',
                                ),
                              ),
                              SizedBox(width: 20),
                              IconButton(
                                icon: Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                onPressed: () {
                                  launch("tel:77364 86790");
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
            // Replace 'Container()' with the appropriate Widget
          });
        });
  }

  TextEditingController businessNameController = TextEditingController();
  TextEditingController businessAddressController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController storeNameController = TextEditingController();
  TextEditingController extraChargeController = TextEditingController();

  // Other variables to store user information
  String address = '';
  String name = '';
  String phone = '';
  String storeName = '';
  String? storeLogoUrl;

  Future<void> fetchAddress() async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      if (userDoc.exists) {
        setState(() {
          name = userDoc.get('name') ?? '';
          address = userDoc.get('address') ?? '';
          phone = userDoc.get('phone') ?? '';
          storeName = userDoc.get('storeName') ?? '';
          storeLogoUrl = userDoc.get('storeLogo');

          // Handling extraCharge as int
          int extraChargeValue = userDoc.get('extraCharge') as int? ?? 0;
          extraChargeController.text = extraChargeValue.toString();
        });

        // Populate text field controllers with fetched values
        businessNameController.text = name;
        businessAddressController.text = address;
        phoneNumberController.text = phone;
        storeNameController.text = storeName;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      // Handle the error, maybe show a message to the user
    }
  }

// Function to launch WhatsApp
  Future<void> _launchWhatsApp(String phoneNumber, String message) async {
    final String url =
        'https://wa.me/$phoneNumber?text=${Uri.encodeFull(message)}';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(
        msg: 'Could not launch $url',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunch(launchUri.toString())) {
      await launch(launchUri.toString());
    } else {
      Fluttertoast.showToast(
        msg: 'Could not launch ${launchUri.toString()}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      // Handle the error or inform the user that the phone call can't be made
    }
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
          body: Stack(
            children: [
              SafeArea(
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
                                height: h * 0.06,
                              ),
                              Container(
                                width: w * 0.75,
                                height: h * 0.085,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.07),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(6),
                                    bottomRight: Radius.circular(6),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black,
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
                                        'Store Settings &',
                                        style: GoogleFonts.inter(
                                          color: AppColors.secondaryColor,
                                          fontSize: w * 0.045,
                                          fontWeight: FontWeight.w400,
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
                              GestureDetector(
                                onTap: () {
                                  _showBottomSheetpayment(context);
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: w * 0.05, bottom: h * 0.01),
                                  child: Container(
                                    width: w * 0.7,
                                    child: Image.asset('assets/menu1.png',
                                        fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _showBottomSheetdipatchTime(context);
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: w * 0.05, bottom: h * 0.01),
                                  child: Container(
                                    width: w * 0.7,
                                    child: Image.asset('assets/menu2.png',
                                        fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _showBottomSheetextracharge(context);
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: w * 0.05, bottom: h * 0.01),
                                  child: Container(
                                    width: w * 0.7,
                                    child: Image.asset('assets/menu3.png',
                                        fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _showBottomSheethelp(context);
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: w * 0.05, bottom: h * 0.01),
                                  child: Container(
                                    width: w * 0.7,
                                    child: Image.asset('assets/menu4.png',
                                        fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _showBottomSheet(context);
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: w * 0.05, bottom: h * 0.01),
                                  child: Container(
                                    width: w * 0.7,
                                    child: Image.asset('assets/menu5.png',
                                        fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: w * 0.08,
                                    right: w * 0.08,
                                    top: h * 0.02),
                                child: Center(
                                    child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/redline.png',
                                    ),
                                    SizedBox(
                                      height: h * 0.02,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Fluttertoast.showToast(
                                          msg: 'Catalogue Available soon',
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          backgroundColor:
                                              Colors.black.withOpacity(0.2),
                                          textColor: Colors.white,
                                        );
                                      },
                                      child: Container(
                                        width: w * 0.6,
                                        child: Image.asset(
                                          'assets/menu6.png',
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: h * 0.02,
                                    ),
                                    Image.asset(
                                      'assets/redline.png',
                                    ),
                                  ],
                                )),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: h * 0.060,
                          ),
                          Stack(
                            children: [
                              GestureDetector(
                                child: Center(
                                  child: Lottie.asset(
                                    'assets/menu.json', // Replace with your Lottie animation file path
                                    width: w * 0.45,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: h * 0.18,
                                left: w * 0.25,
                                child: RichText(
                                  // Text widget with multiple styles
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Version',
                                        style: GoogleFonts.inter(
                                          color: AppColors.primaryColor,
                                          fontSize: w * 0.045,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '1.01',
                                        style: GoogleFonts.inter(
                                          color: AppColors.secondaryColor,
                                          fontSize: w * 0.045,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' (we are in beta)',
                                        style: GoogleFonts.inter(
                                          color: AppColors.primaryColor,
                                          fontSize: w * 0.025,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              )),
              Positioned(
                right: 0,
                top: 30,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, 'productPage', (route) => false);
                  },
                  child: Container(
                    height: h * 0.127,
                    child: Image.asset('assets/CLOSE.png'),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: h * 0.16,
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
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => _copyToClipboard(currentUserId),
                            child: Container(
                              width: w * 0.50,
                              height: h * 0.04,
                              decoration: BoxDecoration(
                                color: AppColors.secondaryColor,
                                borderRadius:
                                    BorderRadius.circular(100), // small curve
                              ),
                              child: Container(
                                width: w * 0.55,
                                height: h * 0.04,
                                decoration: BoxDecoration(
                                  color: AppColors
                                      .secondaryColor, // Assuming this is a visible color
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Copy',
                                        style: GoogleFonts.inter(
                                          color: Colors
                                              .black, // Ensure this color is visible
                                          fontSize: w * 0.040,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Shimmer.fromColors(
                                        baseColor: AppColors
                                            .primaryColor!, // Replace with your desired base color
                                        highlightColor:
                                            AppColors.secondaryColor!,
                                        child: Text(
                                          ' Secret Code',
                                          style: GoogleFonts.inter(
                                            color: Colors
                                                .black, // Ensure this color is visible
                                            fontSize: w * 0.040,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: h * 0.02,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                            width: w * 0.78,
                            height: h * 0.09,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(10), // small curve
                            ),
                            child: ElevatedButton(
                              // onPressed: () {
                              //   Fluttertoast.showToast(
                              //     msg: 'Not Available in beta Release!',
                              //     toastLength: Toast.LENGTH_SHORT,
                              //     gravity: ToastGravity.BOTTOM,
                              //     backgroundColor: Colors.grey[800],
                              //     textColor: Colors.white,
                              //   );
                              // },
                              onPressed: () =>
                                  shareFileFromAssets('assets/trial.apk'),

                              style: ElevatedButton.styleFrom(
                                primary: Colors.white, // background color
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10), // small curve
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Download Now',
                                        style: GoogleFonts.inter(
                                          color: AppColors.thirdtextColor,
                                          fontSize: w * 0.055,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: ' Your APK is ready to be ',
                                              style: GoogleFonts.inter(
                                                color: AppColors.thirdtextColor,
                                                fontSize: w * 0.023,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            TextSpan(
                                              text: 'Downloaded Now',
                                              style: GoogleFonts.inter(
                                                color: AppColors.secondaryColor,
                                                fontSize: w * 0.023,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  SizedBox(width: w * 0.045),
                                  Lottie.asset(
                                    'assets/phone.json', // Replace with your Lottie animation file path
                                    width: 50,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Future<void> shareFileFromAssets(String assetPath) async {
    try {
      final ByteData bytes = await rootBundle.load(assetPath);
      final Uint8List list = bytes.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/trial.apk').create();
      file.writeAsBytesSync(list);

      Share.shareFiles([file.path], text: 'Check out this APK!');
    } catch (e) {
      print('Error sharing file: $e');
    }
  }

  void _copyToClipboard(String textToCopy) {
    Clipboard.setData(ClipboardData(text: textToCopy)).then((_) {
      Fluttertoast.showToast(
        msg: 'Secret Code Copied to Clipboard',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    });
  }

  void deleteDocument(String docId) {
    FirebaseFirestore.instance
        .collection('products')
        .doc(docId)
        .delete()
        .then((_) {
      print('Document successfully deleted!');
    }).catchError((error) {
      print('Error deleting document: $error');
    });
  }
}
