import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';

import 'email_view.dart';
import 'utils.dart';

class LoginView extends StatefulWidget {
  final List<ProvidersTypes> providers;
  final bool passwordCheck;
  final String twitterConsumerKey;
  final String twitterConsumerSecret;
  final Widget loading;

  LoginView({
    Key key,
    @required this.providers,
    this.passwordCheck,
    this.twitterConsumerKey,
    this.twitterConsumerSecret,
    this.loading,
  }) : super(key: key);

  @override
  _LoginViewState createState() => new _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<ProvidersTypes, ButtonDescription> _buttons;
  bool loading = false;

  _handleEmailSignIn() async {
    String value = await Navigator.of(context)
        .push(new MaterialPageRoute<String>(builder: (BuildContext context) {
      return new EmailView(widget.passwordCheck, _auth);
    }));

    if (value != null) {
      _followProvider(value);
    }
  }

  _handleGoogleSignIn() async {
    startLoading();
    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      if (googleAuth.accessToken != null) {
        try {
          AuthCredential credential = GoogleAuthProvider.getCredential(
              idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
          FirebaseUser user = await _auth.signInWithCredential(credential);
          print(user);
        } catch (e) {
          showErrorDialog(context, e.details);
        }
      }
    }
    stopLoading();
  }

  _handleFacebookSignin() async {
    startLoading();
    FacebookLoginResult result =
        await facebookLogin.logInWithReadPermissions(['email']);
    if (result.accessToken != null) {
      try {
        AuthCredential credential = FacebookAuthProvider.getCredential(
            accessToken: result.accessToken.token);
        FirebaseUser user = await _auth.signInWithCredential(credential);
        print(user);
      } catch (e) {
        if (e?.code == 'ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL') {
          showErrorDialog(context,
              'This account already exists but a different login method was used.\n\nPlease try logging in via the original login method.');
        } else {
          showErrorDialog(
              context,
              'Oops, something went wrong.\n\nError code: ' + e?.code ??
                  e.toString());
        }
      }
    }
    stopLoading();
  }

  @override
  Widget build(BuildContext context) {
    _buttons = {
      ProvidersTypes.facebook:
          providersDefinitions(context)[ProvidersTypes.facebook]
              .copyWith(onSelected: _handleFacebookSignin),
      ProvidersTypes.google:
          providersDefinitions(context)[ProvidersTypes.google]
              .copyWith(onSelected: _handleGoogleSignIn),
      ProvidersTypes.email: providersDefinitions(context)[ProvidersTypes.email]
          .copyWith(onSelected: _handleEmailSignIn),
    };

    return Container(
      child: loading
          ? widget.loading != null
              ? widget.loading
              : Align(
                  child: CircularProgressIndicator(),
                  alignment: Alignment.topCenter,
                )
          : ListView(
              children: widget.providers.map((p) {
                return Container(
                    padding: const EdgeInsets.symmetric(vertical: 0.0),
                    child: _buttons[p] ?? Container());
              }).toList(),
            ),
    );
  }

  void _followProvider(String value) {
    ProvidersTypes provider = stringToProvidersType(value);
    if (provider == ProvidersTypes.facebook) {
      _handleFacebookSignin();
    } else if (provider == ProvidersTypes.google) {
      _handleGoogleSignIn();
    }
  }

  void startLoading() {
    setState(() {
      loading = true;
    });
  }

  void stopLoading() {
    setState(() {
      loading = false;
    });
  }
}
