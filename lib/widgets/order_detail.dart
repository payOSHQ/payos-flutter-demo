import 'package:flutter/material.dart';

class OrderDetail extends StatelessWidget {
  const OrderDetail({Key? key, required this.items}) : super(key: key);
  final dynamic items;
  List<dynamic> renderItems(List<dynamic> items) {
    return items.map((dynamic item) {
      return TableRow(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("${item["name"]}"),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "${item["price"]}",
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "${item["quantity"]}",
            textAlign: TextAlign.center,
          ),
        ),
      ]);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(5),
        child: Table(
          border: TableBorder.all(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              width: 0.5),
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1)
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            const TableRow(children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Tên",
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Giá trị",
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  // "#${res?['data']?['id']}",
                  "Số lượng",
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ]),
            ...renderItems(items)
          ],
        ));
  }
}
