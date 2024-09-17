import 'package:flutter/material.dart';
import 'package:surveyapp/screens/Dashboard.dart';
import 'package:surveyapp/screens/Login.dart';
import 'package:surveyapp/screens/Form.dart';
import 'package:surveyapp/util/shared_preference_helper.dart';
import 'package:surveyapp/util/constant.dart' as constant;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferencesHelper prefs =
      await SharedPreferencesHelper.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.prefs});
  final SharedPreferencesHelper prefs;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final String? userAPIKey = prefs.getString(constant.apiKey);
    return MaterialApp(
      title: 'Survey',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromRGBO(40, 49, 112, 1)),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        Login.routeName: (context) => const Login(),
        FormPage.routeName: (context) => const FormPage(),
        DashboardPage.routeName: (context) => const DashboardPage()
      },
      initialRoute:
          userAPIKey == null ? Login.routeName : DashboardPage.routeName,
    );
  }
}
