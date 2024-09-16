import "dart:convert";

import "package:flutter/widgets.dart";

import "package:surveyapp/util/constant.dart" as constant;
import "package:surveyapp/util/shared_preference_helper.dart";
import "package:http/http.dart" as http;

// ignore: constant_identifier_names

const BaseUrl = "http://192.168.0.103/surveyapp/api/v1/";
// const BaseUrl = "https://surveyapp.ciphernetsandbox.com.ng/api/v1/";

class Api {
  String _apiKey = '';
  static final Api _instance = Api._internal();

  static Api get instance => _instance;

  Api._internal() {
    _loadApiKey();
  }

  _loadApiKey() async {
    var instance = await SharedPreferencesHelper.getInstance();
    _apiKey = instance.getString(constant.apiKey) ?? '';
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      var decodedResponse = jsonDecode(response.body);
      debugPrint(response.body);
      return decodedResponse;
    } else {
      debugPrint("Request failed with response code: ${response.statusCode}");
      debugPrint("Failed response body ${response.body}");
      //showAlert(context, body)
      return null;
    }
  }

  Future<dynamic> _get(
    String uri,
    Map<String, dynamic> param,
  ) async {
    try {
      await _loadApiKey();
      var parsedUri = Uri.parse("$BaseUrl$uri");

      Map<String, String> headers = {'x-api-key': _apiKey};
      // print(_apiKey);
      if (param.isNotEmpty) {
        parsedUri = parsedUri.replace(queryParameters: param);
      }
      // print(parsedUri);
      var response = await http.get(parsedUri, headers: headers);
      return _handleResponse(response);
    } catch (error) {
      print("Error from try Catch: ${error.toString()}");
      return null;
    }
  }

  Future<dynamic> _post(
    String uri,
    Map<String, dynamic> data,
  ) async {
    try {
      await _loadApiKey();
      var parsedUri = Uri.parse("$BaseUrl$uri");
      Map<String, String> headers = {'x-api-key': _apiKey};
      //  print(parsedUri);
      var response = await http.post(parsedUri, body: data, headers: headers);
      return _handleResponse(response);
    } catch (error) {
      print("Error from try Catch: ${error.toString()}");
      return null;
    }
  }

  Future<Map<String, dynamic>?> login(String username, String password) async {
    var response = await _post(
      "login",
      {'username': username, 'password': password},
    );
    if (response == null) {
      return null;
    }

    return response as Map<String, dynamic>;
  }
}
