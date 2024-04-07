import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_progress_tracker/app_constants.dart';
import 'package:my_progress_tracker/controllers/Auth_Controller.dart';

class LoginApi {
  static Future<String> login(
      String email, String password, String deviceToken) async {
    final url = Uri.parse('https://reqres.in/api/login');
    final headers = {'Content-Type': 'application/json'};
    final jsonBody = json.encode(
        {'email': email, 'password': password, 'device_token': deviceToken});

    try {
      final response = await http.post(url, headers: headers, body: jsonBody);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final token = responseData['token'] as String;
        Constants.token = responseData['token'] as String;
        await SharedPreferencesHelper.saveUserToken(token);
        return token;
      } else {
        throw Exception('Login failed!');
      }
    } catch (error) {
      rethrow;
    }
  }
}
