library flutter_firebase_ui;

import 'package:flutter/material.dart';

import 'login_view.dart';
import 'utils.dart';

export 'utils.dart';

class SignInScreen extends StatefulWidget {
  SignInScreen({
    Key key,
    this.title,
    this.header,
    this.footer,
    this.signUpPasswordCheck,
    this.providers,
    this.color = Colors.white,
    this.backgroundImage,
    this.loading,
  }) : super(key: key);

  final String title;
  final Widget header;
  final Widget footer;
  final Widget loading;
  final List<ProvidersTypes> providers;
  final Color color;
  final bool signUpPasswordCheck;
  final ImageProvider backgroundImage;

  @override
  _SignInScreenState createState() => new _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  Widget get _header => widget.header ?? new Container();
  Widget get _footer => widget.footer ?? new Container();

  bool get _passwordCheck => widget.signUpPasswordCheck ?? false;

  List<ProvidersTypes> get _providers =>
      widget.providers ?? [ProvidersTypes.email];

  @override
  Widget build(BuildContext context) => new Scaffold(
//        appBar: new AppBar(
//          title: new Text(widget.title),
//          elevation: 4.0,
//        ),
        body: new Builder(
          builder: (BuildContext context) {
            return Stack(
              fit: StackFit.expand,
              children: [
                widget.backgroundImage == null
                    ? null
                    : Container(
                        foregroundDecoration:
                            BoxDecoration(color: Colors.black.withOpacity(0.6)),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: widget.backgroundImage,
                            ),
                          ),
                        ),
                      ),
                Container(
                  padding: const EdgeInsets.all(16.0),
//                  decoration: new BoxDecoration(color: widget.color),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _header,
                      Expanded(
                        child: LoginView(
                          providers: _providers,
                          passwordCheck: _passwordCheck,
                          loading: widget.loading,
                        ),
                      ),
                      _footer
                    ],
                  ),
                ),
              ].where((w) => w != null).toList(),
            );
          },
        ),
      );
}
