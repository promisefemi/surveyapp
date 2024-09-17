import 'package:flutter/material.dart';
import 'package:surveyapp/screens/Dashboard.dart';
import 'package:surveyapp/util/api.dart';
import 'package:surveyapp/screens/Form.dart';
import 'package:surveyapp/util/shared_preference_helper.dart';
import 'package:surveyapp/util/util.dart';
import 'package:surveyapp/util/constant.dart' as constant;

class Login extends StatefulWidget {
  const Login({super.key});
  static const routeName = '/';
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var _username = "";
  var _password = "";
  bool _isLoading = false;

  manageLogin() async {
    print("Username $_username");
    print("Password $_password");

    if (_isLoading) {
      return;
    }

    if (_username == "" || _password == "") {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var response = await Api.instance.login(_username, _password);

      setState(() {
        _isLoading = false;
      });
      if (response == null) {
        showAlert(
          context,
          "Something went wrong, please check your internet connection",
          title: "Error",
        );
        return;
      }

      print(response);

      if (!response['status']) {
        showAlert(context, response['message']);
        return;
      }

      final pref = await SharedPreferencesHelper.getInstance();
      pref.setString(constant.apiKey, response['data']['apiKey']);
      pref.setMap(constant.userKey, response['data']['user']);

      Navigator.pushNamed(context, DashboardPage.routeName);

      return;
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showAlert(
        context,
        "Something went wrong, please check your internet connection",
        title: "Error",
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
          ),
          child: null,
        ),
        Positioned(
          bottom: 10,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Log in',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: "Username",
                      hintStyle: TextStyle(fontSize: 12),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) => {
                      setState(() => _username = value),
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: "Password",
                        hintStyle: TextStyle(fontSize: 12),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) => {
                            setState(() => _password = value),
                          }),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 50),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () => manageLogin(),
                    child: Text(_isLoading ? "Loading..." : "Submit"),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        )
      ]),
    );
  }
}
