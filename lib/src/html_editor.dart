import 'dart:io';
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// ignore: must_be_immutable
class HtmlEditor extends StatefulWidget {
  HtmlEditor({
    Key? key,
    this.controller,
    this.scrollController,
    this.onChange,
    this.onFocus,
    this.onBlur,
    this.minHeight = 300.0,
    this.autoAdjustScroll = false,
    this.flexibleHeight = false,
    this.backgroundColorCssCode = "#ffffff",
    this.placeholder = "Edit text",
  }) : super(key: key);
  final ScrollController? scrollController;
  InAppWebViewController? controller;
  final Function(String content, double height)? onChange;
  final Function()? onFocus;
  final Function()? onBlur;
  final double minHeight;
  final bool autoAdjustScroll;
  final bool flexibleHeight;
  final String backgroundColorCssCode;
  final String placeholder;

  @override
  _HtmlEditorState createState() => _HtmlEditorState();
}

class _HtmlEditorState extends State<HtmlEditor> {
  late String htmlData;
  late double _height;
  late ContextMenu _contextMenu;
  late InAppWebViewController _controller;

  @override
  void initState() {
    htmlData = """
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, user-scalable=yes">
    <title>Din besked</title>
</head>
<style>
    [contenteditable]:focus {
        outline: 0px solid transparent;
    }

    body {
      height: ${widget.flexibleHeight ? 'auto' : '${widget.minHeight}px'} !important;
      overflow: ${widget.flexibleHeight ? 'hidden' : 'scroll'} !important;
      background-color: ${widget.backgroundColorCssCode} !important;
      font-family: sans-serif;
      margin: 0px;
      padding-left: 10px;
      padding-right: 10px;
      padding-bottom: 10px;
    }

    #editor {
        margin-top: -10px;
        height: inherit;
        overflow: inherit;
        position: relative;
        word-wrap: break-word
    }

    #placeholder {
        position: absolute;
        color: grey
    }
</style>
<body id="body">
    <div id="editor-container">
        <div contenteditable="true" role="textbox" aria-multiline="true" spellcheck="false" autocorrect="false"
            inputmode="text" style="height: ${widget.minHeight} px;" id="editor">
        </div>
    </div>
</body>

</html>
""";
    _height = widget.minHeight;
    _contextMenu = ContextMenu(
      menuItems: [
        if (Platform.isAndroid) ...[
          ContextMenuItem(
            androidId: 0,
            iosId: "0",
            title: "𝗕",
            action: () {
              _controller.evaluateJavascript(source: """
              document.execCommand('bold');
            """);
            },
          ),
          ContextMenuItem(
            androidId: 1,
            iosId: "1",
            title: "𝐼",
            action: () {
              _controller.evaluateJavascript(source: """
              document.execCommand('italic');
            """);
            },
          ),
          ContextMenuItem(
            androidId: 2,
            iosId: "2",
            title: "U̲",
            action: () {
              _controller.evaluateJavascript(source: """
             document.execCommand('underline');
            """);
            },
          ),
        ],
        ContextMenuItem(
          androidId: 3,
          iosId: "3",
          title: "Remove format",
          action: () {
            _controller.evaluateJavascript(source: """
              document.execCommand('removeFormat');
            """);
          },
        ),
      ],
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      child: InAppWebView(
        initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              javaScriptEnabled: true,
              transparentBackground: true,
              disableHorizontalScroll: widget.flexibleHeight,
              disableVerticalScroll: widget.flexibleHeight,
              horizontalScrollBarEnabled: !widget.flexibleHeight,
              verticalScrollBarEnabled: !widget.flexibleHeight,
              supportZoom: false,
            ),
            ios: IOSInAppWebViewOptions(
              disallowOverScroll: true,
              scrollsToTop: false,
              allowsBackForwardNavigationGestures: false,
            ),
            android: AndroidInAppWebViewOptions(
              geolocationEnabled: false,
              builtInZoomControls: false,
              thirdPartyCookiesEnabled: false,
            )),
        contextMenu: _contextMenu,
        onConsoleMessage: (_, message) {
          print("Webview: " + message.message);
        },
        initialData: InAppWebViewInitialData(
          data: htmlData,
        ),
        onWebViewCreated: (controller) {
          _controller = controller;
        },
        onLoadStop: (controller, _) {
          // set up editor and add callbacks
          _controller = controller;
          _controller.injectJavascriptFileFromAsset(assetFilePath: "assets/initialize.js");
          _controller.evaluateJavascript(source: """
          var placeholder = document.createElement("div");
          placeholder.innerHTML = "<p>${widget.placeholder}</p>";
          placeholder.id = "placeholder";
          document.getElementById("editor-container").prepend(placeholder);
          """);
          // add handlers
          controller.addJavaScriptHandler(
              handlerName: 'onFocus',
              callback: (_) {
                if (Platform.isIOS) {
                  setState(() {
                    _height += Random().nextBool() ? 0.5 : -0.5;
                  });
                }
                widget.onFocus?.call();
              });
          controller.addJavaScriptHandler(
              handlerName: 'onBlur',
              callback: (_) {
                widget.onBlur?.call();
              });
          controller.addJavaScriptHandler(
              handlerName: 'onChange',
              callback: (args) {
                String content = args[0];
                int height = args[1];
                adjustEditorHeight(contentHeight: height.toDouble());
                widget.onChange?.call(content, height.toDouble());
              });
        },
      ),
    );
  }

  void adjustEditorHeight({
    required double contentHeight,
  }) {
    var heightChange = contentHeight - _height;
    if (heightChange != 0) {
      setState(() {
        _height = max(contentHeight, 200);
      });
      if (widget.scrollController != null && widget.autoAdjustScroll) {
        ScrollController controller = widget.scrollController!;
        if (controller.position.maxScrollExtent > 0) {
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            controller.animateTo(controller.offset + heightChange,
                duration: Duration(milliseconds: 200), curve: Curves.ease);
          });
        }
      }
    }
  }
}
