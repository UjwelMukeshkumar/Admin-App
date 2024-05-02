import 'dart:io';
import 'dart:ui';

import 'package:cloi/color.dart';
import 'package:cloi/pages/products/productAdd.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

class catagoriePage extends StatefulWidget {
  @override
  _catagoriePageState createState() => _catagoriePageState();
}

class _catagoriePageState extends State<catagoriePage> {
  final Stream<QuerySnapshot> products =
      FirebaseFirestore.instance.collection('catagorie').snapshots();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  late String currentUserId = '';

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid; // Assign the current user's UID
      });
    }
  }

  void deleteDocument(String docId) {
    FirebaseFirestore.instance
        .collection('catagorie') // Corrected to 'catagorie' collection
        .doc(docId)
        .delete()
        .then((_) {
      print('Document successfully deleted!');
      Fluttertoast.showToast(
        msg: "Category deleted successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }).catchError((error) {
      print('Error deleting document: $error');
      Fluttertoast.showToast(
        msg: "Error deleting category",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    });
  }

  void _showBottomSheetDelete(BuildContext context, String docId) {
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
            height: h * 0.25,
            width: w * 0.95,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black87.withOpacity(0.9),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: h * 0.04,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Confirm ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: w * 0.075,
                                      color: AppColors.primaryColor),
                                ),
                                TextSpan(
                                  text: 'Delete',
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
                      height: h * 0.005,
                    ),
                    Center(
                      child: Text(
                        'Are you sure you want to delete this item?',
                        style: TextStyle(
                            fontSize: w * 0.03,
                            fontWeight: FontWeight.w300,
                            color: AppColors.secondarytextColor),
                      ),
                    ),
                    SizedBox(
                      height: h * 0.02,
                    ),
                    Center(
                      child: Container(
                          width: w * 0.6,
                          child: Image.asset('assets/line.png')),
                    ),
                    SizedBox(
                      height: h * 0.04,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: h * 0.05,
                          width: w * 0.3,
                          child: TextButton(
                            style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  AppColors.secondaryColor),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  AppColors.secondaryColor),
                            ),
                            child: Text(
                              'Yes',
                              style: TextStyle(
                                  fontSize: w * 0.05,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryColor),
                            ),
                            onPressed: () {
                              deleteDocument(
                                  docId); // Use the passed docId for deletion
                              Navigator.of(context)
                                  .pop(); // Close the bottom sheet
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: w * 0.03, right: 0.2),
                          child: Container(
                            height: h * 0.05,
                            child: TextButton(
                              style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        AppColors.primaryColor),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        AppColors.primaryColor),
                              ),
                              child: Text(
                                'No',
                                style: TextStyle(
                                    fontSize: w * 0.05,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.thirdtextColor),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: h * 0.02,
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
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1.0)),
      child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(25.0),
                      child: TextField(
                        style: TextStyle(
                            color: AppColors
                                .secondaryColor // Set text color to white
                            ),
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: "Search Catagorie",
                          hintText: "Enter Catagorie",
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.secondaryColor,
                          ),
                          labelStyle: TextStyle(
                            color:
                                Colors.white, // Set label text color to white
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppColors.cardColor), // White border
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppColors
                                    .secondarytextColor), // White border when focused
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: AppColors.cardColor),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                                context, 'productPage', (route) => false);
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromARGB(255, 0, 0, 0)
                                          .withOpacity(0.1),
                                      spreadRadius: 2,
                                      blurRadius: 1,
                                      offset: Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ]),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, top: 5, bottom: 5),
                                child: Text(
                                  "My Products",
                                ),
                              )),
                        ),
                        SizedBox(
                          width: w * 0.03,
                        ),
                        Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                color: AppColors.secondaryColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromARGB(255, 0, 0, 0)
                                        .withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 1,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ]),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 25, right: 25, top: 5, bottom: 5),
                              child: Text(
                                "Catagorie",
                                style: TextStyle(color: AppColors.primaryColor),
                              ),
                            )),
                      ],
                    ),
                    SizedBox(
                      height: h * 0.02,
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('catagorie')
                            .where('uid', isEqualTo: currentUserId)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          // Check for errors
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }

                          // Show a loader while waiting for data
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                                child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ));
                          }

                          // After data is retrieved, check if it's empty
                          if (snapshot.data?.docs.isEmpty ?? true) {
                            return Center(
                                child: Text("No catagorie available"));
                          }

                          return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var catagorie = snapshot.data!.docs[index].data()
                                  as Map<String, dynamic>;
                              String catagorieName =
                                  catagorie['catagorieName'] ?? '';
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    'catagorieEdit',
                                    arguments: {
                                      'data': catagorie,
                                      'catagorieName': catagorie[
                                          'catagorieName'], // Include images data here
                                      'catagoriePhoto':
                                          catagorie['catagoriePhoto'],
                                      'images': catagorie[
                                          'images'], // Include images data here
                                      'uid': catagorie['uid'],
                                      'id': snapshot.data!.docs[index].id,
                                      // Include images data here

                                      // Pass the document ID as an argument
                                    },
                                  );
                                },
                                child: ListTile(
                                  title: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.07),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              const Color.fromARGB(255, 0, 0, 0)
                                                  .withOpacity(0.1),
                                          spreadRadius: 2,
                                          blurRadius: 1,
                                          offset: Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.white.withOpacity(
                                            0.08), // replace with your desired border color
                                        width:
                                            0.5, // replace with your desired border width
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(7),
                                            child: Container(
                                              width: w * 0.2,
                                              height: w * 0.2,
                                              decoration: BoxDecoration(
                                                color: AppColors
                                                    .fourthtextColor, // Set the desired background color
                                                // Set the desired background color
                                              ),
                                              child: catagorie[
                                                              'catagoriePhoto'] !=
                                                          null &&
                                                      catagorie[
                                                              'catagoriePhoto']
                                                          .isNotEmpty
                                                  ? Image.network(
                                                      catagorie[
                                                          'catagoriePhoto'],
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Image.asset(
                                                      'assets/default.png', // Path to your local asset image
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            catagorie['catagorieName'] ??
                                                'Unnamed Category',
                                            style: TextStyle(
                                                color: AppColors.primaryColor),
                                          ),
                                        ),
                                        Spacer(),
                                        InkWell(
                                          onTap: () {
                                            String docId = snapshot
                                                .data!
                                                .docs[index]
                                                .id; // Get the document ID
                                            if (catagorieName != 'All') {
                                              _showBottomSheetDelete(context,
                                                  docId); // Pass docId to the function
                                            }
                                          },
                                          child: Container(
                                            width: w * 0.12,
                                            child: catagorieName != 'All'
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withOpacity(0.06),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                10), // small curve
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Lottie.asset(
                                                            'assets/delete.json'),
                                                      ),
                                                    ),
                                                  )
                                                : null,
                                          ),
                                        ),

                                        SizedBox(width: w * 0.04)
                                        // Edit button
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: h * 0.09,
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                top: 30,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context, 'menuPage',
                      // arguments: {}
                    );
                  },
                  child: Container(
                    height: h * 0.1,
                    child: Image.asset('assets/close2.png'),
                  ),
                ),
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
                        width: w * 0.6,
                        height: h * 0.08,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(10), // small curve
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            //het
                            _showBottomSheet(context);
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
                              Text(
                                'Add Catagorie',
                                style: GoogleFonts.inter(
                                  color: AppColors.thirdtextColor,
                                  fontSize: w * 0.05,
                                ),
                              ),
                              SizedBox(
                                width: w * 0.02,
                              ),
                              SizedBox(
                                  width: w * 0.05,
                                  child: Image.asset('assets/icon1.png')),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: w * 0.18,
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
                            primary: Color(0xFFF80000),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10), // small curve
                            ),
                          ),
                          child: Container(
                            width: w * 0.055,
                            child: Image.asset('assets/icon2.png'),
                          ), // replace with your asset path
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

  Future<void> selectAndUploadImage() async {
    // Select an image
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    String imageUrl;

    if (image != null) {
      File imageFile = File(image.path);

      // Upload image
      UploadTask uploadTask = uploadImage(imageFile);
      final TaskSnapshot downloadUrl = await uploadTask;
      imageUrl = await downloadUrl.ref.getDownloadURL();
    } else {
      // Use the default image URL if no image is selected
      imageUrl =
          'https://firebasestorage.googleapis.com/v0/b/cloi-d6e0b.appspot.com/o/uploads%2F1000000272.png?alt=media&token=c2ba9aee-4595-4190-a3ad-f9d99a729d03';
    }

    setState(() {
      catagoriePhoto = imageUrl; // Set the image URL
    });

    // Save imageUrl to Firestore (your existing Firestore saving logic here)
  }

  UploadTask uploadImage(File imageFile) {
    String fileName = imageFile.path.split('/').last;
    Reference storageRef =
        FirebaseStorage.instance.ref().child('uploads/$fileName');
    UploadTask uploadTask = storageRef.putFile(imageFile);
    return uploadTask; // Directly return the UploadTask
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

  String catagorieName = '';
  TextEditingController catagorieNameController = TextEditingController();
  String? catagoriePhoto;

  Future<void> fetchAddress() async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('catagorie')
          .doc(currentUserId)
          .get();

      setState(() {
        catagorieName = userDoc['catagorieName'] ?? '';
        catagoriePhoto = userDoc['catagoriePhoto'] ?? '';
      });
    } catch (e) {
      print('Error fetching address: $e');
      setState(() {
        catagorieName = 'catagorie not found';
      });
    }
  }

  Future<void> saveImageUrlToFirestore(String imageUrl) async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .set({
      'catagoriePhoto': imageUrl, // Save the image URL
    }, SetOptions(merge: true));
  }

  File? _image;
  final picker = ImagePicker();
  String? uploadedImageUrl; // Add this line to hold the uploaded image URL
  bool _isLoading = true;

  Future getImage() async {
    setState(() => _isLoading = true);
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      UploadTask uploadTask = uploadImage(_image!);

      showUploadProgressDialog(
          context, uploadTask); // Show upload progress dialog

      final snapshot = await uploadTask.whenComplete(() {});
      final imageUrl = await snapshot.ref.getDownloadURL();

      await saveImageUrlToFirestore(imageUrl); // Save URL to Firestore

      Navigator.of(context).pop(); // Close the progress dialog

      setState(() {
        uploadedImageUrl = imageUrl; // Update the uploaded image URL
        catagoriePhoto =
            imageUrl; // Update the catagoriePhoto with new image URL
      });

      // Close the bottom sheet if it's open and reopen with updated content
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // Close the bottom sheet if it's open
      }
      // ignore: use_build_context_synchronously
      _showBottomSheet(context);
    } else {
      print('No image selected.');
      setState(() => _isLoading = false);
    }
  }

  void _showBottomSheet(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
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
                color: AppColors.cardColor, // Set the desired background color
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
                                  text: 'Your Catagorie\n',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: w * 0.065,
                                      color: AppColors.primaryColor),
                                ),
                                TextSpan(
                                  text: 'Name Below',
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
                                  text: ' ADD',
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
                              controller: catagorieNameController,
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
                              child: catagoriePhoto != null &&
                                      catagoriePhoto!.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        catagoriePhoto!,
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
                          onPressed: () async {
                            if (catagorieNameController.text.isNotEmpty) {
                              try {
                                // Check if an image URL is available, otherwise use the default image URL
                                String imageUrlToSave = uploadedImageUrl ??
                                    'https://firebasestorage.googleapis.com/v0/b/cloi-d6e0b.appspot.com/o/uploads%2F1000000272.png?alt=media&token=c2ba9aee-4595-4190-a3ad-f9d99a729d03';

                                // Save the category information along with the image URL to Firebase
                                await FirebaseFirestore.instance
                                    .collection('catagorie')
                                    .add({
                                  'catagorieName': catagorieNameController.text,
                                  'uid': FirebaseAuth.instance.currentUser!.uid,
                                  'catagoriePhoto':
                                      imageUrlToSave, // use imageUrlToSave here
                                });

                                Fluttertoast.showToast(
                                  msg: "Category added successfully",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );

                                Navigator.pop(
                                    context); // Close the bottom sheet
                                catagorieNameController
                                    .clear(); // Clear the text field for next input
                              } catch (e) {
                                print("Error adding category: $e");
                                Fluttertoast.showToast(
                                  msg: "Error adding category",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                              }
                            } else {
                              Fluttertoast.showToast(
                                msg: "Category name is empty",
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
}
