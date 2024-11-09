import 'dart:convert';

import 'package:biometric_storage/biometric_storage.dart';
import 'package:cryptography/cryptography.dart';
import 'package:fin_zero_id/log.dart';
import 'package:fin_zero_id/services/prefs_service.dart';

const _tag = 'secrets_service';

class SecretsService {
  SecretsService({
    required PrefsService prefs,
  }) : _prefs = prefs {
    _init();
  }

  final _privateKey = "PRIVATE_KEY";

  final PrefsService _prefs;

  void _init() {
    Log.d(_tag, '_init');
  }

  Future<void> generateKeys() async {
    final algorithm = Ed25519();

    // Generate a key pair
    final keyPair = await algorithm.newKeyPair();
    final publicKey = await keyPair.extractPublicKey();
    final privateKeyBytes = await keyPair.extractPrivateKeyBytes();

    final publicKeyBase64 = base64Encode(publicKey.bytes);
    Log.d(_tag, 'publicKeyBase64: $publicKeyBase64');
    await _prefs.setPublicKey(publicKeyBase64);

    final privateKeyBase64 = base64Encode(privateKeyBytes);
    Log.d(_tag, 'privateKeyBase64: $privateKeyBase64');
    await _prefs.setPrivateKey(privateKeyBase64);

    final store = await BiometricStorage().getStorage(_privateKey);
    await store.write(
      privateKeyBase64,
      promptInfo: PromptInfo(
        androidPromptInfo: AndroidPromptInfo(
          title: 'Authenticate to save your private key',
        ),
      ),
    );
  }

  Future<String?> signWithPrivateKey(String message) async {
    final response = await BiometricStorage().canAuthenticate();
    Log.d(_tag, 'signWithPrivateKey: response = $response');

    if (response != CanAuthenticateResponse.success) return null;

    final store = await BiometricStorage().getStorage(_privateKey);

    String? privateKeyBase64;
    try {
      await store.read(
        promptInfo: PromptInfo(
          androidPromptInfo: AndroidPromptInfo(
            title: 'Authenticate to login with your private key',
          ),
        ),
      );
    } catch (e, stackTrade) {
      Log.e(_tag, 'signWithPrivateKey: e = $e', stackTrace: stackTrade);
      privateKeyBase64 = _prefs.getPrivateKey();
    }
    Log.d(_tag, 'signWithPrivateKey: result = $privateKeyBase64');

    if (privateKeyBase64 == null) {
      return null;
    }

    // Decode the private key
    final privateKeyBytes = base64Decode(privateKeyBase64);
    final algorithm = Ed25519();
    final keyPair = await algorithm.newKeyPairFromSeed(privateKeyBytes);

    // Sign the message
    final signature = await algorithm.sign(
      utf8.encode(message),
      keyPair: keyPair,
    );

    // Return the signature in Base64 format
    final signatureBase64 = base64Encode(signature.bytes);
    Log.d(_tag, 'Signature: $signatureBase64');

    return signatureBase64;
  }
}
