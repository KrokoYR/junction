import 'package:camera/camera.dart';
import 'package:fin_zero_id/fin_colors.dart';
import 'package:fin_zero_id/fin_text_style.dart';
import 'package:fin_zero_id/gen/assets.gen.dart';
import 'package:fin_zero_id/log.dart';
import 'package:fin_zero_id/pages/onboarding_step_3_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

const _tag = 'onboarding_step_2_page';

class OnboardingStep2PageArguments {
  final XFile? idPhoto;

  const OnboardingStep2PageArguments({
    required this.idPhoto,
  });
}

class OnboardingStep2Page extends StatefulWidget {
  static const routeName = '/onboarding_step_2';

  const OnboardingStep2Page({
    super.key,
    required this.arguments,
  });

  final OnboardingStep2PageArguments arguments;

  @override
  State<OnboardingStep2Page> createState() => _OnboardingStep2PageState();
}

class _OnboardingStep2PageState extends State<OnboardingStep2Page> {
  String _statusMessage = "Please tap your ID card to the phone";

  @override
  void initState() {
    super.initState();
    _startNfc();
  }

  @override
  void dispose() {
    FlutterNfcKit.finish();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Assets.animationNfc.lottie(),
              const SizedBox(height: 20),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: FinTextStyle.style17.copyWith(
                  color: FinColors.primaryTextColor,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startNfc() async {
    setState(() {
      _statusMessage = "Please tap your ID card to the phone";
    });

    try {
      // Start NFC session and read the card ID
      NFCTag tag = await FlutterNfcKit.poll();
      Log.d(_tag, '_startNfc: tag = ${tag.toJson()}');

      // Here we are accessing the ID of the NFC card/tag
      String cardId = tag.id;

      setState(() {
        _statusMessage = "Card detected! ID: $cardId";
      });

      // End the NFC session after reading
      await FlutterNfcKit.finish();

      await Future.delayed(Duration(seconds: 1));

      if (!mounted) return;

      Navigator.of(context).pushNamed(
        OnboardingStep3Page.routeName,
        arguments: OnboardingStep3PageArguments(
          idPhoto: widget.arguments.idPhoto,
          nfcId: cardId,
        ),
      );
    } catch (e, stackTrace) {
      Log.e(_tag, "_startNfc: e = $e", stackTrace: stackTrace);
      setState(() {
        _statusMessage = "Failed to read card. Please try again.";
      });
    }
  }
}
