import 'package:flutter/material.dart';
import 'package:base/widgets/list_item.dart';

class OrderTable extends StatelessWidget {
  OrderTable({Key? key, required this.data}) : super(key: key);

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Mô tả đơn hàng',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Table(
            border: TableBorder.all(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                width: 0.5),
            columnWidths: const <int, TableColumnWidth>{
              0: FixedColumnWidth(100),
              1: FixedColumnWidth(200)
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Mã đơn hàng",
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "#${data["id"]}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ]),
              TableRow(children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Trạng thái"),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(data["status"] == "PAID"
                      ? "Đã thanh toán"
                      : "Chưa thanh toán"),
                ),
              ]),
              TableRow(children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Sản phẩm"),
                ),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ListItem(
                            text:
                                'Tên sản phẩm:  + ${data["items"][0]["name"]}'),
                        ListItem(
                            text: 'Số lượng: ${data["items"][0]["quantity"]}'),
                        ListItem(text: 'Đơn giá: ${data["items"][0]["price"]}'),
                      ],
                    )),
              ]),
              TableRow(children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Tổng tiền	"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("${data["amount"]} VNĐ"),
                ),
              ]),
            ],
          )
        ],
      ),
    );
  }
}
