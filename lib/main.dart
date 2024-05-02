import 'package:cloi/firebase_options.dart';
import 'package:cloi/pages/accounts/account.dart';
import 'package:cloi/pages/appPages/appPage.dart';
import 'package:cloi/pages/loginPages/infoPage.dart';
import 'package:cloi/pages/loginPages/loginpage.dart';
import 'package:cloi/pages/loginPages/sucess.dart';
import 'package:cloi/pages/menu.dart';
import 'package:cloi/pages/orders/orderCancelled.dart';
import 'package:cloi/pages/orders/orderDelivered.dart';
import 'package:cloi/pages/orders/orderPage.dart';
import 'package:cloi/pages/orders/orderShipped.dart';
import 'package:cloi/pages/orders/orders.dart';
import 'package:cloi/pages/products/catagorie.dart';
import 'package:cloi/pages/products/catagorieEdit.dart';
import 'package:cloi/pages/products/productAdd.dart';
import 'package:cloi/pages/products/productEdit.dart';
import 'package:cloi/pages/products/products.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        'loginPage': (context) => const loginPage(),
        'orderPage': (context) => orderPage(),
        'orderView': (context) {
          final Map<String, dynamic> arguments = ModalRoute.of(context)!
              .settings
              .arguments as Map<String, dynamic>;

          return orderView(
            data: arguments['data'],
            docId: arguments['docId'],
          );
        },
        'orderShip': (context) {
          final Map<String, dynamic> arguments = ModalRoute.of(context)!
              .settings
              .arguments as Map<String, dynamic>;

          return orderShip(
            data: arguments['data'],
            docId: arguments['docId'],
          );
        },
        'orderCancel': (context) {
          final Map<String, dynamic> arguments = ModalRoute.of(context)!
              .settings
              .arguments as Map<String, dynamic>;

          return orderCancel(
            data: arguments['data'],
            docId: arguments['docId'],
          );
        },
        'orderDeliver': (context) {
          final Map<String, dynamic> arguments = ModalRoute.of(context)!
              .settings
              .arguments as Map<String, dynamic>;

          return orderDeliver(
            data: arguments['data'],
            docId: arguments['docId'],
          );
        },
        'productPage': (context) => productPage(),
        'catagorie': (context) => catagoriePage(),
        'productAdd': (context) => productAdd(),
        'productEdit': (context) {
          final Map<String, dynamic> arguments = ModalRoute.of(context)!
              .settings
              .arguments as Map<String, dynamic>;

          return productEdit(
            data: arguments['data'],
            docId: arguments['docId'],
            images: arguments['images'],
          );
        },
        'accountPage': (context) => accountPage(),
        'infoPage': (context) => infoPage(),
        'sucessPage': (context) => sucessPage(),
        'menuPage': (context) => menuPage(),
        'appPage': (context) => appPage(),
        'catagorieEdit': (context) {
          final Map<String, dynamic> arguments = ModalRoute.of(context)!
              .settings
              .arguments as Map<String, dynamic>;

          return catagorieEdit(
            data: arguments['data'],
            uid: arguments['uid'],
            id: arguments['id'],
            catagoriePhoto: arguments['catagoriePhoto'],
          );
        },
      },
      debugShowCheckedModeBanner: false,
      title: 'Cloi',
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data == null) {
              return const loginPage();
            } else {
              final user = snapshot.data;
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  if (snapshot.connectionState == ConnectionState.done) {
                    Map<String, dynamic>? data =
                        snapshot.data?.data() as Map<String, dynamic>?;
                    bool? loginCompleted;

                    if (data != null && data.containsKey('loginCompleted')) {
                      loginCompleted = data['loginCompleted'];
                    }

                    if (loginCompleted == true) {
                      return productPage();
                    } else if (loginCompleted == false) {
                      return infoPage();
                    } else {
                      return const loginPage();
                    }
                  }
                  return Center(
                    child: Lottie.asset(
                      'assets/loading.json', // Replace with your Lottie animation file path
                      width: 200,
                    ),
                  );
                },
              );
            }
          }
          return Center(
            child: Lottie.asset(
              'assets/loading.json', // Replace with your Lottie animation file path
              width: 200,
            ),
          );
        },
      ),
    );
  }
}
