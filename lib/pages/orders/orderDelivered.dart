import 'package:cloi/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class orderDeliver extends StatefulWidget {
  final Map<String, dynamic> data;

  final String docId;
  const orderDeliver({
    Key? key,
    required this.data,
    required this.docId,
  }) : super(key: key);

  @override
  State<orderDeliver> createState() => _orderDeliverState();
}

class _orderDeliverState extends State<orderDeliver> {
  late String docId;

  /// Prints the document ID.

  late List<dynamic> products = widget.data['products'];

  late int orderNo = widget.data['storeOrderNo'];
  late String userPhone = widget.data['userPhone'];
  late String userName = widget.data['userName'];
  late String status = widget.data['status'];
  late int totalItems = widget.data['totalItems'];
  late String date = widget.data['date'];
  late String userAddress = widget.data['userAddress'];
  late double totalPrice = widget.data['totalPrice'];
  late double grandTotal = widget.data['grandTotal'];
  late int shippingCharge = widget.data['shippingCharge'];
// Declare docId as a class-level variable

  @override
  void initState() {
    super.initState();
    docId = widget.docId; // Assign widget's docId to the state's docId
  }

  Future<void> updateStatusToCancelled(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(docId)
          .update({'status': 'CANCELLED'});
    } catch (e) {
      print('Failed to update order status: $e');
      // Handle the error as appropriate for your application
    }
  }

  bool showCancel = false;

  void onPressedAction() {
    setState(() {
      showCancel = !showCancel;
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
        backgroundColor: AppColors.cardColor,
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.9),
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
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            left: w * 0.06,
                            top: h * 0.03,
                            bottom: h * 0.015,
                            right: w * 0.06),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #0$orderNo',
                              style: GoogleFonts.inter(
                                fontSize: w * 0.05,
                                fontWeight: FontWeight.w300,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors
                                    .black, // Replace with your desired color
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: Colors.white, // Border color
                                  width: w * 0.0005, // Border width
                                ),
                              ),
                              width: w * 0.25,
                              height: h * 0.03,
                              child: Center(
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: w * 0.027,
                                    color: status == 'DELIVERED'
                                        ? AppColors.deliverColor
                                        : status == 'SHIPPED'
                                            ? AppColors.shipColor
                                            : status == 'CONFIRMED'
                                                ? AppColors.primaryColor
                                                : status == 'CANCELLED'
                                                    ? AppColors.secondaryColor
                                                    : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: Container(
                            width: w * 0.75,
                            child: Image.asset('assets/line.png')),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: h * 0.01, right: w * 0.08, left: w * 0.06),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: totalItems.toString(),
                                style: GoogleFonts.inter(
                                  fontSize: w * 0.045,
                                  fontWeight: FontWeight.w300,
                                  color: AppColors.secondaryColor,
                                ),
                                children: [
                                  TextSpan(
                                    text: ' items',
                                    style: GoogleFonts.inter(
                                      fontSize: w * 0.035,
                                      fontWeight: FontWeight.w300,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                text: ' | ',
                                style: GoogleFonts.inter(
                                  fontSize: w * 0.035,
                                  fontWeight: FontWeight.w300,
                                  color: AppColors.primaryColor,
                                ),
                                children: [
                                  TextSpan(
                                    text: date,
                                    style: GoogleFonts.inter(
                                      fontSize: w * 0.03,
                                      fontWeight: FontWeight.w300,
                                      color: AppColors.secondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: w * 0.06,
                            top: h * 0.003,
                            bottom: h * 0.01,
                            right: w * 0.07),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Address",
                            style: GoogleFonts.inter(
                              fontSize: w * 0.045,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: w * 0.06, bottom: h * 0.005, right: w * 0.07),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            userAddress,
                            style: GoogleFonts.inter(
                              height: h * 0.0022,
                              fontSize: w * 0.035,
                              fontWeight: FontWeight.w300,
                              color: AppColors.secondarytextColor,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: h * 0.005, right: w * 0.07, left: w * 0.06),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Contact Name : " + userName,
                            style: GoogleFonts.inter(
                              fontSize: w * 0.035,
                              fontWeight: FontWeight.w300,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: h * 0.02, right: w * 0.07, left: w * 0.06),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Contact Number : +91 " + userPhone,
                            style: GoogleFonts.inter(
                              fontSize: w * 0.035,
                              fontWeight: FontWeight.w300,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                            width: w * 0.8,
                            child: Image.asset('assets/line.png')),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left: w * 0.06,
                                  bottom: h * 0.006,
                                  top: h * 0.015,
                                  right: w * 0.07),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "item Total",
                                    style: GoogleFonts.inter(
                                      fontSize: w * 0.035,
                                      fontWeight: FontWeight.w300,
                                      color: AppColors.secondarytextColor,
                                    ),
                                  ),
                                  Text(
                                    "₹ " + totalPrice.toString(),
                                    style: GoogleFonts.inter(
                                      fontSize: w * 0.035,
                                      fontWeight: FontWeight.w300,
                                      color: AppColors.secondarytextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: w * 0.06,
                                  bottom: h * 0.015,
                                  right: w * 0.07),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Delivery",
                                    style: GoogleFonts.inter(
                                      fontSize: w * 0.035,
                                      fontWeight: FontWeight.w300,
                                      color: AppColors.secondarytextColor,
                                    ),
                                  ),
                                  Text(
                                    "₹ " + shippingCharge.toString(),
                                    style: GoogleFonts.inter(
                                      fontSize: w * 0.035,
                                      fontWeight: FontWeight.w300,
                                      color: AppColors.secondarytextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: Container(
                                  width: w * 0.8,
                                  child: Image.asset('assets/redline.png')),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: h * 0.015,
                                  left: w * 0.06,
                                  bottom: h * 0.015,
                                  right: w * 0.07),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Grand Total",
                                    style: GoogleFonts.inter(
                                      fontSize: w * 0.035,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  Text(
                                    "₹ " + grandTotal.toString(),
                                    style: GoogleFonts.inter(
                                      fontSize: w * 0.035,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: Container(
                                width: w * 0.8,
                                child: Image.asset('assets/redline.png'),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: h * 0.005,
                                left: w * 0.035,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: w * 0.99,
                                  height: h * 0.4,
                                  child: ListView.builder(
                                    itemCount: products.length,
                                    itemBuilder: (context, index) {
                                      var product = products[index];
                                      return ListTile(
                                        title: Row(
                                          children: [
                                            Container(
                                              width: w * 0.13,
                                              height: h * 0.055,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                child: Image.network(
                                                  product['images'][0],
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: w * 0.035,
                                            ),
                                            Container(
                                              width: w * 0.4,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${product['productName']}',
                                                    style: GoogleFonts.inter(
                                                      fontSize: w * 0.035,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColors
                                                          .primaryColor,
                                                    ),
                                                  ),
                                                  RichText(
                                                    text: TextSpan(
                                                      text: '${product['qty']}',
                                                      style: GoogleFonts.inter(
                                                        fontSize: w * 0.035,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        color: AppColors
                                                            .secondarytextColor,
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              ' x ₹ ${product['salePrice']}',
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: w * 0.035,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color: AppColors
                                                                .secondarytextColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Spacer(),
                                            Text(' ₹ ${product['salePrice']}',
                                                style: GoogleFonts.inter(
                                                  fontSize: w * 0.035,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.primaryColor,
                                                )),
                                          ],
                                        ),

                                        // Add more details as needed
                                      );
                                    },
                                  ),
                                ),
                              ),
                            )
                          ]),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0, // Adjust the position as needed
                right: 0, // Adjust the position as needed
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
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          // Call the method to add product details
                          // await addProduct();

                          Navigator.pushNamedAndRemoveUntil(
                              context, 'orderPage', (route) => false);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10), // small curve
                          ),
                          minimumSize: Size(w * 0.86,
                              h * 0.09), // set the width and height of the button
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            // replace with your asset path
                            Text(
                              'Close here',
                              style: TextStyle(
                                color: AppColors.secondaryColor,
                                fontSize: w * 0.05,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(
                              width: w * 0.05,
                            ),
                            SizedBox(
                                width: w * 0.07,
                                child: Image.asset('assets/icon10.png')),
                          ],
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // This is a placeholder function. Replace it with your actual implementation.
}
