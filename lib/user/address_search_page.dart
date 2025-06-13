import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class AddressSearchPage extends StatefulWidget {
  const AddressSearchPage({super.key});

  @override
  State<AddressSearchPage> createState() => _AddressSearchPageState();
}

class _AddressSearchPageState extends State<AddressSearchPage> {
  InAppWebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('주소 검색')),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri('https://arcohol-20250609.web.app/kakao_postcode.html'),
        ),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            javaScriptEnabled: true,
            javaScriptCanOpenWindowsAutomatically: true,
            useShouldOverrideUrlLoading: true,
          ),
          android: AndroidInAppWebViewOptions(
            useHybridComposition: true,
          ),
        ),
        onWebViewCreated: (controller) {
          webViewController = controller;
          controller.addJavaScriptHandler(
            handlerName: 'onAddressSelected',
            callback: (args) {
              Navigator.pop(context, args[0]);
            },
          );
        },

        /// ✅ 팝업 창을 수동으로 열어주는 처리 (중요!)
        onCreateWindow: (controller, createWindowRequest) async {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: SizedBox(
                width: double.infinity,
                height: 500,
                child: InAppWebView(
                  windowId: createWindowRequest.windowId,
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                      javaScriptEnabled: true,
                    ),
                  ),
                ),
              ),
            ),
          );
          return true;
        },
      ),
    );
  }
}
