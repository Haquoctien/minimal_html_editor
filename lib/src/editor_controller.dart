import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class EditorController {
  /// Underlying web view controller.
  ///
  /// This will get initialized once the editor is fully loaded.
  late InAppWebViewController webViewController;

  /// Controller that controls the enclosing scroll view.
  ///
  /// ```dart
  /// ListView(
  ///   controller: scrollController,
  ///   children: [
  ///     ...,
  ///     HtmlEditor(
  ///       controller: EditorController(
  ///         scrollController: scrollController
  ///       ), // EditorController
  ///     ), // HtmlEditor
  ///     ...,
  ///   ],
  /// ) // ListView
  /// ```
  ScrollController? scrollController;

  EditorController({this.scrollController});

  void setWebViewController(InAppWebViewController controller) {
    this.webViewController = controller;
  }

  void focus() {
    webViewController.evaluateJavascript(
        source: 'document.getElementById("editor").focus();');
  }

  void unfocus() {
    webViewController.evaluateJavascript(
        source: 'document.getElementById("editor").blur();');
  }

  /// Get html content from editor
  Future<String> getHtml() async {
    return await webViewController.evaluateJavascript(
        source: 'document.getElementById("editor").innerHTML;');
  }

  /// Set html content for editor
  void setHtml(String html) async {
    if (html != '<p></p>' && html != '<p><br></p>') {
      await webViewController.evaluateJavascript(source: 'hidePlaceholder();');
    }
    await webViewController.evaluateJavascript(
        source: 'document.getElementById("editor").innerHTML = `$html`;');
  }
}
