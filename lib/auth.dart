import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_sign_in/google_sign_in.dart';

class AuthServices {
  GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  String location = 'Null, Press Button';
  // ignore: non_constant_identifier_names
  String Address = 'search';

  // ignore: non_constant_identifier_names
  Future<void> GetAddressFromLatLong(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark place = placemarks[0];
    Address =
        '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
  }

  //exact accuarcy
  Future<Position> getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Request permission to use location only when the app is in use.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    // If permission is denied forever, handle it appropriately.
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When permissions are granted, get the position
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  }

  Future<void> addDefaultCategory(String userId) async {
    const defaultCategoryName = 'All';
    const defaultCategoryImage =
        'https://firebasestorage.googleapis.com/v0/b/cloi-d6e0b.appspot.com/o/uploads%2F1000000272.png?alt=media&token=c2ba9aee-4595-4190-a3ad-f9d99a729d03'; // Replace with your default image URL

    try {
      await FirebaseFirestore.instance.collection('catagorie').add({
        'catagorieName': defaultCategoryName,
        'uid': userId,
        'catagoriePhoto': defaultCategoryImage,
      });
    } catch (e) {
      print('Error adding default category: $e');
    }
  }

  //till here

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );
        UserCredential userCredential =
            await firebaseAuth.signInWithCredential(credential);
        User? user = userCredential.user;

        if (user != null) {
          // Get the user's location and address
          Position position = await getGeoLocationPosition();
          await GetAddressFromLatLong(position);

          String photoURL = user.photoURL ??
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTf6_jeCeVDiMDqJ9DIobNO3Uu4EppEmf-64fuSwh5KAGeYYt3PoSM03rPUNjIuAeD5XXY&usqp=CAU';

          // Check if the user's document already exists
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          // If the document does not exist, create it
          if (!userDoc.exists) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
              'name': user.displayName,
              'email': user.email,
              'photoURL': photoURL,
              'phone': user.phoneNumber,
              'storeName': '',
              'uid': user.uid,
              'address': Address,
              'storeLogo': '',
              'extraCharge': 0,

              'shippingDetails': 'Same Day Dispatch',
              'paymentMethod': 'COD',
              'paymentkey': '0',
              'loginCompleted':
                  false, // Update 'loginCompleted' to true upon successful login
            });
            await addDefaultCategory(user.uid);
          }

          // Navigate based on login completion status
          // ... your existing navigation logic
          // Navigate based on login completion status
          bool loginCompleted =
              userDoc.exists ? userDoc['loginCompleted'] : false;
          if (loginCompleted) {
            Navigator.pushNamedAndRemoveUntil(
                context, 'productPage', (route) => false);
          } else {
            Navigator.pushNamedAndRemoveUntil(
                context, 'infoPage', (route) => false);
          }
        }
      } else {
        const snackBar =
            SnackBar(content: Text('Error signing in with Google'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      final snackBar = SnackBar(content: Text('$e'));
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> signOutOfGoogle(BuildContext context) async {
    try {
      googleSignIn.signOut();
      firebaseAuth.signOut();
      Navigator.pushNamedAndRemoveUntil(context, 'loginPage', (route) => false);
    } catch (e) {
      final snackBar = SnackBar(content: Text('$e'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
