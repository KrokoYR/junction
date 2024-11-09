import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fin_zero_id/data/qr_payload.dart';
import 'package:fin_zero_id/data/serializers.dart';
import 'package:fin_zero_id/data/sign_response.dart';
import 'package:fin_zero_id/di.dart';
import 'package:fin_zero_id/fin_colors.dart';
import 'package:fin_zero_id/fin_text_style.dart';
import 'package:fin_zero_id/log.dart';
import 'package:fin_zero_id/services/api_service.dart';
import 'package:fin_zero_id/services/prefs_service.dart';
import 'package:fin_zero_id/services/secrets_service.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

const _tag = 'qr_page';

class QrPage extends StatefulWidget {
  static const routeName = '/qr';

  const QrPage({super.key});

  @override
  State<QrPage> createState() => _QrPageState();
}

class _QrPageState extends State<QrPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // QR scanner view
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),

          // Centered frame overlay for QR scanning
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Display the result below the scanner view
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: (result != null)
                  ? Text(
                      'QR: ${result!.code}',
                      style: FinTextStyle.style22.copyWith(
                        color: FinColors.primaryTextColor,
                      ),
                    )
                  : Text(
                      'Scan a code',
                      style: FinTextStyle.style22.copyWith(
                        color: FinColors.primaryTextColor,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen(_onScan);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _onScan(Barcode scanData) async {
    Log.d(_tag, '_onScan: scanned = ${scanData.code}');

    // setState(() {
    //   result = scanData;
    // });

    QrPayload? payload;
    try {
      payload = deserializeSync<QrPayload>(jsonDecode(scanData.code!));
    } catch (e, stackTrace) {
      Log.e(_tag, '_onScan: e = $e', stackTrace: stackTrace);
    }
    Log.d(_tag, '_onScan: payload = $payload');
    if (payload == null) return;

    final secretsService = di.get<SecretsService>();
    final apiService = di.get<ApiService>();
    final prefs = di.get<PrefsService>();
    final signature = await secretsService.signWithPrivateKey(
      payload.sessionKey,
    );

    SignResponse? response;
    try {
      response = await apiService.post<SignResponse>(
        path: '/signature-verification',
        data: {
          'verification_id': prefs.getId(),
          'session_key': payload.sessionKey,
          'signature': signature,
        },
        printFullBody: true,
      );
    } catch (e, stackTrace) {
      if (e is DioException) {
        Log.e(
          _tag,
          '_onScan: realUri = ${e.response?.realUri}, data = ${e.response?.requestOptions.data}, response = ${e.response?.data}, error = $e',
          stackTrace: stackTrace,
        );
      } else {
        Log.e(_tag, '_onScan: e = $e', stackTrace: stackTrace);
      }
    }

    Log.d(_tag, '_onScan: response = $response');
    if (response == null) return;

    if (!mounted) return;
    Navigator.of(context).pop();
  }
}
