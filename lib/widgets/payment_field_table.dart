import 'package:flutter/material.dart';

/// Flutter code sample for [DataTable].
const Map<String, dynamic> WEBHOOK_FIELD_DESC = {
  "orderCode": "Mã đơn hàng",
  "amount": "Số tiền",
  "description": "Mô tả lệnh chuyển khoản",
  "accountNumber": "Số tài khoản nhận",
  "reference": "Mã tham chiếu",
  "transactionDateTime": "Thời gian",
  "paymentLinkId": "Mã link thanh toán",
  'code': "Mã trạng thái thanh toán",
  "desc": "Mô tả trạng thái",
  'counterAccountBankId': "Mã ngân hàng đối ứng",
  'counterAccountBankName': "Tên ngân hàng đối ứng",
  'counterAccountName': "Tên chủ tài khoản đối ứng",
  'counterAccountNumber': "Số tài khoản đối ứng",
  'virtualAccountName': "Tên chủ tài khoản ảo",
  'virtualAccountNumber': "Số tài khoản ảo",
};

class PaymentFieldTable extends StatelessWidget {
  const PaymentFieldTable({Key? key, required this.data}) : super(key: key);
  final Map<String, dynamic> data;

  @override
  Widget build(
    BuildContext context,
  ) {
    Map<String, dynamic> filteredData = {};

    for (var key in data.keys) {
      var value = data[key];
      if (value is String && value.isNotEmpty) {
        filteredData[key] = value;
      }
    }
    List<DataRow> rows = [];
    for (String key in filteredData.keys) {
      var value = filteredData[key];
      rows.add(
        DataRow(
          cells: <DataCell>[
            DataCell(SizedBox(
                width: 80, //SET width
                child: Text(key))),
            DataCell(SizedBox(width: 150, child: Text(value.toString()))),
            DataCell(SizedBox(width: 80, child: Text(WEBHOOK_FIELD_DESC[key]))),
          ],
        ),
      );
    }
    if (rows.isEmpty) {
      rows.add(const DataRow(cells: <DataCell>[
        DataCell(
          Text(
            "Không có thông tin giao dịch",
            textAlign: TextAlign.center,
          ),
        ),
        DataCell(Text("")),
        DataCell(Text("")),
      ]));
    }
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'DS các trường dữ liệu trong webhook',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        DataTable(
          columns: const <DataColumn>[
            DataColumn(
              label: Expanded(
                child: Text(
                  'Tên',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Giá trị',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Mô tả',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ],
          rows: rows,
          columnSpacing: 20,
        ),
      ],
    );
  }
}
