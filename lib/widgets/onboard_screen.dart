import 'package:bengaliallinone/constants.dart';
import 'package:bengaliallinone/utility/size_config.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class OnBaordScreen extends StatefulWidget {
  @override
  _OnBaordScreenState createState() => _OnBaordScreenState();
}

final _controller = PageController(
  initialPage: 0,
);

int _currentPage = 0;

List<Widget> _pages = [
  Column(
    children: [
      Expanded(
          child:
              Container(width: 200, child: Image.asset('assets/Home-Tab.png'))),
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text.rich(
          TextSpan(
              text: 'We Are ',
              style: kPageViewTextStyle.copyWith(color: Colors.white),
              children: <InlineSpan>[
                TextSpan(
                  text: 'Matrix Media',
                  style: kPageViewTextStyle.copyWith(color: primaryColor),
                  recognizer: new TapGestureRecognizer()
                    ..onTap = () => Container(),
                )
              ]),
          textAlign: TextAlign.center,
        ),
      ),
    ],
  ),
  Column(
    children: [
      Expanded(
          child: Container(
              width: SizeConfig.screenWidth! * 0.9, child: Image.asset('assets/audiobook-1.png'))),
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text('Portfolio that speaks',
            style: kPageViewTextStyle.copyWith(color: Colors.white), textAlign: TextAlign.center),
      ),
    ],
  ),
  Column(
    children: [
      Expanded(
          child: Container(
              width: SizeConfig.screenWidth, child: Image.asset('assets/testimonial-newone.png'))),
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text("Client's Speak",
            style: kPageViewTextStyle.copyWith(color: Colors.white), textAlign: TextAlign.center),
      ),
    ],
  ),
];

class _OnBaordScreenState extends State<OnBaordScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView(
            controller: _controller,
            children: _pages,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
          ),
        ),
        SizedBox(
          height: 10,
        ),
        DotsIndicator(
          dotsCount: _pages.length,
          position: _currentPage.toDouble(),
          decorator: DotsDecorator(
              size: const Size.square(9.0),
              activeSize: const Size(22.0, 9.0),
              activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
              activeColor: primaryColor),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
