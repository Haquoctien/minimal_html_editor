import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class EditorController {
  late InAppWebViewController webViewController;
  ScrollController? scrollController;

  EditorController({this.scrollController});

  void setWebViewController(InAppWebViewController controller) {
    this.webViewController = controller;
  }

  void focus() {
    webViewController.evaluateJavascript(source: 'document.getElementById("editor").focus();');
  }

  void unfocus() {
    webViewController.evaluateJavascript(source: 'document.getElementById("editor").blur();');
  }

  Future<String> getText() {
    return webViewController
        .evaluateJavascript(source: 'document.getElementById("editor").innerHTML;')
        .then((value) => value);
  }

  void setText(String text) async {
    if (text != '<p></p>' && text != '<p><br></p>') {
      await webViewController.evaluateJavascript(source: 'hidePlaceholder();');
    }
    await webViewController.evaluateJavascript(source: 'document.getElementById("editor").innerHTML = `$text`;');
  }
}
