import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mediquest_mobile/connectivity/ApiClient.dart';
import 'package:mediquest_mobile/payload/ApiPayload.dart';
import 'package:mediquest_mobile/payload/StudentAuthPayload.dart';
import 'package:mediquest_mobile/screens/LoginScreen.dart';
import 'package:mediquest_mobile/utils/GeneralUtils.dart';
import 'package:mediquest_mobile/utils/SharedPreferncesUtil.dart';

class AuthenticationManager {
  static Future<bool> validateToken(String token) async {
    bool validToken = await ApiClient.validateToken(token: token);
    validToken ? print("valid token") : print("invalid token");
    return validToken;
  }

  Future<StudentAuthPayload> login(String username, String password) async {
    print("logging in");
    StudentAuthPayload authenticationPayload;

    Response response = await ApiClient().login(username, password);
    print(response.statusCode);
    if (response != null &&
        response.body != null &&
        GeneralUtils.isSuccess(response.statusCode)) {
      //decode the data
      print("response not null, decoding login ");
      Map<String, dynamic> data = jsonDecode(response.body.toString());
      ApiPayload payload = ApiPayload.fromJson(data);

      if (payload.success) {
        print("payload success");
        print("converting");
        print(payload.toJson());
        authenticationPayload = StudentAuthPayload.fromJson(payload.payload);
        print(
            "***************************************************************************");

        print(authenticationPayload?.toJson());

        print(
            "***************************************************************************");

        if (authenticationPayload != null) {
          print("login  not null ");
          SharedPreferencesUtil.setAuthToken(
              token: authenticationPayload?.accessToken);
          SharedPreferencesUtil.setCurrentStudent(
              authenticationPayload.student);
        } else {
          print("login null ");
        }
      } else {
        print("payload failed:  " + payload.message);
      }
    } else {
      print("null  response");
    }
    return authenticationPayload;
  }

  static void logout({@required BuildContext context}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey,
          title: Text('Log Out'),
          titleTextStyle:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          content: SingleChildScrollView(
            child: Text(
              'Are you sure you want to log out?',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'No',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                'Yes',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  //  color: HexColor(AppColors.WhiteColor),
                ),
              ),
              onPressed: () {
                print("Sign Out Pressed");
                Navigator.popUntil(context, (route) => route.isFirst);

                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return LoginScreen();
                }));
              },
            ),
          ],
        );
      },
    );
  }
}
