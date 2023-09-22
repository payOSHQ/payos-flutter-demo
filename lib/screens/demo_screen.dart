import 'package:flutter/material.dart';
import 'package:base/api/payos_api.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:base/widgets/input.dart';
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
  var _name = "Mì tôm Hảo Hảo ly";
  var _cost = "1000";
  var _description = "Thanh toan don hang";
  var checkoutUrl = "";
  Future<void> paymentCheckout() async {
    var res = await createPaymentLink({
      "description": _description,
      "productName": _name,
      "price": _cost,
      "returnUrl": "https://dev.pay.payos.vn/blogs/result",
      "cancelUrl": "https://dev.pay.payos.vn/blogs/result",
    });
    print(res);
    if (res["error"] != 0) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Lỗi"),
            content: const Text("Gọi API thất bại. Vui lòng thử lại sau."),
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
      checkoutUrl = res["data"]["checkoutUrl"];
    }
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
                    onPressed: _isLoading
                        ? null
                        : () async {
                            setState(() => _isLoading = true);
                            await paymentCheckout();
                            if (checkoutUrl != "") {
                              final Uri url = Uri.parse(checkoutUrl);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {
                                // ignore: use_build_context_synchronously
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Lỗi"),
                                      content:
                                          const Text("Không thể mở liên kết"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Đóng thông báo
                                          },
                                          child: const Text("Đóng"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            }
                            setState(() => _isLoading = false);
                          },
                    label: const Text('Đến trang thanh toán'),
                  ),
                ],
              ),
            ),
          )),
        ));
  }
}
