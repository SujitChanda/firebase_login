import 'package:bengaliallinone/screens/registration_screen.dart';
import 'package:bengaliallinone/services/firebase_services.dart';
import 'package:bengaliallinone/services/shared_ervices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';

class AuthProvider with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  SharedServices _sharedServices = SharedServices();
  FirebaseServices _services = FirebaseServices();
  String smsOtp = "";
  String? verificationId;
  String error = '';
  bool otpSubmit = false;
  bool loading = false;
  String? screen;
  double? latitude;
  double? longitude;
  String? address;
  String? location;
  String? username;
  String? phoneNumber;
  String? email;
  String? uid;
  //DocumentSnapshot snapshot;
  TextEditingController _pinEditingController = TextEditingController();
  PinDecoration _pinDecoration = BoxLooseDecoration(
    gapSpace: 8,
    textStyle: TextStyle(color: Colors.black, fontSize: 20),
    hintText: '******',
    hintTextStyle: TextStyle(color: Colors.grey, fontSize: 20),
    strokeColorBuilder: FixedColorBuilder(Colors.blue),
  );

  Future<void> verifyPhone(
      {required BuildContext context, required String number}) async {
    this.loading = true;
    notifyListeners();

    final PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential credential) async {
      this.loading = true;
      notifyListeners();
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException e) {
      this.loading = true;
      print(e.code);
      this.error = e.toString();
      notifyListeners();
    };

    final PhoneCodeSent smsOtpSend = (String verId, int? resendToken) async {
      this.verificationId = verId;
      print(number);
      this.loading = false;
      notifyListeners();
      smsOtpDialog(context, number);
    };

    try {
      _auth.verifyPhoneNumber(
        phoneNumber: number,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: smsOtpSend,
        codeAutoRetrievalTimeout: (String verId) {
          this.verificationId = verId;
        },
      );
    } catch (e) {
      this.error = e.toString();
      this.loading = false;
      notifyListeners();
      print(e);
    }
  }

  smsOtpDialog(BuildContext context, String number) {
    this.loading = false;
    notifyListeners();
    return showCupertinoDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Column(
              children: [
                Text('Verification Code'),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Enter 6 digit OTP received as SMS',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
            content: Container(
              height: 50,
              child: PinFieldAutoFill(
                codeLength: 6,
                autoFocus: true,
                decoration: _pinDecoration,
                controller: _pinEditingController,
                //currentCode: _code,
                onCodeSubmitted: (code) {
                  this.smsOtp = code;
                  otpSubmit = true;
                  notifyListeners();
                },
                onCodeChanged: (code) async {
                  if (code!.length == 6) {
                    this.smsOtp = code;
                    FocusScope.of(context).requestFocus(FocusNode());
                    this.smsOtp = code;
                    otpSubmit = true;
                    notifyListeners();
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                },
              ),
            ),
          );
        }).whenComplete(() async {
      this.loading = true;
      notifyListeners();
      if (smsOtp.length == 6 && otpSubmit)
        try {
          // Navigator.of(context).pop();

          PhoneAuthCredential phoneAuthCredential =
              PhoneAuthProvider.credential(
                  verificationId: verificationId!, smsCode: smsOtp);
          final User? user =
              (await _auth.signInWithCredential(phoneAuthCredential)).user;
          if (user != null) {
            print("Login SuccessFul");
            _services.getUserById(user.uid).then((snapShot) {
              if (snapShot.exists) {
                //user data already exists

                if (this.screen == 'Login') {
                  username = "${snapShot['name']}";
                  phoneNumber = '${snapShot["number"]}';
                  email = '${snapShot['email']}';
                  notifyListeners();
                  _sharedServices.addUserDataToSF(
                    name: '${snapShot['name']}',
                    phone: '${snapShot['number']}',
                    email: '${snapShot['email']}',
                    picURL: '${snapShot['profile_Pic_URL']}',
                  );
                  Navigator.pushReplacementNamed(context, '/Landing_Screen');
                } else {
                  //need to update new selected address
                  //  updateUser(id: user.uid, number: user.phoneNumber);

                }
              } else {
                // user data does not exists
                // will create new data in db
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RegistrationScreen(
                              phoneNumber: user.phoneNumber!,
                              uid: user.uid,
                            )));

                // createUser(id: user.uid, number: user.phoneNumber);
                // Navigator.pushReplacementNamed(context, LandingPage.idScreen);
              }
            });
          } else {
            print('Login failed');
          }
        } catch (e) {
          this.error = 'Invalid OTP';
          this.loading = false;
          notifyListeners();

          print(e.toString());
        }
      this.loading = false;
      notifyListeners();
    });
  }
}
