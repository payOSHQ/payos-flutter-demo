import 'package:flutter/material.dart';
import 'package:base/api/payos_api.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:base/widgets/input.dart';

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
      "returnUrl": "testapp:///result",
      "cancelUrl": "testapp:///result",
    });
    print(res);
    if (res["error"] != 0)
      print("Lỗi");
    else {
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
      body: Center(
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
                        if (!context.mounted) return;
                        late final WebViewController controller;
                        controller = WebViewController()
                          ..setJavaScriptMode(JavaScriptMode.unrestricted)
                          ..setNavigationDelegate(
                            NavigationDelegate(
                              onProgress: (int progress) {},
                              onPageStarted: (String url) {},
                              onPageFinished: (String url) {},
                              onWebResourceError: (WebResourceError error) {},
                              onNavigationRequest: (NavigationRequest request) {
                                Uri uri = Uri.parse(request.url);
                                if (uri.scheme == "testapp") {
                                  context.go(Uri(
                                          path: uri.path,
                                          queryParameters: uri.queryParameters)
                                      .toString());
                                }
                                return NavigationDecision.prevent;
                              },
                            ),
                          )
                          ..loadRequest(
                            Uri.parse(checkoutUrl),
                          );
                        showGeneralDialog(
                          context: context,
                          barrierDismissible: false,
                          barrierLabel: "Modal",
                          transitionDuration: const Duration(milliseconds: 500),
                          pageBuilder: (_, __, ___) {
                            return Scaffold(
                              appBar: AppBar(
                                  title: const Text(
                                    "Trang thanh toán",
                                  ),
                                  leading: IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      }),
                                  elevation: 0.0),
                              backgroundColor: Colors.white.withOpacity(0.90),
                              body: Container(
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Color(0xfff8f8f8),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: WebViewWidget(controller: controller),
                              ),
                            );
                          },
                        );
                        setState(() => _isLoading = false);
                      },
                label: const Text('Đến trang thanh toán'),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
