import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  const Input({
    super.key,
    required this.header,
    required this.label,
    required this.value,
    required this.onChange,
  });

  final String value;
  final String header;
  final String label;
  final Function(void) onChange;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              header,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          TextFormField(
            keyboardType: TextInputType.text,
            controller: TextEditingController(text: value),
            decoration: InputDecoration(
                labelText: label,
                border:
                    const OutlineInputBorder(borderSide: BorderSide(width: 2))),
            style: const TextStyle(fontSize: 15),
            onChanged: (value) {
              // Cập nhật biến name nếu cần
              // name = value;
              onChange(value);
            },
          ),
        ],
      ),
    );
  }
}
