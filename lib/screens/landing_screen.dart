
import 'package:bengaliallinone/constants.dart';
import 'package:bengaliallinone/screens/my_profile_screen.dart';
import 'package:bengaliallinone/services/push_notification_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LandingScreen extends StatefulWidget {
  LandingScreen({Key? key}) : super(key: key);

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late FirebaseNotifcation firebase;
  late WebViewController controller;
  double containerHeight = 0;
  var containerMaxHeight;
  bool isLoading = true;
  String greetingText = "";
 

  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      greetingText = 'Good Morning';

      return greetingText;
    }
    if (hour < 20) {
      greetingText = 'Good Afternoon';

      return greetingText;
    } else {
      greetingText = 'Good Evening';

      return greetingText;
    }
  }


  handleAsync() async {
    await firebase.initialize();
    await firebase.subscribeToTopic('user');
    await firebase.getToken();
  }

  @override
  void initState() {
    greeting();
    firebase = FirebaseNotifcation(context: context);
    handleAsync();
   
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    containerMaxHeight = MediaQuery.of(context).size.height -
        (kToolbarHeight + MediaQuery.of(context).padding.top);
    return WillPopScope(
      onWillPop: () async {
        if (await controller.canGoBack()) {
          controller.goBack();
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: primaryColor,
            elevation: 0,
            title: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyProfileScreen(
                              appBarVisibility: true,
                            ))).whenComplete(() {
                  if (mounted) setState(() {});
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 22,
                    child: Padding(
                      padding: const EdgeInsets.all(0.5),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 21.5,
                        child: ClipRRect(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          borderRadius: BorderRadius.all(Radius.circular(500)),
                          child: CachedNetworkImage(
                            imageUrl: prefs!.getString('_userPicURL')!,
                            width: MediaQuery.of(context).size.width,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(
                              color: Colors.blue,
                              strokeWidth: 0.5,
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Container(
                      height: 30,
                      width: 1,
                      color: Colors.white,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(greeting(),
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(
                                  backgroundColor: primaryColor,
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  letterSpacing: 1)),
                      Text(prefs!.getString('_userName')!,
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
                                    fontSize: 16,
                                    color: Colors.white,
                                    letterSpacing: 0.8,
                                    fontWeight: FontWeight.bold,
                                  ))
                    ],
                  ),
                ],
              ),
            ),
          ),
          extendBody: false,
          body: 

          Stack(
            children: [
              WebView(
                onPageFinished: (finished) {
                  if (mounted)
                    setState(() {
                      isLoading = false;
                    });
                },
                initialUrl: "https://www.matrixnmedia.com",
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (controller) {
                  this.controller = controller;
                },
              ),
              Visibility(
                visible: isLoading,
                child: new Center(
                    child: Card(
                  elevation: 10,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: CircleAvatar(
                      child: Container(
                        height: 90,
                        width: 90,
                        child: CircularProgressIndicator(
                          color: secondaryColor,
                          strokeWidth: 3,
                        ),
                      ),
                      backgroundColor: Colors.white,
                      radius: 35,
                      backgroundImage: AssetImage("assets/appLogo1.png")),
                )),
              )
            ],
          ),
          ),
    );
  }
}
