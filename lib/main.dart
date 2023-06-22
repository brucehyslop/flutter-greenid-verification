// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
// #docregion platform_imports
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';


void main() => runApp(const MaterialApp(home: WebViewExample()));

const String kLocalExamplePage = '''
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Page Title</title>
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <link rel="stylesheet" href="https://simpleui-au.vixverify.com/df/assets/stylesheets/greenid.css" />
        <style>
        </style>
    </head>
    <body>
        <div id="green-id-verification"></div>

        <script src="https://simpleui-au.vixverify.com/df/javascripts/greenidConfig.js"></script>
        <script src="https://simpleui-au.vixverify.com/df/javascripts/greenidui.min.js"></script>
        <script>
            greenidUI.setup({
                environment: 'test',
                frameId: 'green-id-verification',
                errorCallback: onError,
                sessionCompleteCallback: onSessionComplete,
                sessionCancelledCallback: onSessionCancel,
            });

            greenidConfig.setOverrides({
                "visa_short_title": "Foreign passport",
                "visa_title": "Foreign passport (Australian visa)",
                "visa_info_title": "Foreign passport (Australian visa)",
                "visadvs_short_title": "Foreign passport",
                "visadvs_title": "Foreign passport (Australian visa)",
                "visadvs_info_title": "About the Foreign passport (Australian visa) source"
            });
            
            // greenidUI.show('mhits', 'KqM-rTB-Xfw-JLw', "eb8259b428d692d75623d375fadd5c1814b1fdd0");

            function onError(param1, param2) {

                VerificationError.postMessage('greenID validation error ' +  param1 + ' : ' + param2);
            }

            function onSessionComplete(data) {

                VerificationComplete.postMessage('greenID validation complete: ' + data);
            }

            function onSessionCancel() {

                VerificationCancelled.postMessage('greenID validation cancelled');
            }
        </script>
    </body>
</html>
''';

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
//       ..setNavigationDelegate(
//         NavigationDelegate(
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
//           onNavigationRequest: (NavigationRequest request) {
//             debugPrint('allowing navigation to ${request.url}');
//             return NavigationDecision.navigate;
//           },
//           onUrlChange: (UrlChange change) {
//             debugPrint('url change to ${change.url}');
//           },
//         ),
//       )
      // handle verification error from the GreenID UI
      ..addJavaScriptChannel(
        'VerificationError',
        onMessageReceived: (JavaScriptMessage message) {
            debugPrint('verification error: ${message.message}');
        })
      // handle verification cancelled from the GreenID UI
      ..addJavaScriptChannel(
        'VerificationCancelled',
        onMessageReceived: (JavaScriptMessage message) {
            debugPrint('verification cancelled: ${message.message}');
        })
      // handle verification completed from the GreenID UI
      ..addJavaScriptChannel(
        'VerificationComplete',
        onMessageReceived: (JavaScriptMessage message) {
            debugPrint('verification complete: ${message.message}');
        })
      ..loadHtmlString(kLocalExamplePage);

    
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

    final tokenController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        actions: <Widget>[
          Row(
            children: <Widget>[

                SizedBox(
                    width: 300,
                    child: TextField(
                        controller: tokenController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Token',
                        ),
                    ),
                ),
                IconButton(
                    icon: const Icon(Icons.verified_user),
                    // trigger the display (show) of the GreenID verification UI 
                    // parameters: 
                    //  1. GreenID API user
                    //  2. GreenID API secret
                    //  3. the customers GreenID token, this is returned when the customer KYC data has been submitted,
                    //     or retrieved after KYC data has previously been submitted. 
                    onPressed: () => _controller.runJavaScript("greenidUI.show('mhits', 'KqM-rTB-Xfw-JLw', '${tokenController.text}');")
                ),
            ])
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
