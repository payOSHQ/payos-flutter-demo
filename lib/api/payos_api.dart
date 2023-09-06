import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<Map<String, dynamic>> createPaymentLink(
    Map<String, dynamic> formValue) async {
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
}

Future<Map<String, dynamic>> getOrder(String orderId) async {
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
}
