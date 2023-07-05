// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
// #docregion platform_imports
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';


void main() => runApp(const MaterialApp(home: WebViewExample()));


class WebViewExample extends StatefulWidget {
  const WebViewExample({super.key});

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
//           onProgress: (int progress) {
//             debugPrint('WebView is loading (progress : $progress%)');
//           },
//           onPageStarted: (String url) {
//             debugPrint('Page started loading: $url');
//           },
//           onPageFinished: (String url) {
//             debugPrint('Page finished loading: $url');
//           },
//           onWebResourceError: (WebResourceError error) {
//             debugPrint('''
// Page resource error:
//   code: ${error.errorCode}
//   description: ${error.description}
//   errorType: ${error.errorType}
//   isForMainFrame: ${error.isForMainFrame}
//           ''');
//           },
        //   onNavigationRequest: (NavigationRequest request) {
        //     debugPrint('allowing navigation to ${request.url}');
        //     return NavigationDecision.navigate;
        //   },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
            if (change.url == 'rocket://fiserve.success') {
                debugPrint('fiserve failure');
                // TODO: route to send screen??

            } else if (change.url == 'rocket://fiserve.failure') {
                debugPrint('fiserve failure');
                // TODO: route to load screen??
            }
          },
        ),
      );
      // handle verification error from the GreenID UI
      
    
    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {

    // final amountCtrl = TextEditingController();

    cardLoad() async {

        final response = await http.post(
            Uri.parse('https://api.staging.rocketremit.com/v3/customer/load/card'),
            headers: <String, String>{
                'X-Auth-Token': 'ACCESS TOKEN',
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode({
                'amount': 5000,
                // 'successUrl': 'rocket://fiserve.success',
                // 'failureUrl': 'rocket://fiserve.failure'
            }),
        );

        if (response.statusCode == 200) {

            final jsonResp = jsonDecode(response.body);

            // form encode the params from the card load response
            final formParams = jsonResp['params'].keys.map((key) => "${Uri.encodeComponent(key)}=${Uri.encodeComponent(jsonResp['params'][key])}").join("&");
            debugPrint(formParams);

            _controller.loadRequest(
                Uri.parse(jsonResp['fiservUrl']),
                method: LoadRequestMethod.post,
                headers: <String, String>{'Content-Type': 'application/x-www-form-urlencoded'},
                body: Uint8List.fromList(formParams.codeUnits),
            );

        } else {
            // then throw an exception.
            throw Exception('Failed to create get fiserv details');
        }
    }

    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        actions: <Widget>[
          Row(
            children: <Widget>[

                // SizedBox(
                //     width: 300,
                //     child: TextField(
                //         controller: amountCtrl,
                //         decoration: InputDecoration(
                //             border: OutlineInputBorder(),
                //             labelText: 'Amount',
                //         ),
                //         keyboardType: TextInputType.number,
                //         // inputFormatters: <TextInputFormatter>[
                //         //      FilteringTextInputFormatter.digitsOnly
                //         // ]
                //     ),
                // ),
                IconButton(
                    icon: const Icon(Icons.payments),
                    onPressed: () => cardLoad()
                ),
            ])
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
