import 'package:flutter/material.dart';
import 'package:base/api/payos_api.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:base/widgets/transfer_info.dart';
import 'package:base/widgets/order_detail.dart';
import 'package:screenshot/screenshot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:typed_data';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PaymentSreen extends StatefulWidget {
  const PaymentSreen({
    super.key,
    required this.orderCode,
    required this.accountNumber,
    required this.accountName,
    required this.amount,
    required this.bin,
    required this.description,
    required this.qrCode,
  });
  final String orderCode;
  final String accountNumber;
  final String accountName;
  final String amount;
  final String description;
  final String qrCode;
  final String bin;
  @override
  State<StatefulWidget> createState() {
    return _PaymentSreen();
  }
}

class _PaymentSreen extends State<PaymentSreen> {
  final _screenshotController = ScreenshotController();
  //socket
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
      Fluttertoast.showToast(
          msg: "Thanh toán thành công!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: const Color.fromARGB(255, 192, 192, 192),
          textColor: const Color.fromARGB(255, 61, 61, 61),
          fontSize: 16.0);
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      context.go(Uri(path: '/result', queryParameters: {
        "orderCode": widget.orderCode,
      }).toString());
    });
  }

  @override
  void dispose() {
    // Đóng kết nối khi widget bị hủy
    socket.emit("leaveOrderRoom", widget.orderCode);
    socket.disconnect();
    super.dispose();
  }

  void cancelOrderClick() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Hủy thanh toán",
            textAlign: TextAlign.center,
          ),
          content: const Text(
            "Quý khách có muốn hủy giao dịch này?",
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng thông báo
              },
              child: const Text(
                "Đóng",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                //Thoát phòng
                socket.emit("leaveOrderRoom", widget.orderCode);
                cancelOrder(widget.orderCode);
                if (!mounted) return;
                context.go(Uri(path: '/result', queryParameters: {
                  "orderCode": widget.orderCode,
                }).toString());
              },
              child: const Text(
                "Xác nhận hủy",
                style: TextStyle(color: Color.fromARGB(255, 192, 71, 62)),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _captureAndSaveQRCode() async {
    final permissionStatus = await Permission.storage.status;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    //Yêu cầu quyền lưu ảnh ở điện thoại
    if (androidInfo.version.sdkInt >= 33) {
      await Permission.photos.request();
    } else {
      if (permissionStatus.isDenied) {
        // Here just ask for the permission for the first time
        await Permission.storage.request();

        // I noticed that sometimes popup won't show after user press deny
        // so I do the check once again but now go straight to appSettings
        if (permissionStatus.isDenied) {
          await openAppSettings();
        }
      } else if (permissionStatus.isPermanentlyDenied) {
        // Here open app settings for user to manually enable permission in case
        // where permission was permanently denied
        await openAppSettings();
      } else {
        // Do stuff that require permission here
      }
    }
    //Thực hiện lưu ảnh
    final Uint8List? image = await _screenshotController.capture();
    if (image != null) {
      final result = await ImageGallerySaver.saveImage(image,
          name:
              "${widget.accountNumber}_${widget.bin}_${widget.amount}_${widget.orderCode}_Qrcode.png");
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Lưu ảnh thành công!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Đóng thông báo
                },
                child: const Text("Đóng"),
              ),
            ],
          );
        },
      );
    } else {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Lỗi"),
            content: const Text("Lưu ảnh thất bại"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Đóng thông báo
                },
                child: const Text("Đóng"),
              ),
            ],
          );
        },
      );
    }
  }

  Future<Map<String, dynamic>> fetchData() async {
    // await Future.delayed(Duration(seconds: 2));
    var order = await getOrder(widget.orderCode);
    var bankList = await getBankList();

    List<Map<String, dynamic>> bankListAsMaps =
        List<Map<String, dynamic>>.from(bankList["data"]);
    Map<String, dynamic> matchedBank =
        bankListAsMaps.firstWhere((bank) => bank["bin"] == widget.bin);
    return {"order": order, "bank": matchedBank};
  }

  int calculateSumAmount(List<dynamic> items) {
    //Tính toán ở đây
    return 1000;
  }

  void onPressedQrImage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 131, 131, 131),
                      ),
                      textAlign: TextAlign.center,
                      child: Text(
                          "Sử dụng một Ứng dụng Ngân hàng bất kỳ để quét mã VietQR."),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(40),
                      child: Screenshot(
                        controller: _screenshotController,
                        child: Container(
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 223, 219, 231),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            child: QrImageView(
                              data: widget.qrCode,
                              version: QrVersions.auto,
                              dataModuleStyle: const QrDataModuleStyle(
                                  color: Color.fromRGBO(37, 23, 78, 1),
                                  dataModuleShape: QrDataModuleShape.circle),
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: Colors.black,
                              ),
                            )),
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300)),
                          onPressed: () async {
                            await _captureAndSaveQRCode();
                          },
                          icon: const Icon(
                            Icons.downloading,
                          ),
                          label: const Text("Tải về")),
                      const SizedBox(
                        width: 20,
                      ),
                      OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300)),
                          onPressed: () {},
                          icon: const Icon(
                            Icons.share,
                          ),
                          label: const Text("Chia sẻ")),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.fromLTRB(40, 0, 40, 0)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Đóng"))
                ],
              ),
            ),
          ),
        );
      },
    );
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
          } else if (snapshot.hasError || res?["order"]["error"] != 0) {
            //Xử lý lỗi gọi Api ở đây
            return Text('Lỗi: ${snapshot.error}');
          }
          return Scaffold(
              body: SafeArea(
            child: SingleChildScrollView(
                child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chi tiết đơn hàng',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  OrderDetail(
                    items: res?["order"]["data"]["items"],
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 15, 10),
                      child: Text(
                        "Tổng tiền:      ${calculateSumAmount(res?["order"]["data"]["items"])} vnd",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                  const Text(
                    "Thông tin chuyển khoản",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromARGB(
                                255, 168, 161, 161), // Màu của border
                            width: 0.5, // Độ rộng của border
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            color: const Color.fromARGB(255, 130, 147, 240),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: Row(
                                children: [
                                  Image.network("${res?["bank"]["logo"]}",
                                      width: 100),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("${res?["bank"]["name"]}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: null),
                                      const SizedBox(height: 3),
                                      Text(
                                        // ignore: unnecessary_string_interpolations
                                        "${widget.accountName}",
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          TransferInfo(
                            accountNumber: widget.accountNumber,
                            amount: widget.amount,
                            description: widget.description,
                          ),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                            child: Text(
                              "Mở App Ngân hàng bất kỳ để quét mã VietQR hoặc chuyển khoản chính xác nội dung bên trên",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(0),
                                  backgroundColor:
                                      const Color.fromARGB(255, 223, 219, 231),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  )),
                              onPressed: onPressedQrImage,
                              child: QrImageView(
                                data: widget.qrCode,
                                version: QrVersions.auto,
                                size: 200,
                                dataModuleStyle: const QrDataModuleStyle(
                                    color: Color.fromRGBO(37, 23, 78, 1),
                                    dataModuleShape: QrDataModuleShape.circle),
                                eyeStyle: const QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: Colors.black,
                                ),
                              )),
                          Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: 'Lưu ý : Nhập chính xác nội dung ',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: widget.description,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const TextSpan(text: ' khi chuyển khoản!'),
                                  ],
                                ),
                              )),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                                onPressed: cancelOrderClick,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple.shade400,
                                  // Màu nền
                                ),
                                child: const Text(
                                  "Hủy thanh toán",
                                  style: TextStyle(color: Colors.white),
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ));
        });
  }
}
