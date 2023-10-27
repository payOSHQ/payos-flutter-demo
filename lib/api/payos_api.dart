import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<Map<String, dynamic>> createPaymentLink(
    Map<String, dynamic> formValue) async {
  try {
    final response = await http.post(
      Uri.parse('${dotenv.env['ORDER_URL']}/order/create'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(formValue),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData;
    } else {
      throw Exception('Failed to create payment link');
    }
  } catch (e) {
    return {'error': 1};
  }
}

Future<Map<String, dynamic>> getOrder(String orderId) async {
  try {
    final response = await http.get(
      Uri.parse('${dotenv.env['ORDER_URL']}/order/${orderId.toString()}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData;
    } else {
      throw Exception('Failed to get Order');
    }
  } catch (e) {
    return {'error': 1};
  }
}

Future<Map<String, dynamic>> getBankList() async {
  try {
    final response = await http.get(
      Uri.parse('${dotenv.env['VIETQR_URL']}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData;
    } else {
      throw Exception('Failed to get Order');
    }
  } catch (e) {
    return {'error': 1};
  }
}

Future<Map<String, dynamic>> cancelOrder(String orderId) async {
  try {
    final response = await http.post(
      Uri.parse('${dotenv.env['ORDER_URL']}/order/${orderId.toString()}/cancel'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData;
    } else {
      throw Exception('Failed to cancel Order');
    }
  } catch (e) {
    return {'error': 1};
  }
}
