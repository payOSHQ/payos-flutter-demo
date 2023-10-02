import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:base/api/payos_api.dart';
import 'package:base/widgets/order_table_demo.dart';
import 'package:base/widgets/payment_field_table.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.orderCode});
  final String orderCode;

  Future<Map<String, dynamic>> fetchData() async {
    // await Future.delayed(Duration(seconds: 2));
    var result = await getOrder(orderCode);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
        future: fetchData(),
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>> snapshot) {
          var res = snapshot.data;
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Hiển thị giao diện khi tác vụ đang chờ.
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.white,
                color: Colors.indigo,
              ),
            );
          } else if (snapshot.hasError || res?["error"] != 0) {
            //Xử lý lỗi gọi Api ở đây
            return Text('Lỗi: ${snapshot.error}');
          }
          return Scaffold(
              appBar: AppBar(title: const Text('Result Screen')),
              body: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Column(
                      children: [
                        if (res!["data"]["id"] != null)
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: "Đơn hàng #",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                                TextSpan(
                                  text: res["data"]["id"].toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (res["data"]["status"] == "PAID")
                                  const TextSpan(
                                    text: " đã được thanh toán",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black),
                                  )
                                else
                                  const TextSpan(
                                    text: " chưa được thanh toán",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black),
                                  ),
                              ],
                            ),
                          )
                        else
                          const Text("Đơn hàng không tìm thấy"),
                        //Order Table
                        OrderTable(data: res["data"]),
                        //Payment Field Table
                        PaymentFieldTable(
                            data: res["data"]!["webhook_snapshot"] != null
                                ? res["data"]!["webhook_snapshot"]!["data"]
                                : {}),
                        ElevatedButton(
                          onPressed: () => context.go('/blogs'),
                          child: const Text('Go back to the Demo screen'),
                        ),
                      ],
                    ),
                  ),
                ),
              ));
        });
  }
}
