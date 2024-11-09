import 'package:fin_zero_id/bottom_wide_button.dart';
import 'package:fin_zero_id/fin_colors.dart';
import 'package:fin_zero_id/fin_text_style.dart';
import 'package:fin_zero_id/gen/assets.gen.dart';
import 'package:fin_zero_id/log.dart';
import 'package:fin_zero_id/pages/onboarding_step_1_page.dart';
import 'package:flutter/material.dart';

const _tag = 'home_page';

class HomePage extends StatefulWidget {
  static const routeName = '/home';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(),
              Assets.animationHomePage.lottie(
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 40),
              Text(
                "FinZeroID",
                textAlign: TextAlign.center,
                style: FinTextStyle.styleH2.copyWith(
                  color: FinColors.primaryTextColor,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Your access point to digital democracy",
                textAlign: TextAlign.center,
                style: FinTextStyle.style22.copyWith(
                  color: FinColors.secondaryTextColor,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Spacer(),
              BottomWideButton(
                centralText: "Continue",
                centralTextColor: FinColors.primaryTextColor,
                color: FinColors.accentColor,
                loadingColor: FinColors.primaryTextColor,
                onPressed: _onContinuePressed,
                respectBottomSafeArea: true,
                shimmer: true,
              ),
              SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }

  void _onContinuePressed() {
    Log.d(_tag, '_onContinuePressed');

    Navigator.of(context).pushNamed(OnboardingStep1Page.routeName);
  }
}
