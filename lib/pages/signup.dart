import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pejuang/collection.dart';
import 'package:pejuang/helper/helperfunctions.dart';
import 'package:pejuang/pages/homepage.dart';
import 'package:pejuang/services/auth.dart';
import 'package:pejuang/services/database.dart';
import 'package:pejuang/widget/widget.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;

import 'package:google_fonts/google_fonts.dart';
class SignUp extends StatefulWidget {
  final Function toggleView;
  SignUp(this.toggleView);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {







  TextEditingController emailEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();
  TextEditingController usernameEditingController = TextEditingController();
  TextEditingController nidcardnumber = TextEditingController();
  TextEditingController mobilenumber = TextEditingController();


  AuthService authService = AuthService();
  DatabaseMethods databaseMethods = DatabaseMethods();

  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
    File file;
    String postId = Uuid().v4();






    handleTakePhoto() async {
      Navigator.pop(context);
      File file = await ImagePicker.pickImage(
        source: ImageSource.camera,
        maxHeight: 675,
        maxWidth: 960,
      );
      setState(() {
        this.file = file;
      });
    }

  TextStyle mystyle(double size, [Color color, FontWeight fw]) {
    return GoogleFonts.montserrat(
      fontSize: size,
      color: color,
      fontWeight: fw,
    );
  }
    optionsdialog() {
      return showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              children: <Widget>[
                SimpleDialogOption(
                  onPressed: handleChooseFromGallery,
                  child: Text(
                    "Image from gallery",
                    style: mystyle(20),
                  ),
                ),
                SimpleDialogOption(
                  onPressed: handleTakePhoto,
                  child: Text(
                    "Image from camera",
                    style: mystyle(20),
                  ),
                ),
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: mystyle(20),
                  ),
                )
              ],
            );
          });
    }

    handleChooseFromGallery() async {
      Navigator.pop(context);
      File file = await ImagePicker.pickImage(source: ImageSource.gallery);
      setState(() {
        this.file = file;
      });
    }

    compressImage() async {
      final tempDir = await getTemporaryDirectory();
      final path = tempDir.path;
      Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
      final compressedImageFile = File('$path/img_$postId.jpg')
        ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
      setState(() {
        file = compressedImageFile;
      });
    }

    Future<String> uploadImage(imageFile) async {
      StorageUploadTask uploadTask =
          nidpictures.child("post_$postId.jpg").putFile(imageFile);
      StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
      String downloadUrl = await storageSnap.ref.getDownloadURL();
      return downloadUrl;
    }


  singUp() async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      await authService
          .signUpWithEmailAndPassword(
              emailEditingController.text, passwordEditingController.text)
          .then((result) async {
            
            
        if (result != null) {
      String photoUrl = await uploadImage(file);

          
          

          Map<String, String> userDataMap = {
            "userName": usernameEditingController.text,
            "userEmail": emailEditingController.text,
            "nid": nidcardnumber.text,
            "mobile": mobilenumber.text,
            "nidpic":photoUrl,

          };

          databaseMethods.addUserInfo(userDataMap);

          HelperFunctions.saveUserLoggedInSharedPreference(true);
          HelperFunctions.saveUserNameSharedPreference(
              usernameEditingController.text);
          HelperFunctions.saveUserEmailSharedPreference(
              emailEditingController.text);

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Feedpage()));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: appBarMain(context),
      body: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Spacer(),
                  Form(
                    key: formKey,
                    child:SingleChildScrollView (
                                          child: Column(
                        children: [
                          TextFormField(
                            style: simpleTextStyle(),
                            controller: usernameEditingController,
                            validator: (val) {
                              return val.isEmpty || val.length < 3
                                  ? "Enter Username 3+ characters"
                                  : null;
                            },
                            decoration: textFieldInputDecoration("username"),
                          ),
                          TextFormField(
                            controller: emailEditingController,
                            style: simpleTextStyle(),
                            validator: (val) {
                              return RegExp(
                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      .hasMatch(val)
                                  ? null
                                  : "Enter correct email";
                            },
                            decoration: textFieldInputDecoration("email"),
                          ),
                          TextFormField(
                            obscureText: true,
                            style: simpleTextStyle(),
                            decoration: textFieldInputDecoration("password"),
                            controller: passwordEditingController,
                            validator: (val) {
                              return val.length < 6
                                  ? "Enter Password 6+ characters"
                                  : null;
                            },
                          ),
                          TextFormField(
                            style: simpleTextStyle(),
                            decoration: textFieldInputDecoration("NID Number"),
                            controller: nidcardnumber,
                            validator: (val) {
                              return val.length < 11
                                  ? "Please Valid NID Number"
                                  : null;
                            },
                          ),
                               TextFormField(
                            style: simpleTextStyle(),
                            decoration: textFieldInputDecoration("Mobile Number"),
                            controller: mobilenumber,
                            validator: (val) {
                              return val.length < 11
                                  ? "Enter Your Mobile  Number"
                                  : null;
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Upload Your NId Card Picture",style: TextStyle(color: Colors.white),),

                          //  IconButton(icon:Icon(Icons.camera) , onPressed: null,color: Colors.white,)
                            InkWell(
            onTap: () => optionsdialog(),
            child: Icon(
              Icons.camera_alt,
              size: 40,
              color: Colors.white,
            ),
          )

                          ],

                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  GestureDetector(
                    onTap: () {
                      singUp();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xff007EF4),
                              const Color(0xff2A75BC)
                            ],
                          )),
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        "Sign Up",
                        style: biggerTextStyle(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  /*    Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30), color: Colors.white),
              width: MediaQuery.of(context).size.width,
              child: Text(
                "Sign Up with Google",
                style: TextStyle(fontSize: 17, color: CustomTheme.textColor),
                textAlign: TextAlign.center,
              ),
            ), */
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: simpleTextStyle(),
                      ),
                      GestureDetector(
                        onTap: () {
                          widget.toggleView();
                        },
                        child: Text(
                          "SignIn now",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                  )
                ],
              ),
            ),
    );
  }
}
