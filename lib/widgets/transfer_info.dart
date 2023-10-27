import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TransferInfo extends StatelessWidget {
  const TransferInfo({
    super.key,
    required this.accountNumber,
    required this.amount,
    required this.description,
  });
  final String accountNumber;
  final String amount;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Column(
          children: [
            FieldTransferInfo(
              text: accountNumber,
              label: "Số tài khoản",
            ),
            FieldTransferInfo(
              text: "$amount vnd",
              label: "Số tiền chuyển khoản",
            ),
            FieldTransferInfo(
              text: description,
              label: "Nội dung chuyển khoản",
            ),
          ],
        ),
      ),
    );
  }
}

class FieldTransferInfo extends StatefulWidget {
  const FieldTransferInfo({
    super.key,
    required this.label,
    required this.text,
  });

  final String label;
  final String text;
  @override
  State<StatefulWidget> createState() {
    return _FieldTransferInfo();
  }
}

class _FieldTransferInfo extends State<FieldTransferInfo> {
  var isClick = false;
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: Color.fromARGB(255, 168, 161, 161), width: 0.5))),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 138, 138, 138),
                        fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  // ignore: unnecessary_string_interpolations
                  Text(
                    widget.text,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: () async {
                  setState(() => isClick = true);
                  await Clipboard.setData(ClipboardData(text: widget.text));
                  await Future.delayed(const Duration(seconds: 2));
                  setState(() => isClick = false);
                },
                child: isClick
                    ? const Icon(
                        Icons.check,
                      )
                    : const Text(
                        "Sao chép",
                        style: TextStyle(fontSize: 13),
                      ),
              ),
            )
          ],
        ));
  }
}
