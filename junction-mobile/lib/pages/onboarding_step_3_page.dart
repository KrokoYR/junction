import 'dart:async';

import 'package:camera/camera.dart';
import 'package:fin_zero_id/fin_animations.dart';
import 'package:fin_zero_id/fin_colors.dart';
import 'package:fin_zero_id/fin_text_style.dart';
import 'package:fin_zero_id/gen/assets.gen.dart';
import 'package:fin_zero_id/log.dart';
import 'package:fin_zero_id/pages/onboarding_step_4_page.dart';
import 'package:flutter/material.dart';

const _tag = 'onboarding_step_3_page';

class OnboardingStep3PageArguments {
  final XFile? idPhoto;
  final String? nfcId;

  OnboardingStep3PageArguments({
    required this.idPhoto,
    required this.nfcId,
  });
}

class OnboardingStep3Page extends StatefulWidget {
  static const routeName = '/onboarding_step_3';

  final OnboardingStep3PageArguments arguments;

  const OnboardingStep3Page({
    super.key,
    required this.arguments,
  });

  @override
  State<OnboardingStep3Page> createState() => _OnboardingStep3PageState();
}

class _OnboardingStep3PageState extends State<OnboardingStep3Page> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;

  bool _done = false;
  String _instructionText = "Align your face here";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _startInstructionCycle();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _cameraController = CameraController(frontCamera, ResolutionPreset.medium);
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
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                children: [
                  // Full-screen camera preview
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(3.14159),
                    // Flip the camera feed horizontally
                    child: SizedBox(
                      width: size.width,
                      height: size.height,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: 100,
                          child: CameraPreview(_cameraController!),
                        ),
                      ),
                    ),
                  ),

                  // Centered oval face alignment frame
                  AnimatedOpacity(
                    duration: FinAnimations.duration,
                    opacity: _done ? 0 : 1,
                    curve: _done
                        ? FinAnimations.disappearCurve
                        : FinAnimations.appearCurve,
                    child: Center(
                      child: Container(
                        width: 250,
                        height: 350,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(200),
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: ClipOval(
                          child: Center(
                            child: Text(
                              _instructionText,
                              textAlign: TextAlign.center,
                              style: FinTextStyle.style17.copyWith(
                                color: FinColors.primaryTextColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Capture button at the bottom
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
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FinColors.accentColor,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _startInstructionCycle() async {
    await Future.delayed(Duration(seconds: 3));

    setState(() {
      _instructionText = "Smile";
    });

    await Future.delayed(Duration(seconds: 3));

    setState(() {
      _instructionText = "Look up";
    });

    await Future.delayed(Duration(seconds: 3));

    setState(() {
      _instructionText = "Validating...";
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

    await Future.delayed(Duration(seconds: 3));

    if (!mounted) return;

    Navigator.of(context).pushNamed(
      OnboardingStep4Page.routeName,
      arguments: OnboardingStep4PageArguments(
        idPhoto: widget.arguments.idPhoto,
        nfcId: widget.arguments.nfcId,
      ),
    );
  }
}
