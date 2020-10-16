import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle mystyle(double size, [Color color, FontWeight fw]) {
  return GoogleFonts.montserrat(
    fontSize: size,
    color: color,
    fontWeight: fw,
  );
}

CollectionReference usercollection = Firestore.instance.collection('users');


CollectionReference postcollection = Firestore.instance.collection('posts');
StorageReference nidpictures = FirebaseStorage.instance.ref().child('nidpicture');
