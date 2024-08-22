import 'dart:convert';

import 'package:mobile/common/urls.dart';
import 'package:mobile/data/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:d_method/d_method.dart';
class UserSource {
  /// '${URLs.host}/users'
  static const _baseURL = '${URLs.host}/users';
  
  static Future<User?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseURL/login'),
        body: jsonEncode({
          'email': email,
          'password': password
        })
      );
      DMethod.logResponse(response);

      if(response.statusCode == 200) {
        Map resBody = jsonDecode(response.body);
        return User.formJson(Map.from(resBody));
      }
      return null;
    } catch (e) {
      DMethod.log(e.toString(),colorCode: 1);
      return null;
    }
  }

  static Future<bool> addEmployee(String name, String email) async {
    try {
      final response = await http.post(
        Uri.parse(_baseURL),
        body: jsonEncode({
          'name': name,
          'email': email
        })
      );
      DMethod.logResponse(response);

      return response.statusCode == 201;
    } catch (e) {
      DMethod.log(e.toString(),colorCode: 1);
      return false;
    }
  }

  static Future<bool> delete(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseURL/$userId'),
      );
      DMethod.logResponse(response);

      return response.statusCode == 200;
    } catch (e) {
      DMethod.log(e.toString(),colorCode: 1);
      return false;
    }
  }

  static Future<List<User>?> getEmployee(String email, String password) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseURL/employee'),
      );
      DMethod.logResponse(response);

      if(response.statusCode == 200) {
        List resBody = jsonDecode(response.body);
        return resBody.map((e) => User.formJson(Map.from(e))).toList();
      }
      return null;
    } catch (e) {
      DMethod.log(e.toString(),colorCode: 1);
      return null;
    }
  }
}