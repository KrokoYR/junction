import 'package:camera/camera.dart';
import 'package:fin_zero_id/bottom_wide_button.dart';
import 'package:fin_zero_id/fin_animations.dart';
import 'package:fin_zero_id/fin_colors.dart';
import 'package:fin_zero_id/fin_text_style.dart';
import 'package:fin_zero_id/gen/assets.gen.dart';
import 'package:fin_zero_id/log.dart';
import 'package:fin_zero_id/pages/onboarding_step_2_page.dart';
import 'package:flutter/material.dart';

const _tag = 'onboarding_step_1_page';

class OnboardingStep1Page extends StatefulWidget {
  static const routeName = '/onboarding_step_1';

  const OnboardingStep1Page({super.key});

  @override
  State<OnboardingStep1Page> createState() => _OnboardingStep1PageState();
}

class _OnboardingStep1PageState extends State<OnboardingStep1Page> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;

  bool _loading = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;
    _cameraController = CameraController(camera, ResolutionPreset.high);
    _initializeControllerFuture = _cameraController!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            FutureBuilder(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_cameraController!);
                } else {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(FinColors.accentColor),
                    ),
                  );
                }
              },
            ),
            AnimatedOpacity(
              duration: FinAnimations.duration,
              opacity: _loading ? 0 : 1,
              curve: _loading
                  ? FinAnimations.disappearCurve
                  : FinAnimations.appearCurve,
              child: Center(
                child: Container(
                  width: 300,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.transparent,
                  ),
                  child: Center(
                    child: Text(
                      "Place your ID here",
                      style: FinTextStyle.style17.copyWith(
                        color: FinColors.secondaryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            AnimatedOpacity(
              duration: FinAnimations.duration,
              opacity: (_loading && !_done) ? 1 : 0,
              curve: (_loading && !_done)
                  ? FinAnimations.appearCurve
                  : FinAnimations.disappearCurve,
              child: Center(
                child: Text(
                  "Validating...",
                  style: FinTextStyle.style17.copyWith(
                    color: FinColors.primaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            AnimatedOpacity(
              duration: FinAnimations.duration,
              opacity: _done ? 0 : 1,
              curve: _done
                  ? FinAnimations.disappearCurve
                  : FinAnimations.appearCurve,
              child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20, bottom: 18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    BottomWideButton(
                      centralText: "Capture ID",
                      centralTextColor: FinColors.primaryTextColor,
                      color: FinColors.accentColor,
                      onPressed: _loading ? null : _onContinuePressed,
                      respectBottomSafeArea: true,
                      shimmer: false,
                      loading: _loading,
                      loadingColor: FinColors.primaryTextColor,
                    ),
                  ],
                ),
              ),
            ),
            AnimatedOpacity(
              duration: FinAnimations.duration,
              opacity: _done ? 1 : 0,
              curve: _done
                  ? FinAnimations.appearCurve
                  : FinAnimations.disappearCurve,
              child: Center(
                child: Assets.animationSuccess.lottie(
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onContinuePressed() async {
    Log.d(_tag, '_onContinuePressed');

    setState(() {
      _loading = true;
    });

    XFile? image;
    try {
      await _initializeControllerFuture;
      await _cameraController!.pausePreview();
      image = await _cameraController!.takePicture();
    } catch (e, stackTrace) {
      Log.e(_tag, '_onContinuePressed: e = $e', stackTrace: stackTrace);
    }

    await Future.delayed(Duration(seconds: 3));

    setState(() {
      _done = true;
    });

    Log.d(_tag, '_onContinuePressed: image.path = ${image?.path}');
    // if (image == null) return;

    await Future.delayed(Duration(seconds: 3));

    if (!mounted) return;
    Navigator.of(context).pushNamed(
      OnboardingStep2Page.routeName,
      arguments: OnboardingStep2PageArguments(idPhoto: image),
    );
  }
}
