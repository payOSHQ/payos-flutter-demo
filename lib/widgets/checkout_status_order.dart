import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:go_router/go_router.dart';

class CheckStatusOrder extends StatefulWidget {
  const CheckStatusOrder({super.key, required this.orderCode});
  final String orderCode;
  @override
  State<CheckStatusOrder> createState() {
    return _CheckStatusOrder();
  }
}

class _CheckStatusOrder extends State<CheckStatusOrder> {
  var _status = false;
  IO.Socket socket = IO.io(dotenv.env['ORDER_URL'], <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false, // Tắt kết nối tự động (nếu cần)
  });

  @override
  void initState() {
    super.initState();
    // Kết nối với máy chủ
    socket.connect();
    socket.emit("joinOrderRoom", widget.orderCode);
    // Lắng nghe sự kiện từ máy chủ
    socket.on("paymentUpdated", (data) async {
      socket.emit("leaveOrderRoom", widget.orderCode);
      if (!mounted) return;
      setState(() => _status = true);
      await Future.delayed(const Duration(seconds: 2), () {
        context.go(Uri(path: '/result', queryParameters: {
          "orderCode": widget.orderCode,
        }).toString());
      });
    });
  }

  @override
  void dispose() {
    // Đóng kết nối khi widget bị hủy
    socket.emit("leaveOrderRoom", widget.orderCode);
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _status
          ? [
              const Icon(
                Icons.check,
                color: Color.fromARGB(255, 9, 201, 34),
              ),
              const SizedBox(
                width: 10,
              ),
              const DefaultTextStyle(
                style: TextStyle(color: Colors.black, fontSize: 14),
                child: Text("Thanh toán đơn hàng thành công"),
              )
            ]
          : [
              LoadingAnimationWidget.fourRotatingDots(
                  color: Colors.purple.shade200, size: 25),
              const SizedBox(
                width: 10,
              ),
              const DefaultTextStyle(
                style: TextStyle(color: Colors.black, fontSize: 14),
                child: Text("Đơn hàng đang chờ thanh toán"),
              )
            ],
    );
  }
}
