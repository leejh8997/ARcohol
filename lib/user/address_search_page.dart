import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class AddressSearchPage extends StatefulWidget {
  const AddressSearchPage({super.key});

  @override
  State<AddressSearchPage> createState() => _AddressSearchPageState();
}

class _AddressSearchPageState extends State<AddressSearchPage> {
  late InAppWebViewController webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('주소 검색')),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri('https://postcode.map.daum.net'),
        ),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            javaScriptEnabled: true,
          ),
          android: AndroidInAppWebViewOptions(
            useHybridComposition: true,
          ),
          ios: IOSInAppWebViewOptions(
            allowsInlineMediaPlayback: true,
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
        onLoadStop: (controller, url) async {
          await controller.evaluateJavascript(source: """
            new daum.Postcode({
              oncomplete: function(data) {
                window.flutter_inappwebview.callHandler('onAddressSelected', [data.address]);
              }
            }).open();
          """);
        },
      ),
    );
  }
}
