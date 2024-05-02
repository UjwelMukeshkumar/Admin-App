import 'dart:io';

import 'package:cloi/auth.dart';
import 'package:cloi/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class productAdd extends StatefulWidget {
  const productAdd({super.key});

  @override
  State<productAdd> createState() => _productAddState();
}

class _productAddState extends State<productAdd> {
  final CollectionReference products =
      FirebaseFirestore.instance.collection('products');

  TextEditingController ad_name = TextEditingController();
  TextEditingController qty = TextEditingController();
  TextEditingController mrp = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController description = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final List<String> _imageUrls = [];

  int imageCount = 0;

  Future<void> _pickImage() async {
    if (imageCount >= 5) {
      Fluttertoast.showToast(
        msg: "Maximum of 5 images can be uploaded",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return; // Limit image selection to 5 images
    }
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final Reference ref = FirebaseStorage.instance
          .ref()
          .child('products')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      UploadTask uploadTask = ref.putFile(File(image.path));

      // Show the upload progress dialog
      showUploadProgressDialog(context, uploadTask);

      final TaskSnapshot downloadUrl = await uploadTask;
      final String imageUrl = await downloadUrl.ref.getDownloadURL();

      Navigator.of(context).pop(); // Close the progress dialog

      setState(() {
        _imageUrls.add(imageUrl);
        imageCount++;
      });
    }
  }

