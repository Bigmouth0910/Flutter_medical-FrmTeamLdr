import 'package:flutter/material.dart';
import 'package:rxphoto/features/patient/bloc/patient_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxphoto/common/routes/routes.dart';
import 'package:rxphoto/features/login/bloc/login_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxphoto/generated/l10n.dart';

class LoginPage extends StatefulWidget {
  LoginPage();
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _usernameController.text = "suju";
    _passwordController.text = "test";
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
  }

  _launchURL() async {
    const url = "https://rxphoto.com/contact/";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientBloc = context.read<PatientBloc>();
    Size size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        // final value = await showDialog<bool>(
        //     context: context,
        //     builder: (context) {
        //       return AlertDialog(
        //         content: Text('Are you sure you want to exit?'),
        //         actions: <Widget>[
        //           TextButton(
        //             child: Text('No'),
        //             onPressed: () {
        //               Navigator.of(context).pop(false);
        //             },
        //           ),
        //           TextButton(
        //             child: Text('Yes'),
        //             onPressed: () {
        //               Navigator.of(context).pop(true);
        //             },
        //           ),
        //         ],
        //       );
        //     });
        return true;
      },
      child: Scaffold(
        body: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state.status == LoginStatus.loginSuccess) {
              patientBloc.add(UserDataSaved(state.user!));
              patientBloc.add(PatientDataRequested(orderBy: 'new'));
              Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.PATIENT_PAGE, (route) => false);
            }
          },
          builder: (context, state) {
            return ScrollConfiguration(
              behavior: MyBehavior(),
              child: SingleChildScrollView(
                child: SizedBox(
                  height: size.height,
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Expanded(
                              child: SizedBox(),
                            ),
                            Expanded(
                              flex: 7,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(0),
                                child: SizedBox(
                                  width: size.width * .9,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Image.asset(
                                        'assets/images/logo.png',
                                        width: 100,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: 15,
                                          bottom: 15,
                                        ),
                                        child: Text(
                                          'MediCam',
                                          style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xffFF90A4),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: 0,
                                          bottom: 15,
                                        ),
                                        child: Text(
                                          S.of(context).login,
                                          style: TextStyle(
                                            fontSize: 35,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xff6B6B6B),
                                          ),
                                        ),
                                      ),
                                      Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: component(
                                              Icons.account_circle_outlined,
                                              S.of(context).userName + '...',
                                              false,
                                              false,
                                              _usernameController)),
                                      // component(
                                      //   Icons.email_outlined,
                                      //   'Email...',
                                      //   false,
                                      //   true,
                                      // ),
                                      component(
                                          Icons.lock_outline,
                                          S.of(context).password + '...',
                                          true,
                                          false,
                                          _passwordController),
                                      // Row(
                                      //   mainAxisAlignment:
                                      //       MainAxisAlignment.spaceAround,
                                      //   children: [
                                      //     RichText(
                                      //       text: TextSpan(
                                      //         text: 'Forgotten password!',
                                      //         style: TextStyle(
                                      //           color: Colors.white,
                                      //         ),
                                      //         recognizer: TapGestureRecognizer()
                                      //           ..onTap = () {
                                      //             HapticFeedback.lightImpact();
                                      //             Fluttertoast.showToast(
                                      //               msg:
                                      //                   'Forgotten password! button pressed',
                                      //             );
                                      //           },
                                      //       ),
                                      //     ),
                                      //     RichText(
                                      //       text: TextSpan(
                                      //         text: 'Create a new Account',
                                      //         style: TextStyle(
                                      //           color: Colors.white,
                                      //         ),
                                      //         recognizer: TapGestureRecognizer()
                                      //           ..onTap = () {
                                      //             HapticFeedback.lightImpact();
                                      //             Fluttertoast.showToast(
                                      //               msg:
                                      //                   'Create a new Account button pressed',
                                      //             );
                                      //           },
                                      //       ),
                                      //     ),
                                      //   ],
                                      // ),
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          if (_usernameController.text == '' ||
                                              _passwordController.text == '')
                                            Fluttertoast.showToast(
                                                msg: S
                                                    .of(context)
                                                    .wrongPassword);
                                          context.read<LoginBloc>().add(
                                              LoginBtnPressed(
                                                  _usernameController.text,
                                                  _passwordController.text));
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(
                                            top: 10,
                                          ),
                                          padding: EdgeInsets.all(15),
                                          width: size.width / 1.25,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: Color(0xffFF91A6),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            S.of(context).login,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 70),
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () {
                                          // HapticFeedback.lightImpact();
                                          // if (_usernameController.text == '' ||
                                          //     _passwordController.text == '')
                                          //   Fluttertoast.showToast(
                                          //       msg:
                                          //           'Please input username and password');
                                          // context.read<LoginBloc>().add(
                                          //     LoginBtnPressed(
                                          //         _usernameController.text,
                                          //         _passwordController.text));
                                        },
                                        child: Container(
                                          width: size.width / 1.25,
                                          alignment: Alignment.center,
                                          // decoration: BoxDecoration(
                                          //   color: Colors.black.withOpacity(.1),
                                          //   borderRadius:
                                          //       BorderRadius.circular(20),
                                          // ),
                                          child: InkWell(
                                            onTap: () async {
                                              final value = await showDialog<
                                                      bool>(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      content: Text(
                                                        S
                                                            .of(context)
                                                            .sureToContact,
                                                        style: TextStyle(
                                                            fontSize: 20),
                                                      ),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          child: Text(
                                                              S
                                                                  .of(context)
                                                                  .cancel,
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xffFF91A6),
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(false);
                                                          },
                                                        ),
                                                        TextButton(
                                                          child: Text(
                                                            S.of(context).go,
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xffFF91A6),
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(true);
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  });
                                              if (value!) {
                                                _launchURL();
                                              }
                                            },
                                            child: Text(
                                              S.of(context).ContactUs,
                                              style: TextStyle(
                                                color: Color(0xff6B6B6B),
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                  width: size.width / 1.25,
                                  margin: EdgeInsets.only(top: 10),
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'V 1.0',
                                    style: TextStyle(
                                        color: Color(0xffFF91A6), fontSize: 14),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget component(IconData icon, String hintText, bool isPassword,
      bool isEmail, TextEditingController controller) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width / 1.25,
      alignment: Alignment.center,
      padding: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 1, color: Color(0xffFF91A6))),
      child: TextField(
        style: TextStyle(color: Color(0xffFF91A7), fontSize: 20),
        obscureText: isPassword,
        controller: controller,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Color(0xffFF91A7),
            size: 35,
          ),
          border: InputBorder.none,
          hintMaxLines: 1,
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 20,
            color: Color(0xffBFBFBF),
          ),
        ),
      ),
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
    BuildContext context,
    Widget child,
    AxisDirection axisDirection,
  ) {
    return child;
  }
}
