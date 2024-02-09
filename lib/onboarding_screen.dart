import 'package:avaremp/storage.dart';
import 'package:flutter/material.dart';
import 'main_screen.dart';

import 'package:introduction_screen/introduction_screen.dart';


class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  OnBoardingScreenState createState() => OnBoardingScreenState();
}

class OnBoardingScreenState extends State<OnBoardingScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/images/$assetName', width: width);
  }

  Widget _buildFullscreenImage(String assetName) {
    return Image.asset('assets/images/$assetName', fit: BoxFit.cover, height: double.infinity, width: double.infinity, alignment: Alignment.center,);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.blueAccent,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,
      allowImplicitScrolling: false,
      pages: [
        PageViewModel(
          title: "Welcome to AvareMP!",
          body: "This introduction will show you the necessary steps to operate the app.",
          image: _buildFullscreenImage('intro.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Internet",
          body: "Connect this device to the Internet.\nOn the Wi-Fi setting, choose the Wi-Fi network you want, connect to it.\nMake sure the Internet is available on this network.",
          image: _buildImage('wifi.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Sign the Terms of Use",
          bodyWidget: Column(children: [
            const Text(
                """
This is not an FAA certified GPS. You must assume this software will fail when life and/or property are at risk. The authors of this software are not liable for any injuries to persons, or damages to aircraft or property including Android devices, related to its use.

** What Information We Collect **

The Apps4Av online service collects identifiable account set-up information in the form of account username (e-mail address). This information must be provided in order to register and use our platform. The email information we collect is used for internal verification to complete registrations / transactions, ensure appropriate legal use of the service, provide notification to users about updates to the service, provide notification to users about content upgrade, and help provide technical support to our users. The privacy of your personal information is very important to us. We will delete all your information from our records when you unregister from the online service.

** Sharing Your Personal Information **

We do not sell or share your personal information to third parties for marketing purposes unless you have granted us permission to do so. We will ask for your permission before we use or share your information for any purpose other than the reason you provided it or as otherwise provided by this document. We may also respond to subpoenas, court orders or legal process by disclosing all your information available to us, if required to do so.

** Security **

We utilize generally accepted security measures (such as encryption / HTTPS) to protect against the misuse or unauthorized disclosure of any personal information you submit to us. However, like other Internet sites, we cannot guarantee that it is completely secure from people who might attempt to evade security measures or intercept transmissions over the Internet.

** Enforcement **

If you believe for any reason that we have not followed these privacy principles, please contact us at apps4av@gmail.com and we will act promptly to investigate, correct as appropriate, and advise you of the correction. Please identify the issue as a Privacy Policy concern in your communication to apps4av@gmail.com.

** Register/Sign This Document **

The development team for this free aviation app is dedicated to empowering pilots with helpful free, open source, ad-free, and safe tools. To that end we have decided to require anonymous Registration of users in order to:
 * Advise users immediately in the event we discover any errors in the app or in the FAA materials we process and provide to our users at no charge.
 * Begin offering additional features useful to pilots, such as local airport info and attractions provided by pilots.
 * Enable the potential for future features such as direct anonymous but verified communication between users or devices such as sharing Waypoints, Tracks, and Plans.
 * Ensure that you assume all liability for your use of our free tools more conveniently, without the need to click an agreement at every launch of the app.
 * File flight plans with the FAA.

Do you agree to ALL the above Terms, Conditions, and Privacy Policy? By clicking "Register" below, you agree to, and sign for ALL the above "Terms, Conditions, and Privacy Policy".
"""
            ),
            TextButton(onPressed: () {
              setState(() {
                Storage().settings.setSign(true);
              });},
              child: const Text("Register"),
            ),
            Text(Storage().settings.isSigned() ? "You have signed the document." : "You have not signed this document.")
          ]),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "GPS",
          bodyWidget: Column(children:[
            const Text("Make sure you are in an area where GPS signals are strong."),
            Storage().gpsNotPermitted ? const Text("Make sure the app has permissions to use this device's GPS.") : Container(),
            Storage().gpsNotPermitted ? TextButton(onPressed: () {  }, child: const Text("GPS Permissions"),) : Container(),
            Storage().gpsDisabled ? const Text("Make sure the GPS is enabled on this device.") : Container(),
            Storage().gpsDisabled ? TextButton(onPressed: () {  }, child: const Text("Enable GPS")) : Container(),
          ]),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Databases and Aviation Maps",
          bodyWidget: Column(children:[
            const Text("You must download Databases.\nPress the Download button below, then select Databases to show the download icon. Select any other maps you wish to download.\nPress the download button on top right. Wait for the selected items to turn green."),
            TextButton(onPressed: () {
                Navigator.pushNamed(context, "/download");
              },
              child: const Text("Download"),
            )
          ]),
          image: _buildImage('download.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Keep Warnings in Check",
          image: _buildImage('warning.png'),
          body: "Any time you see this red warning icon in the app, click on it for troubleshooting. The app may not work properly when this icon is visible.",
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Join the Forum",
          body: "For 24/7 help, join our forum\napps4av-forum@googlegroups.com.\nPress the Done button to start using the app.\nYou may not exit this introduction till you have signed the Terms of Use.",
          image: _buildFullscreenImage('forum.png'),
          decoration: pageDecoration,
        ),
      ],
      onDone: () {if(Storage().settings.isSigned()) {_onIntroEnd(context);} }, // do not exit till terms is signed
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: true,
      //rtl: true, // Display as right-to-left
      back: const Icon(Icons.arrow_back),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        color: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }
}