  void showUploadProgressDialog(BuildContext context, UploadTask uploadTask) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text('Uploading Image', style: TextStyle(color: Colors.white)),
          content: StreamBuilder<TaskSnapshot>(
            stream: uploadTask.snapshotEvents,
            builder: (context, snapshot) {
              double progress = 0;
              if (snapshot.hasData) {
                progress =
                    snapshot.data!.bytesTransferred / snapshot.data!.totalBytes;
              }
              return LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              );
            },
          ),
        );
      },
    );
  }

  void _removeImage(int index) async {
    final String imageUrl = _imageUrls[index];
    final Reference storageRef = FirebaseStorage.instance.refFromURL(imageUrl);

    try {
      // Delete the image from Firebase Storage
      await storageRef.delete();

      setState(() {
        _imageUrls.removeAt(index);
        imageCount--;
      });
    } catch (e) {
      print('Error deleting image: $e');
      // Handle or display the error as needed
    }
  }

  late User user;

  Future<void> addProduct() async {
    // Validation Checks
    if (ad_name.text.isEmpty ||
        qty.text.isEmpty ||
        mrp.text.isEmpty ||
        price.text.isEmpty ||
        _imageUrls.isEmpty) {
      // Show an error message if any field is empty or no image is selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all fields and add at least one image."),
          backgroundColor: Colors.red,
        ),
      );
      return; // Return early if validation fails
    }

    try {
      AuthServices authServices = AuthServices();
      User? currentUser = authServices.firebaseAuth.currentUser;
      if (currentUser == null) {
        print('User not signed in');
        return;
      }

      final data = {
        'user_id': currentUser.uid,
        'name': currentUser.displayName ?? '',
        'photo': currentUser.photoURL ?? '',
        'productName': ad_name.text,
        'description': description.text,
        'mrp': int.parse(mrp.text),
        'salePrice': int.parse(price.text),
        'qty': int.parse(qty.text),
        'initialQty': int.parse(qty.text),
        'images': _imageUrls, // Include image URLs in the data
        'fav': [],
        'cart': [],
        'selectedUnit': _selectedUnit,
      };

      // Add the product to Firestore
      DocumentReference newProductRef =
          await FirebaseFirestore.instance.collection('products').add(data);

      // Find the "All" category document and update it
      QuerySnapshot allCategoryQuery = await FirebaseFirestore.instance
          .collection('catagorie')
          .where('catagorieName', isEqualTo: 'All')
          .where('uid',
              isEqualTo: currentUser
                  .uid) // Ensure the category belongs to the current user
          .get();

      if (allCategoryQuery.docs.isNotEmpty) {
        String allCategoryId =
            allCategoryQuery.docs.first.id; // ID of the "All" category document
        FirebaseFirestore.instance
            .collection('catagorie')
            .doc(allCategoryId)
            .update({
          'productIds': FieldValue.arrayUnion(
              [newProductRef.id]) // Append the new product ID
        });
      } else {
        print('No category named "All" found for the current user');
        // Optionally, create the "All" category here if it doesn't exist
      }
      // Clear the controllers and image URLs list after successful upload
      ad_name.clear();
      description.clear();
      mrp.clear();
      price.clear();
      qty.clear();
      _imageUrls.clear();
      imageCount = 0;

      // Optionally, navigate to the products page or show a success message
      Navigator.pushNamedAndRemoveUntil(
        context,
        'productPage',
        (route) => false,
      );
    } catch (e) {
      print('Error adding product: $e');
      // Handle errors appropriately
    }
  }

  String _selectedUnit = 'piece'; // Default selected unit
  final List<String> _units = ['L', 'Kg', 'ml', 'g', 'piece'];

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
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 1,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(
                          0.08), // replace with your desired border color
                      width: 0.5, // replace with your desired border width
                    ),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: _pickImage,
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Container(
                                    height: h * 0.22,
                                    width: w * 0.5,
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
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: h * 0.01,
                                        ),
                                        Container(
                                          height: h * 0.1,
                                          child: Image.asset(
                                            'assets/icon8.png',
                                          ),
                                        ),
                                        SizedBox(
                                          height: h * 0.008,
                                        ),
                                        Text(
                                          'PICK IMAGE',
                                          style: TextStyle(
                                              fontSize: w * 0.05,
                                              color:
                                                  AppColors.secondarytextColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: w * 0.03,
                              ),
                              Column(
                                children: [
                                  Text(
                                    '$imageCount',
                                    style: TextStyle(
                                        fontSize: w * 0.18,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.primaryColor),
                                  ),
                                  Text(
                                    'IMAGE',
                                    style: TextStyle(
                                        fontSize: w * 0.05,
                                        color: AppColors.primaryColor),
                                  ),
                                  Text(
                                    'SELECTED',
                                    style: TextStyle(
                                        fontSize: w * 0.05,
                                        color: AppColors.secondaryColor),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(children: [
                                Padding(
                                  padding: EdgeInsets.only(left: w * 0.025),
                                  child: Column(
                                    children: [
                                      _imageUrls.isEmpty
                                          ? Padding(
                                              padding: EdgeInsets.only(
                                                  top: h * 0.005),
                                              child: Text(
                                                'No Image Picked',
                                                style: TextStyle(
                                                  fontSize: w * 0.05,
                                                  color: AppColors.primaryColor,
                                                ),
                                              ),
                                            )
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                width: w * 0.86,
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                    children: _imageUrls
                                                        .asMap()
                                                        .entries
                                                        .map((entry) {
                                                      final int index =
                                                          entry.key;
                                                      final String imageUrl =
                                                          entry.value;

                                                      return GestureDetector(
                                                        onTap: () =>
                                                            _removeImage(index),
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            horizontal: 4.0,
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            child: Container(
                                                              width: w * 0.23,
                                                              height: h * 0.1,
                                                              child:
                                                                  Image.network(
                                                                imageUrl,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(w * 0.035),
                                  child: Container(
                                      width: w * 0.85,
                                      child: Image.asset('assets/line.png')),
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: w * 0.03,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(w * 0.03),
                                      child: Container(
                                        width: w * 0.55,
                                        child: TextField(
                                          controller: ad_name,
                                          style: TextStyle(
                                              fontSize: w * 0.05,
                                              color: AppColors.primaryColor),
                                          decoration: InputDecoration(
                                            hintText: 'ADD TITLE HERE',
                                            hintStyle: TextStyle(
                                                fontSize: w * 0.05,
                                                fontWeight: FontWeight.w300,
                                                color:
                                                    AppColors.primarytextColor),
                                            border: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.white.withOpacity(
                                                    0.08), // replace with your desired color
                                                width: 0.5,
                                              ),
                                            ),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.white.withOpacity(
                                                    0.08), // replace with your desired color
                                                width: 0.5,
                                              ),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.white.withOpacity(
                                                    0.08), // replace with your desired color
                                                width: 0.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(w * 0.03),
                                      child: Container(
                                        width: w * 0.2,
                                        child: TextField(
                                          controller: qty,
                                          style: TextStyle(
                                              fontSize: w * 0.05,
                                              color: AppColors.primaryColor),
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            hintText: 'QTY',
                                            suffixText: 'Qty',
                                            suffixStyle: TextStyle(
                                              fontSize: w * 0.038,
                                              color:
                                                  AppColors.secondarytextColor,
                                            ),
                                            hintStyle: TextStyle(
                                                fontSize: w * 0.05,
                                                fontWeight: FontWeight.w300,
                                                color:
                                                    AppColors.primarytextColor),
                                            border: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.white.withOpacity(
                                                    0.08), // replace with your desired color
                                                width: 0.5,
                                              ),
                                            ),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.white.withOpacity(
                                                    0.08), // replace with your desired color
                                                width: 0.5,
                                              ),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.white.withOpacity(
                                                    0.08), // replace with your desired color
                                                width: 0.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: w * 0.03,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: w * 0.03,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(w * 0.03),
                                      child: Container(
                                        width: w * 0.29,
                                        child: TextField(
                                          controller: mrp,
                                          style: TextStyle(
                                              fontSize: w * 0.05,
                                              color: AppColors.primaryColor),
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            prefixText: '₹ ',
                                            hintText: 'MRP',
                                            suffixText: 'MRP',
                                            hintStyle: TextStyle(
                                                fontSize: w * 0.037,
                                                fontWeight: FontWeight.w300,
                                                color:
                                                    AppColors.primarytextColor),
                                            border: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.white.withOpacity(
                                                    0.08), // replace with your desired color
                                                width: 0.5,
                                              ),
                                            ),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.white.withOpacity(
                                                    0.08), // replace with your desired color
                                                width: 0.5,
                                              ),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.white.withOpacity(
                                                    0.08), // replace with your desired color
                                                width: 0.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    DropdownButton<String>(
                                      value: _selectedUnit,
                                      icon: Icon(Icons.arrow_drop_down,
                                          color: AppColors
                                              .secondaryColor), // Change icon color if needed
                                      style: TextStyle(
                                          color: AppColors
                                              .primaryColor), // Text color for items
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedUnit = newValue!;
                                        });
                                      },
                                      dropdownColor: AppColors
                                          .thirdtextColor, // Set the background color of the open container
                                      items: _units
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(w * 0.03),
                                      child: Container(
                                        width: w * 0.29,
                                        child: TextField(
                                          controller: price,
                                          style: TextStyle(
                                              fontSize: w * 0.05,
                                              color: AppColors.primaryColor),
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            prefixText: '₹ ',
                                            hintText: ' OUR PRICE',
                                            suffixText: 'SALE',
                                            hintStyle: TextStyle(
                                                fontSize: w * 0.037,
                                                fontWeight: FontWeight.w300,
                                                color:
                                                    AppColors.primarytextColor),
                                            border: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.white.withOpacity(
                                                    0.08), // replace with your desired color
                                                width: 0.5,
                                              ),
                                            ),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.white.withOpacity(
                                                    0.08), // replace with your desired color
                                                width: 0.5,
                                              ),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.white.withOpacity(
                                                    0.08), // replace with your desired color
                                                width: 0.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: w * 0.03,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: h * 0.01,
                                ),
                                Container(
                                  width: w * 0.8,
                                  child: TextField(
                                    controller: description,
                                    maxLines: 8,
                                    style: TextStyle(
                                        fontSize: w * 0.05,
                                        color: AppColors.primaryColor),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppColors
                                          .cardColor, // Set the background color to grey
                                      hintText: 'DESCRIPTION',

                                      hintStyle: TextStyle(
                                          fontSize: w * 0.05,
                                          fontWeight: FontWeight.w300,
                                          color: AppColors
                                              .primarytextColor), // Placeholder text
                                      border: OutlineInputBorder(
                                        // Border appearance
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide:
                                            BorderSide.none, // No border side
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 16.0,
                                          horizontal:
                                              20.0), // Adjust padding as needed
                                    ),
                                    // Other properties or callbacks as needed
                                  ),
                                ),
                                SizedBox(
                                  height: h * 0.15,
                                ),
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 7, // Adjust the position as needed
                right: 7, // Adjust the position as needed
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        AppColors.secondaryColor, // Secondary color background
                    shape: BoxShape.circle, // Circular shape
                  ),
                  child: IconButton(
                    icon: Icon(Icons.close,
                        color: AppColors
                            .primaryColor), // Close icon with primary color
                    onPressed: () {
                      Navigator.of(context).pop(); // Go back to previous screen
                    },
                  ),
                ),
              ),
              Positioned(
                top: h * 0.84,
                left: w * 0.07,
                child: ElevatedButton(
                  onPressed: () async {
                    // Call the method to add product details
                    await addProduct();

                    // Navigator.pushNamedAndRemoveUntil(
                    //     context, 'productPage', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFFF80000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // small curve
                    ),
                    minimumSize: Size(w * 0.86,
                        h * 0.09), // set the width and height of the button
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // replace with your asset path
                      Text(
                        'Add Product',
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
            ],
          ),
        ),
      ),
    );
  }
}


// here


