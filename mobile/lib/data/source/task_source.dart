import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:mobile/common/urls.dart';
import 'package:mobile/data/models/task.dart';
import 'package:http/http.dart' as http;
import 'package:d_method/d_method.dart';
class TaskSource {
  /// '${URLs.host}/tasks'
  static const _baseURL = '${URLs.host}/tasks';
  

  static Future<(bool, String)> addTask(String title, String description, String dueDate, int userId) async {
    try {
      final response = await http.post(
        Uri.parse(_baseURL),
        body: jsonEncode({
          "title":title,
          "description": description,
          "status": "Queue",
          "dueDate": dueDate,
          "userId": userId,
        })
      );
      DMethod.logResponse(response);

      if(response.statusCode == 201) {
        return (true, "Success add new task");
      }
      if (response.statusCode == 400) {
        return (false, "Email already exists");
      }

      return (false, "Failed add new task");
    } catch (e) {
      DMethod.log(e.toString(),colorCode: 1);
      return (false, "Something went wrong");
    }
  }

  static Future<bool> deleteTask(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseURL/$id')
      );
      DMethod.logResponse(response);

      return response.statusCode == 200;
    } catch (e) {
      DMethod.log(e.toString(),colorCode: 1);
      return false;
    }
  }

  static Future<bool> submitTask(XFile xfile, int id) async {
    try {
      final request = await http.MultipartRequest(
        'PATCH',
        Uri.parse('$_baseURL/$id/submit'),
      )..fields['submitDate'] = DateTime.now().toIso8601String()
      ..files.add(await http.MultipartFile.fromPath('attachment', xfile.path, filename: xfile.name));

      final response = await request.send();

      return response.statusCode == 200;
    } catch (e) {
      DMethod.log(e.toString(),colorCode: 1);
      return false;
    }
  }
  
  static Future<bool> rejectedTask(int id, String reason) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseURL/$id/reject'),
        body: {
          "reason":reason,
          "rejectedDate": DateTime.now().toIso8601String(),
        }
      );
      DMethod.logResponse(response);

      return response.statusCode == 200;
    } catch (e) {
      DMethod.log(e.toString(),colorCode: 1);
      return false;
    }
  }

  static Future<bool> fixTask(int id, int revision) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseURL/$id/fix'),
        body: {
          "revision":revision,
        }
      );
      DMethod.logResponse(response);

      return response.statusCode == 200;
    } catch (e) {
      DMethod.log(e.toString(),colorCode: 1);
      return false;
    }
  }

  static Future<bool> approvedTask(int id,) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseURL/$id/approve'),
        body: {
          "approvedDate": DateTime.now().toIso8601String(),
        }
      );
      DMethod.logResponse(response);

      return response.statusCode == 200;
    } catch (e) {
      DMethod.log(e.toString(),colorCode: 1);
      return false;
    }
  }

  static Future<Task?> findTaskById(int id,) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseURL/$id'),
      );
      DMethod.logResponse(response);

      if(response.statusCode == 200) {
        Map resBody = jsonDecode(response.body);
        return Task.formJson(Map.from(resBody));
      }

      return null;
    } catch (e) {
      DMethod.log(e.toString(),colorCode: 1);
      return null;
    }
  }

  static Future<List<Task>?> needToBeReview() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseURL/review/asc'),
      );
      DMethod.logResponse(response);

      if(response.statusCode == 200) {
        List resBody = jsonDecode(response.body);
        return resBody.map((e) => Task.formJson(Map.from(e))).toList();
      }

      return null;
    } catch (e) {
      DMethod.log(e.toString(),colorCode: 1);
      return null;
    }
  }

  static Future<List<Task>?> progressTask(int userId,) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseURL/progress/$userId'),
      );
      DMethod.logResponse(response);

      if(response.statusCode == 200) {
        List resBody = jsonDecode(response.body);
        return resBody.map((e) => Task.formJson(Map.from(e))).toList();
      }

      return null;
    } catch (e) {
      DMethod.log(e.toString(),colorCode: 1);
      return null;
    }
  }

  static Future<Map?> statisticTask(int userId,) async {
    List listStatus = ["Queue", "Review", "Approved", "Rejected"];
    Map stat = {};
    try {
      final response = await http.get(
        Uri.parse('$_baseURL/statistic/$userId'),
      );
      DMethod.logResponse(response);

      if(response.statusCode == 200) {
        List resBody = jsonDecode(response.body);
        for (String status in listStatus) {
          Map? found = resBody.where((e) => e["status"] == status).firstOrNull;
          stat[status] = found?["total"] ?? 0;
        }
        return stat;
      }

      return null;
    } catch (e) {
      DMethod.log(e.toString(),colorCode: 1);
      return null;
    }
  }

  static Future<List<Task>?> whereUserAndStatus(int userId, String status) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseURL/user/$userId/$status'),
      );
      DMethod.logResponse(response);

      if(response.statusCode == 200) {
        List resBody = jsonDecode(response.body);
        return resBody.map((e) => Task.formJson(Map.from(e))).toList();
      }

      return null;
    } catch (e) {
      DMethod.log(e.toString(),colorCode: 1);
      return null;
    }
  }
  
}