import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  final String text;
  const ListItem({Key? key, required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Căn trên cùng
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.only(
              top: 5), // Khoảng cách giữa dấu đầu dòng và mục
          child: const Icon(Icons.circle,
              size: 4), // Biểu tượng dấu đầu dòng (có thể thay đổi)
        ),
        Expanded(
          child: Text(text),
        ),
      ],
    );
  }
}
