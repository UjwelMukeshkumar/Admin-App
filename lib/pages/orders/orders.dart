import 'package:cloi/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class orderPage extends StatefulWidget {
  @override
  _orderPageState createState() => _orderPageState();
}

class _orderPageState extends State<orderPage> {
  late String currentUserId;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

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

  void getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;
    return DefaultTabController(
      length: 4, // Number of tabs
      child: Scaffold(
        backgroundColor: AppColors.thirdtextColor, // Set background color
        appBar: AppBar(
          backgroundColor:
              AppColors.thirdtextColor, // Set AppBar background color
          bottom: TabBar(
            labelColor: AppColors.primaryColor, // Set TabBar text color
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Confirmed'),
              Tab(text: 'Shipped'),
              Tab(text: 'Delivered'),
            ],
          ),
          title: TextField(
            style: TextStyle(
                color: AppColors.secondaryColor,
                fontSize: w * 0.05 // Set text color to white
                ),
            controller: searchController,
            decoration: InputDecoration(
              // labelText: "Search Customer | Phone No..",
              hintText: "Search Customer Name | Phone No..",
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.secondaryColor,
              ),
              hintStyle: TextStyle(
                  color: Colors.white,
                  fontSize: w * 0.05 // Set label text color to white
                  ),
              border: InputBorder.none,
            ),
          ), // Set AppBar title text color
        ),
        body: Stack(
          children: [
            TabBarView(
              children: [
                _buildOrderList('All'),
                _buildOrderList('CONFIRMED'),
                _buildOrderList('SHIPPED'),
                _buildOrderList('DELIVERED'),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomButtons(w, h),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(String status) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.only(bottom: h * 0.1),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('store_id', isEqualTo: currentUserId)
            .orderBy('storeOrderNo', descending: true) // Modify this line
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryColor));
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          var filteredDocs = snapshot.data!.docs.where((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return (status == 'All' || data['status'] == status) &&
                (data['userName'].toLowerCase().contains(searchQuery) ||
                    data['userPhone'].toLowerCase().contains(searchQuery));
          }).toList();

          return ListView(
            children: filteredDocs.isEmpty
                ? [
                    Column(
                      children: [
                        SizedBox(
                          height: h * 0.2,
                        ),
                        Center(
                          child: Lottie.asset(
                            'assets/product.json',
                            width: w * 0.8,
                          ),
                        ),
                        Text(
                          "No Orders Available",
                          style: TextStyle(
                              fontSize: w * 0.05,
                              color: AppColors.primaryColor),
                        )
                      ],
                    ),
                  ]
                : filteredDocs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    return ListTile(
                      title: InkWell(
                        onTap: () {
                          String status = data['status'];
                          if (status == 'CANCELLED') {
                            Navigator.pushNamed(
                              context,
                              'orderCancel',
                              arguments: {
                                'data': data,
                                'docId': document.id,
                                'products': data['products'],
                              },
                            );
                          } else if (status == 'CONFIRMED') {
                            Navigator.pushNamed(
                              context,
                              'orderView',
                              arguments: {
                                'data': data,
                                'docId': document.id,
                                'products': data['products'],
                              },
                            );
                          } else if (status == 'DELIVERED') {
                            Navigator.pushNamed(
                              context,
                              'orderDeliver',
                              arguments: {
                                'data': data,
                                'docId': document.id,
                                'products': data['products'],
                              },
                            );
                          } else if (status == 'SHIPPED') {
                            Navigator.pushNamed(
                              context,
                              'orderShip',
                              arguments: {
                                'data': data,
                                'docId': document.id,
                                'products': data['products'],
                              },
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.07),

                                // changes position of shadow
                              ),
                              BoxShadow(
                                color: const Color.fromARGB(255, 0, 0, 0)
                                    .withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 1,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: w * 0.05,
                                        top: h * 0.02,
                                        bottom: h * 0.005),
                                    child: Text(
                                      'Order #0${data['storeOrderNo'] ?? 'No no:'}',
                                      style: GoogleFonts.inter(
                                        fontSize: w * 0.045,
                                        fontWeight: FontWeight.w300,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        right: w * 0.055,
                                        top: h * 0.02,
                                        bottom: h * 0.005),
                                    child: Text(
                                      '${data['date'] ?? 'No date Available'}',
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryColor,
                                        fontSize: w * 0.035,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Container(
                                      width: w * 0.75,
                                      child: Image.asset('assets/line.png')),
                                ),
                              ),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: w * 0.05,
                                        bottom: h * 0.02,
                                        top: h * 0.005,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors
                                              .black, // Replace with your desired color
                                          borderRadius: BorderRadius.circular(
                                              100), // Replace with your desired border radius
                                        ),
                                        width: w * 0.25,
                                        height: h * 0.03,
                                        child: Center(
                                          child: Text(
                                            '${data['status'] ?? 'No status Available'}',
                                            style: TextStyle(
                                              fontSize: w * 0.027,
                                              color: data['status'] ==
                                                      'DELIVERED'
                                                  ? AppColors.deliverColor
                                                  : data['status'] == 'SHIPPED'
                                                      ? AppColors.shipColor
                                                      : data['status'] ==
                                                              'CONFIRMED'
                                                          ? AppColors
                                                              .primaryColor
                                                          : data['status'] ==
                                                                  'CANCELLED'
                                                              ? AppColors
                                                                  .secondaryColor
                                                              : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          right: w * 0.06,
                                          bottom: h * 0.025,
                                          top: h * 0.009),
                                      child: RichText(
                                        text: TextSpan(
                                          text:
                                              '${data['totalItems'] ?? 'No items Available'}',
                                          style: GoogleFonts.inter(
                                            fontSize: w * 0.05,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.secondaryColor,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: ' items',
                                              style: GoogleFonts.inter(
                                                fontSize: w * 0.03,
                                                fontWeight: FontWeight.w300,
                                                color: AppColors.primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ])
                            ],
                          ),
                        ),
                      ),
                      // subtitle: Text('ID: ${document.id}'),
                    );
                  }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildBottomButtons(double w, double h) {
    return Container(
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
              borderRadius: BorderRadius.circular(10), // small curve
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, 'productPage', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.white, // background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // small curve
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                      width: w * 0.05, child: Image.asset('assets/icon5.png')),
                  SizedBox(
                    width: w * 0.02,
                  ),
                  // replace with your asset path
                  Text(
                    'Go to Products',
                    style: GoogleFonts.inter(
                      // replace 'roboto' with your desired Google font
                      color: AppColors.thirdtextColor,
                      fontSize: w * 0.05,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Container(
            width: w * 0.18,
            height: h * 0.08,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), // small curve
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, 'accountPage', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFFF80000),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // small curve
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
    );
  }
}
