import 'dart:async';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:fin_zero_id/data/verify_response.dart';
import 'package:fin_zero_id/di.dart';
import 'package:fin_zero_id/fin_animations.dart';
import 'package:fin_zero_id/fin_colors.dart';
import 'package:fin_zero_id/fin_text_style.dart';
import 'package:fin_zero_id/gen/assets.gen.dart';
import 'package:fin_zero_id/log.dart';
import 'package:fin_zero_id/pages/profile_page.dart';
import 'package:fin_zero_id/services/api_service.dart';
import 'package:fin_zero_id/services/prefs_service.dart';
import 'package:fin_zero_id/services/secrets_service.dart';
import 'package:flutter/material.dart';

const _tag = 'onboarding_step_4_page';

class OnboardingStep4PageArguments {
  final XFile? idPhoto;
  final String? nfcId;

  OnboardingStep4PageArguments({
    required this.idPhoto,
    required this.nfcId,
  });
}

class OnboardingStep4Page extends StatefulWidget {
  static const routeName = '/onboarding_step_4';

  final OnboardingStep4PageArguments arguments;

  const OnboardingStep4Page({
    super.key,
    required this.arguments,
  });

  @override
  State<OnboardingStep4Page> createState() => _OnboardingStep4PageState();
}

class _OnboardingStep4PageState extends State<OnboardingStep4Page> {
  bool _privateKeyReady = false;
  bool _publicKeyReady = false;
  bool _prepareReady = false;
  bool _uploadReady = false;
  bool _final = false;

  @override
  void initState() {
    super.initState();
    _runSteps();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: AnimatedSwitcher(
            duration: Duration(seconds: 2),
            switchInCurve: FinAnimations.appearCurve,
            switchOutCurve: FinAnimations.disappearCurve,
            child: _final
                ? Center(
                    child: Text(
                      "Welcome to future",
                      style: FinTextStyle.style17.copyWith(
                        color: FinColors.primaryTextColor,
                      ),
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Spacer(),
                      Center(
                        child: Assets.animationLoading.lottie(
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        "One more step",
                        textAlign: TextAlign.center,
                        style: FinTextStyle.styleH2.copyWith(
                          color: FinColors.primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _line(
                        text: "Creating private key",
                        ready: _privateKeyReady,
                        loading: !_privateKeyReady,
                      ),
                      _line(
                        text: "Creating public key",
                        ready: _publicKeyReady,
                        loading: _privateKeyReady,
                      ),
                      _line(
                        text: "Encrypting your data",
                        ready: _prepareReady,
                        loading: _publicKeyReady,
                      ),
                      _line(
                        text: "Publishing public key",
                        ready: _uploadReady,
                        loading: _prepareReady,
                      ),
                      Spacer(),
                      // BottomWideButton(
                      //   centralText: "Continue",
                      //   centralTextColor: FinColors.primaryTextColor,
                      //   color: FinColors.accentColor,
                      //   onPressed: _onContinuePressed,
                      //   respectBottomSafeArea: true,
                      //   shimmer: true,
                      // ),
                      SizedBox(height: 18),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _line({
    required String text,
    required bool ready,
    required bool loading,
  }) {
    return SizedBox(
      height: 40,
      child: BlinkingText(
        text: text,
        ready: ready,
        loading: loading,
      ),
    );
  }

  Future<void> _runSteps() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _privateKeyReady = true;
    });

    await di.get<SecretsService>().generateKeys();

    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _publicKeyReady = true;
    });

    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _prepareReady = true;
    });

    final prefsService = di.get<PrefsService>();
    final apiService = di.get<ApiService>();
    VerifyResponse? response;
    try {
      response = await apiService.post<VerifyResponse>(
        path: '/user/verify',
        data: {
          'video': 'id_card',
          'id_card': 'id_card',
          'public_token': prefsService.getPublicKey(),
        },
        printFullBody: true,
      );
    } catch (e, stackTrace) {
      if (e is DioException) {
        Log.e(
          _tag,
          '_runSteps: realUri = ${e.response?.realUri}, data = ${e.response?.requestOptions.data}, response = ${e.response?.data}, error = $e',
          stackTrace: stackTrace,
        );
      } else {
        Log.e(_tag, 'refresh: e = $e', stackTrace: stackTrace);
      }
    }

    if (response == null) return;

    Log.d(_tag, '_runSteps: response = $response');
    await prefsService.setId(response.verificationId);

    await Future.delayed(Duration(seconds: 3));
    setState(() {
      _uploadReady = true;
    });

    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _final = true;
    });

    await Future.delayed(Duration(seconds: 3));

    if (!mounted) return;

    Navigator.of(context).pushNamed(ProfilePage.routeName);
  }
}

class BlinkingText extends StatefulWidget {
  final String text;
  final bool ready;
  final bool loading;

  const BlinkingText({
    super.key,
    required this.text,
    required this.ready,
    required this.loading,
  });

  @override
  State<BlinkingText> createState() => _BlinkingTextState();
}

class _BlinkingTextState extends State<BlinkingText> {
  String _ellipsis = "";
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.loading) {
      _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        setState(() {
          _ellipsis = _ellipsis.length < 3 ? "$_ellipsis." : "";
        });
      });
    }
  }

  @override
  void didUpdateWidget(BlinkingText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.loading && !widget.loading) {
      _timer?.cancel();
      _ellipsis = '';
    } else if (!oldWidget.loading && widget.loading) {
      _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        setState(() {
          _ellipsis = _ellipsis.length < 3 ? "$_ellipsis." : "";
        });
      });
    }

    if (widget.ready) {
      _timer?.cancel();
      _ellipsis = ' ... ready';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      duration: FinAnimations.duration,
      curve: FinAnimations.onScreenCurve,
      style: FinTextStyle.style17.copyWith(
        color: widget.ready
            ? FinColors.primaryTextColor
            : FinColors.secondaryTextColor,
        fontWeight: FontWeight.normal,
      ),
      child: Text("${widget.text} $_ellipsis"),
    );
  }
}
