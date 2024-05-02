import 'package:cloi/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class catagorieEdit extends StatefulWidget {
  final Map<String, dynamic> data;
  final String uid;
  final String id;
  final String catagoriePhoto;

  const catagorieEdit({
    Key? key,
    required this.data,
    required this.uid,
    required this.catagoriePhoto,
    required this.id,
  }) : super(key: key);

  @override
  State<catagorieEdit> createState() => _catagorieEditState();
}

class _catagorieEditState extends State<catagorieEdit> {
  late String catagorieName;
  late List<dynamic> productIds;
  String? currentUserId; // Define currentUserId
  DocumentReference categoryRef =
      FirebaseFirestore.instance.collection('catagorie').doc();
  @override
  void initState() {
    super.initState();
    catagorieName = widget.data['catagorieName'] ?? '';
    productIds = widget.data['productIds'] ?? [];
    // printCategoryDocumentIds(); // Add this line

    getCurrentUser();
  }

  // void printCategoryDocumentIds() async {
  //   QuerySnapshot querySnapshot =
  //       await FirebaseFirestore.instance.collection('catagorie').get();
  //   List<String> documentIds = querySnapshot.docs.map((doc) => doc.id).toList();
  //   print(documentIds);
  // }

  Future<List<Map<String, dynamic>>> getProducts() async {
    List<Map<String, dynamic>> products = [];
    for (String id in productIds) {
      DocumentSnapshot productDoc =
          await FirebaseFirestore.instance.collection('products').doc(id).get();
      if (productDoc.exists) {
        products.add(productDoc.data() as Map<String, dynamic>);
      }
    }
    return products;
  }

  void getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid; // Assign the current user's UID
        // print(currentUserId);
      });
    }
  }

  List<String> selectedProductIds = []; // Store selected product IDs

  void updateCategory(List<String> selectedIds) async {
    try {
      DocumentReference categoryRef =
          FirebaseFirestore.instance.collection('catagorie').doc(widget.id);

      DocumentSnapshot categorySnapshot = await categoryRef.get();
      print(categoryRef);

      if (!categorySnapshot.exists) {
        // Document does not exist, create a new document
        await categoryRef.set({'productIds': selectedIds});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category created successfully!')),
        );
      } else {
        // Document exists, update it
        await categoryRef.update({'productIds': selectedIds});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Products updated successfully!')),
        );
      }

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating category: $e')),
      );
    }
  }

  void _showProductSelectionModal() async {
    List<String> selectedProductIds = [];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final h = MediaQuery.of(context).size.height;
        final w = MediaQuery.of(context).size.width;
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
                color: Colors.black87,
                child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('products')
                          .where('user_id', isEqualTo: currentUserId)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ));
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Text('No additional products available');
                        }

                        List<DocumentSnapshot> products = snapshot.data!.docs;

                        return Column(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(17.0),
                                child: ListView.builder(
                                  itemCount: products.length,
                                  itemBuilder: (context, index) {
                                    DocumentSnapshot product = products[index];

                                    return CheckboxListTile(
                                      title: Text(
                                        product['productName'] ?? 'No Name',
                                        style: TextStyle(
                                            color: AppColors.primaryColor),
                                      ),
                                      value: selectedProductIds
                                          .contains(product.id),
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            selectedProductIds.add(product.id);
                                          } else {
                                            selectedProductIds
                                                .remove(product.id);
                                          }
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                updateCategory(
                                    selectedProductIds); // Pass the selectedProductIds to updateCategory
                                Navigator.pop(context);
                              },
                              child: Text('Save Selected Products'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    // Handle the selected product IDs here (e.g., adding them to the category's product list)
    // ...
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor:
          AppColors.thirdtextColor, // Change this to your preferred color
      body: SafeArea(
          child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Name Display
                    Padding(
                      padding: EdgeInsets.all(18.0),
                      child: Text(
                        'Catagorie : ${catagorieName}',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondaryColor),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(w * 0.035),
                      child: Container(
                          width: w * 0.85,
                          child: Image.asset('assets/line.png')),
                    ),
                    // Product List
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: getProducts(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Text(
                              'No products found',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor),
                            ),
                          );
                        }
                        List<Map<String, dynamic>> products = snapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics:
                              NeverScrollableScrollPhysics(), // To prevent ListView from scrolling
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> product = products[index];
                            return Container(
                              height: h * 0.09,
                              child: ListTile(
                                title: Row(
                                  children: [
                                    Text(
                                      product['productName'] ?? 'No Name',
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryColor),
                                    ),
                                    Text(
                                      ' | ',
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.secondaryColor),
                                    ),
                                    Text(
                                      'Sale Price: ${product['salePrice']}',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w200,
                                          color: AppColors.primaryColor),
                                    ),
                                  ],
                                ),
                                subtitle: Text(
                                  'Qty: ${product['qty']}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w200,
                                      color: AppColors.primaryColor),
                                ),
                                // Add other details you want to display
                              ),
                            );
                          },
                        );
                      },
                    ),

                    // Button to Add More Products
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: h * 0.84,
            left: w * 0.07,
            child: catagorieName.toLowerCase() == 'all'
                ? ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Go back to previous screen
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 255, 255, 255),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(w * 0.86, h * 0.09),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Close',
                          style: GoogleFonts.inter(
                            color: AppColors.thirdtextColor,
                            fontSize: w * 0.05,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        SizedBox(width: w * 0.02),
                        SizedBox(
                            width: w * 0.05,
                            child: Image.asset('assets/icon1.png')),
                      ],
                    ),
                  )
                : ElevatedButton(
                    onPressed: () async {
                      _showProductSelectionModal();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFF80000),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(w * 0.86, h * 0.09),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Add More Products',
                          style: GoogleFonts.inter(
                            color: AppColors.primaryColor,
                            fontSize: w * 0.05,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        SizedBox(width: w * 0.02),
                        SizedBox(
                            width: w * 0.05,
                            child: Image.asset('assets/icon2.png')),
                      ],
                    ),
                  ),
          ),
          Positioned(
            top: 7, // Adjust the position as needed
            right: 7, // Adjust the position as needed
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.secondaryColor, // Secondary color background
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
        ],
      )),
    );
  }
}
