import 'dart:ui';

import 'package:cloi/color.dart';
import 'package:cloi/pages/products/productAdd.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class productPage extends StatefulWidget {
  @override
  _productPageState createState() => _productPageState();
}

class _productPageState extends State<productPage> {
  final Stream<QuerySnapshot> products =
      FirebaseFirestore.instance.collection('products').snapshots();
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
                          labelText: " Search Product Here",
                          hintText: "Enter product name",
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
                                    left: 20, right: 20, top: 5, bottom: 5),
                                child: Text(
                                  "My Products",
                                  style:
                                      TextStyle(color: AppColors.primaryColor),
                                ),
                              )),
                        ),
                        SizedBox(
                          width: w * 0.03,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                                context, 'catagorie', (route) => false);
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
                                    left: 25, right: 25, top: 5, bottom: 5),
                                child: Text("Catagorie"),
                              )),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: h * 0.02,
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('products')
                            .where('user_id', isEqualTo: currentUserId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                                child: CircularProgressIndicator(
                                    color: AppColors.primaryColor));
                          }

                          if (!snapshot.hasData || snapshot.data == null) {
                            return Text("No products available");
                          }

                          var filteredDocs = snapshot.data!.docs.where((doc) {
                            Map<String, dynamic> data =
                                doc.data() as Map<String, dynamic>;
                            String productName =
                                data['productName']?.toLowerCase() ?? '';
                            return productName.contains(searchQuery);
                          }).toList();

                          return Center(
                            child: ListView(
                              children: filteredDocs.isEmpty
                                  ? [
                                      Container(
                                        height: h * 0.5,
                                        child: Center(
                                          child: Text(
                                            'Add products from below',
                                            style: TextStyle(
                                                color: AppColors
                                                    .secondarytextColor),
                                          ),
                                        ),
                                      )
                                    ]
                                  : filteredDocs
                                      .map((DocumentSnapshot document) {
                                      Map<String, dynamic> data = document
                                          .data() as Map<String, dynamic>;
                                      return ListTile(
                                        title: InkWell(
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              'productEdit',
                                              arguments: {
                                                'data': data,
                                                'docId': document.id,
                                                'images': data[
                                                    'images'], // Include images data here

                                                // Pass the document ID as an argument
                                              },
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withOpacity(0.07),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color.fromARGB(
                                                          255, 0, 0, 0)
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
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    children: [
                                                      if (data['images'] !=
                                                          null)
                                                        Container(
                                                          height: h * 0.13,
                                                          width: w * 0.27,
                                                          child:
                                                              ListView.builder(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            itemCount:
                                                                data['images']
                                                                    .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                  child:
                                                                      Container(
                                                                    height: h *
                                                                        0.13,
                                                                    width: w *
                                                                        0.245,
                                                                    child: Image
                                                                        .network(
                                                                      data['images']
                                                                          [
                                                                          index],
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      loadingBuilder: (BuildContext context,
                                                                          Widget
                                                                              child,
                                                                          ImageChunkEvent?
                                                                              loadingProgress) {
                                                                        if (loadingProgress ==
                                                                            null)
                                                                          return child;
                                                                        return Center(
                                                                          child:
                                                                              CircularProgressIndicator(
                                                                            color:
                                                                                AppColors.primaryColor,
                                                                            value: loadingProgress.expectedTotalBytes != null
                                                                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                                                : null,
                                                                          ),
                                                                        );
                                                                      },
                                                                      errorBuilder: (BuildContext context,
                                                                          Object
                                                                              exception,
                                                                          StackTrace?
                                                                              stackTrace) {
                                                                        return Image.asset(
                                                                            'assets/default.png',
                                                                            fit:
                                                                                BoxFit.cover);
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      if (data['images'] ==
                                                          null)
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(7),
                                                          child: SizedBox(
                                                            height: h * 0.13,
                                                            child: Image.asset(
                                                                'assets/default.png'),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: w * 0.025,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      child: SizedBox(
                                                        width: w * 0.4,
                                                        child: Text(
                                                          '${data['productName'] ?? 'No product name available'}',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                              color: AppColors
                                                                  .secondarytextColor,
                                                              fontSize:
                                                                  w * 0.052),
                                                        ),
                                                      ),
                                                    ),
                                                    SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      child: SizedBox(
                                                        width: w * 0.4,
                                                        height: h * 0.045,
                                                        child: Text(
                                                          '${data['description'] ?? 'No description available'}',
                                                          style: TextStyle(
                                                            fontSize: w * 0.03,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color: AppColors
                                                                .primarytextColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: h * 0.002,
                                                    ),
                                                    Text(
                                                      'Rs ${data['salePrice'] ?? '0.00'}/-',
                                                      style: TextStyle(
                                                          color: AppColors
                                                              .primaryColor),
                                                    ),
                                                    SizedBox(
                                                      height: h * 0.003,
                                                    ),
                                                    // Text('${data['qty'] ?? '-'}'),
                                                  ],
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      context: context,
                                                      builder: (context) {
                                                        final h = MediaQuery.of(
                                                                context)
                                                            .size
                                                            .height;
                                                        final w = MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width;

                                                        return Padding(
                                                          padding:
                                                              MediaQuery.of(
                                                                      context)
                                                                  .viewInsets,
                                                          child: Container(
                                                            color: Colors
                                                                .transparent,
                                                            height: h * 0.25,
                                                            width: w * 0.95,
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        20.0),
                                                                topRight: Radius
                                                                    .circular(
                                                                        20.0),
                                                              ),
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .black87
                                                                      .withOpacity(
                                                                          0.9),
                                                                ),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Padding(
                                                                      padding:
                                                                          EdgeInsets
                                                                              .only(
                                                                        top: h *
                                                                            0.04,
                                                                      ),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.end,
                                                                        children: [
                                                                          RichText(
                                                                            text:
                                                                                TextSpan(
                                                                              children: <TextSpan>[
                                                                                TextSpan(
                                                                                  text: 'Confirm ',
                                                                                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: w * 0.075, color: AppColors.primaryColor),
                                                                                ),
                                                                                TextSpan(
                                                                                  text: 'Delete',
                                                                                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: w * 0.075, color: AppColors.secondaryColor),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height: h *
                                                                          0.005,
                                                                    ),
                                                                    Center(
                                                                      child:
                                                                          Text(
                                                                        'Are you sure you want to delete this item?',
                                                                        style: TextStyle(
                                                                            fontSize: w *
                                                                                0.03,
                                                                            fontWeight:
                                                                                FontWeight.w300,
                                                                            color: AppColors.secondarytextColor),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height: h *
                                                                          0.02,
                                                                    ),
                                                                    Center(
                                                                      child: Container(
                                                                          width: w *
                                                                              0.6,
                                                                          child:
                                                                              Image.asset('assets/line.png')),
                                                                    ),
                                                                    SizedBox(
                                                                      height: h *
                                                                          0.04,
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: <Widget>[
                                                                        Container(
                                                                          height:
                                                                              h * 0.05,
                                                                          width:
                                                                              w * 0.3,
                                                                          child:
                                                                              TextButton(
                                                                            style:
                                                                                ButtonStyle(
                                                                              foregroundColor: MaterialStateProperty.all<Color>(AppColors.secondaryColor),
                                                                              backgroundColor: MaterialStateProperty.all<Color>(AppColors.secondaryColor),
                                                                            ),
                                                                            child:
                                                                                Text(
                                                                              'Yes',
                                                                              style: TextStyle(fontSize: w * 0.05, fontWeight: FontWeight.w600, color: AppColors.primaryColor),
                                                                            ),
                                                                            onPressed:
                                                                                () {
                                                                              deleteDocument(document.id);
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: EdgeInsets.only(
                                                                              left: w * 0.03,
                                                                              right: 0.2),
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                h * 0.05,
                                                                            child:
                                                                                TextButton(
                                                                              style: ButtonStyle(
                                                                                foregroundColor: MaterialStateProperty.all<Color>(AppColors.primaryColor),
                                                                                backgroundColor: MaterialStateProperty.all<Color>(AppColors.primaryColor),
                                                                              ),
                                                                              child: Text(
                                                                                'No',
                                                                                style: TextStyle(fontSize: w * 0.05, fontWeight: FontWeight.w600, color: AppColors.thirdtextColor),
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
                                                                      height: h *
                                                                          0.02,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Padding(
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
                                                      width: w * 0.1,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Lottie.asset(
                                                            'assets/delete.json'),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        // subtitle: Text('ID: ${document.id}'),
                                      );
                                    }).toList(),
                            ),
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
                    child: Image.asset('assets/menu.png'),
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
                            Navigator.pushNamed(
                              context, 'productAdd',
                              // arguments: {}
                            );
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
                                'Add Product',
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

  void deleteDocument(String docId) {
    FirebaseFirestore.instance
        .collection('products')
        .doc(docId)
        .delete()
        .then((_) async {
      // Identify the document for the "All" category
      QuerySnapshot allCategoryQuery = await FirebaseFirestore.instance
          .collection('catagorie')
          .where('catagorieName', isEqualTo: 'All')
          .get();

      if (allCategoryQuery.docs.isNotEmpty) {
        DocumentReference allCategoryRef =
            allCategoryQuery.docs.first.reference;

        // Remove the product ID from the 'productIds' array in the "All" category document
        allCategoryRef.update({
          'productIds': FieldValue.arrayRemove([docId])
        });
      }

      print(
          'Product and its reference in "All" category successfully deleted!');
    }).catchError((error) {
      print(
          'Error deleting product and its reference in "All" category: $error');
    });
  }
}
