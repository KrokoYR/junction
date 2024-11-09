import 'package:fin_zero_id/log.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _tag = 'prefs_service';

class PrefsService {
  late final SharedPreferences _prefs;

  final _idKey = "ID";
  final _publicKey = "PUBLIC_KEY";
  final _privateKey = "PRIVATE_KEY";

  Future<void> init() async {
    Log.d(_tag, 'init');

    _prefs = await SharedPreferences.getInstance();
  }

  String? getId() {
    return _prefs.getString(_idKey);
  }

  Future<bool> setId(String? id) {
    if (id == null) {
      return _prefs.remove(_idKey);
    } else {
      return _prefs.setString(_idKey, id);
    }
  }

  String? getPublicKey() {
    return _prefs.getString(_publicKey);
  }

  Future<bool> setPublicKey(String? publicKey) {
    if (publicKey == null) {
      return _prefs.remove(_publicKey);
    } else {
      return _prefs.setString(_publicKey, publicKey);
    }
  }

  String? getPrivateKey() {
    return _prefs.getString(_privateKey);
  }

  Future<bool> setPrivateKey(String? privateKey) {
    if (privateKey == null) {
      return _prefs.remove(_privateKey);
    } else {
      return _prefs.setString(_privateKey, privateKey);
    }
  }
}
