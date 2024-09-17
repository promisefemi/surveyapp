import 'package:flutter/material.dart';
import 'package:surveyapp/screens/Form.dart';
import 'package:surveyapp/screens/Login.dart';
import 'package:surveyapp/util/api.dart';
import 'package:surveyapp/util/shared_preference_helper.dart';
import 'package:surveyapp/util/constant.dart' as constant;
import 'package:surveyapp/util/util.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  static const routeName = '/dashboard';
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic> user = {};
  Map<String, dynamic> dashboardData = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    final pref = await SharedPreferencesHelper.getInstance();
    final Map<String, dynamic>? userD = pref.getMap(constant.userKey);

    if (userD == null) {
      return;
    }
    setState(() {
      user = userD;
      _isLoading = true;
    });
    var response = await Api.instance.getDashboard(user['username']);
    print(response);
    if (response != null) {
      setState(() {
        dashboardData = response['data'];
        _isLoading = false;
      });
    }
  }

  logout() async {
    final prefs = await SharedPreferencesHelper.getInstance();

    showAlert(context, "Are you sure you want to logout", title: "Log out",
        callback: () async {
      await prefs.remove(constant.apiKey);
      await prefs.remove(constant.userKey);

      // Navigator.pushReplacementNamed(context, LoginPage.routeName);
      Navigator.pushNamedAndRemoveUntil(
          context, Login.routeName, (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          actions: [
            ElevatedButton(
              onPressed: () {
                logout();
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(5),
                // fixedSize: const Size(60, 10),
              ),
              child: const Text(
                "log out",
                style: TextStyle(fontSize: 12),
              ),
            )
          ],
          title: Text('Dashboard',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              )),
          automaticallyImplyLeading: false,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(context, FormPage.routeName);
          },
          icon: const Icon(Icons.add),
          label: const Text("New Submission"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        children: [
                          const Text(
                            "Welcome Back",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "${user['first_name'] ?? ""} ${user['last_name'] ?? ""}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text(
                                  "All submission",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  "${dashboardData['total_submissions'] ?? ""}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text(
                                  "Today's submission",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  "${dashboardData['total_submissions'] ?? ""}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
