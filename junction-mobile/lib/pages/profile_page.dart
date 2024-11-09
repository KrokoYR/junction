import 'package:fin_zero_id/bottom_wide_button.dart';
import 'package:fin_zero_id/di.dart';
import 'package:fin_zero_id/fin_colors.dart';
import 'package:fin_zero_id/fin_text_style.dart';
import 'package:fin_zero_id/log.dart';
import 'package:fin_zero_id/pages/home_page.dart';
import 'package:fin_zero_id/pages/qr_page.dart';
import 'package:fin_zero_id/services/prefs_service.dart';
import 'package:flutter/material.dart';

const _tag = 'profile_page';

class ProfilePage extends StatefulWidget {
  static const routeName = '/profile';

  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _prefs = di.get<PrefsService>();
  String _id = '';

  @override
  void initState() {
    super.initState();
    _id = _prefs.getId() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _onResetPressed,
                  child: SizedBox(
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Spacer(),
                  Text(
                    "FinZeroID",
                    textAlign: TextAlign.center,
                    style: FinTextStyle.styleH2.copyWith(
                      color: FinColors.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    _id,
                    textAlign: TextAlign.center,
                    style: FinTextStyle.style22.copyWith(
                      color: FinColors.secondaryTextColor,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Spacer(),
                  BottomWideButton(
                    centralText: "Login",
                    centralTextColor: FinColors.primaryTextColor,
                    color: FinColors.accentColor,
                    onPressed: _onContinuePressed,
                    respectBottomSafeArea: true,
                    shimmer: false,
                    loadingColor: FinColors.primaryTextColor,
                  ),
                  SizedBox(height: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onContinuePressed() {
    Log.d(_tag, '_onContinuePressed');

    Navigator.of(context).pushNamed(QrPage.routeName);
  }

  Future<void> _onResetPressed() async {
    Log.d(_tag, '_onResetPressed');

    final prefs = di.get<PrefsService>();
    await prefs.setId(null);

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      HomePage.routeName,
      (route) => false,
    );
  }
}
