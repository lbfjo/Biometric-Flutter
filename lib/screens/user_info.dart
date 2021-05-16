import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/res/custom_colors.dart';
import 'package:my_app/screens/sign_in_screen.dart';
import 'package:my_app/utils/authentication.dart';
import 'package:my_app/widget/app_bar_title.dart';
import 'package:my_app/utils/string_extension.dart';
import 'package:my_app/widget/info_card.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:my_app/Screens/secret_vault_screen.dart';
import 'package:local_auth/local_auth.dart';
import "dart:ui" as ui;

const url = 'https://www.linkedin.com/in/francisco-bruno-a62731109/';
final LocalAuthentication localAuthentication = LocalAuthentication();

const phone = '+351 911771737';
void _showDialog(BuildContext context,
    {required String title, required String msg}) {
  final dialog = AlertDialog(
    title: Text(title),
    content: Text(msg),
    actions: <Widget>[
      ElevatedButton(
        style: raisedButtonStyle,
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text('Close'),
      ),
    ],
  );
  showDialog(context: context, builder: (x) => dialog);
}

final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
  onPrimary: Colors.black87,
  primary: Colors.grey[300],
  minimumSize: Size(88, 36),
  padding: EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(2)),
  ),
);

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  late User _user;
  bool _isSigningOut = false;

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SignInScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  void initState() {
    _user = widget._user;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var userString = _user.displayName.toString();
    var capitalized = userString.capitalizeFirstofEach;
    return Scaffold(
      backgroundColor: Colors.teal[200],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.teal[200],
        title: AppBarTitle(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _user.photoURL != null
                  ? ClipOval(
                      child: Material(
                        color: CustomColors.firebaseGrey.withOpacity(0.3),
                        child: Image.network(
                          _user.photoURL!,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    )
                  : ClipOval(
                      child: Material(
                        color: CustomColors.firebaseGrey.withOpacity(0.3),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: CustomColors.firebaseGrey,
                          ),
                        ),
                      ),
                    ),
              SizedBox(height: 8.0),
              Text(capitalized,
                  style: GoogleFonts.pacifico(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              SizedBox(
                width: 200,
                child: Divider(
                  color: Colors.teal.shade700,
                ),
              ),
              InfoCard(
                text: phone,
                icon: Icons.phone,
                onPressed: () async {
                  String removeSpaceFromPhoneNumber =
                      phone.replaceAll(new RegExp(r"\s+\b|\b\s"), "");
                  final phoneCall = 'tel:$removeSpaceFromPhoneNumber';

                  if (await launcher.canLaunch(phoneCall)) {
                    await launcher.launch(phoneCall);
                  } else {
                    _showDialog(
                      context,
                      title: 'Sorry',
                      msg: 'Phone number can not be called. Please try again!',
                    );
                  }
                },
              ),
              InfoCard(
                text: '( ${_user.email!} )',
                icon: Icons.email,
                onPressed: () async {
                  final emailAddress = 'mailto:$_user.email!';

                  if (await launcher.canLaunch(emailAddress)) {
                    await launcher.launch(emailAddress);
                  } else {
                    _showDialog(
                      context,
                      title: 'Sorry',
                      msg: 'Email can not be send. Please try again!',
                    );
                  }
                },
              ),
              InfoCard(
                text: url,
                icon: Icons.web,
                onPressed: () async {
                  if (await launcher.canLaunch(url)) {
                    await launcher.launch(url);
                  } else {
                    _showDialog(
                      context,
                      title: 'Sorry',
                      msg: 'URL can not be opened. Please try again!',
                    );
                  }
                },
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    CustomColors.firebaseAmber,
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                onPressed: () async {
                  bool isAuthenticated =
                      await Authentication.authenticateWithBiometrics();

                  if (isAuthenticated) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SecretVaultScreen(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      Authentication.customSnackBar(
                        content: 'Error authenticating using Biometrics.',
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: RichText(
                    text: TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                            text: 'Access secret vault   ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            )),
                        WidgetSpan(
                          alignment: ui.PlaceholderAlignment.middle,
                          child: Icon(
                            Icons.fingerprint_outlined,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'You are now signed in using your Google account. To sign out of your account click the "Sign Out" button below.',
                style: TextStyle(
                    color: CustomColors.firebaseGrey.withOpacity(0.8),
                    fontSize: 14,
                    letterSpacing: 0.2),
              ),
              SizedBox(height: 16.0),
              _isSigningOut
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        setState(() {
                          _isSigningOut = true;
                        });
                        await Authentication.signOut(context: context);
                        setState(() {
                          _isSigningOut = false;
                        });
                        Navigator.of(context)
                            .pushReplacement(_routeToSignInScreen());
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
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
