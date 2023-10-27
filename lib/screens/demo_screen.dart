import 'package:flutter/material.dart';
import 'package:base/api/payos_api.dart';
import 'package:base/widgets/input.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() {
    return _DemoScreen();
  }
}

class _DemoScreen extends State<DemoScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isLoading = false;
  var _isLoading2 = false;

  var _name = "Mì tôm Hảo Hảo ly";
  var _cost = "1000";
  var _description = "Thanh toan don hang";

  Future<void> navigatePaymentScreen() async {
    try {
      setState(() => _isLoading = true);

      var res = await createPaymentLink({
        "description": _description,
        "productName": _name,
        "price": _cost,
        "returnUrl": "app://payosdemoflutter/result",
        "cancelUrl": "app://payosdemoflutter/result",
      });
      if (res["error"] != 0) {
        throw Exception("Gọi API thất bại. Vui lòng thử lại sau!");
      } else {
        final String amount = res["data"]["amount"].toString();
        String orderCode = res["data"]["orderCode"].toString();
        final String accountNumber = res["data"]["accountNumber"].toString();
        final String accountName = res["data"]["accountName"].toString();
        final String description = res["data"]["description"].toString();
        final String qrCode = res["data"]["qrCode"].toString();
        final String bin = res["data"]["bin"].toString();
        if (!context.mounted) return;
        context.go(Uri(path: '/payment', queryParameters: {
          "amount": amount,
          "orderCode": orderCode,
          "accountNumber": accountNumber,
          "accountName": accountName,
          "description": description,
          "qrCode": qrCode,
          "bin": bin
        }).toString());
      }
    } catch (e) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Lỗi"),
            content: Text(e.toString()),
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
    setState(() => _isLoading = false);
  }

  Future<void> openWebBrower() async {
    try {
      setState(() => _isLoading2 = true);

      var res = await createPaymentLink({
        "description": _description,
        "productName": _name,
        "price": _cost,
        "returnUrl": "app://payosdemoflutter/result",
        "cancelUrl": "app://payosdemoflutter/result",
      });
      if (res["error"] != 0) {
        throw Exception("Gọi API thất bại. Vui lòng thử lại sau!");
      } else {
        print(res["data"]["checkoutUrl"]);
        String ur = res["data"]["checkoutUrl"]
            .replaceAll("https://pay.payos.vn", "https://next.pay.payos.vn");
        print(ur);
        final Uri url = Uri.parse(ur);
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        } else {
          throw Exception("Không thể mở liên kết!");
        }
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Lỗi"),
            content: Text(e.toString()),
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
    setState(() => _isLoading2 = false);
  }

  void onChangeName(name) {
    _name = name;
  }

  void onChangeCost(cost) {
    _cost = cost;
  }

  void onChangeDescription(description) {
    _description = description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Center(child: Text('Demo'))),
        body: SingleChildScrollView(
          child: Center(
              child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Input(
                    value: _name,
                    header: "Tên sản phẩm:",
                    label: "Nhập tên sản phẩm",
                    onChange: onChangeName,
                  ),
                  Input(
                    value: _cost,
                    header: "Đơn giá:",
                    label: "Nhập đơn giá",
                    onChange: onChangeCost,
                  ),
                  Input(
                    value: _description,
                    header: 'Nội dung thanh toán:',
                    label: 'Nội dung thanh toán',
                    onChange: onChangeDescription,
                  ),
                  ElevatedButton.icon(
                    icon: _isLoading2
                        ? Container(
                            width: 24,
                            height: 24,
                            padding: const EdgeInsets.all(2.0),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Icon(Icons.payments),
                    onPressed: _isLoading2 ? null : openWebBrower,
                    label: const Text('Đến trang web thanh toán'),
                  ),
                  Text(
                    "Hoặc",
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  ElevatedButton.icon(
                    icon: _isLoading
                        ? Container(
                            width: 24,
                            height: 24,
                            padding: const EdgeInsets.all(2.0),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Icon(Icons.payments),
                    onPressed: _isLoading ? null : navigatePaymentScreen,
                    label: const Text('Đến giao diện thanh toán'),
                  ),
                ],
              ),
            ),
          )),
        ));
  }
}
