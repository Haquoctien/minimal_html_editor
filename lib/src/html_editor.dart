import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:minimal_html_editor/src/editor_controller.dart';

// ignore: must_be_immutable

class HtmlEditor extends StatefulWidget {
  late final EditorController controller;
  final Function(String content, double height)? onChange;
  final Function()? onFocus;
  final Function()? onBlur;
  final double minHeight;
  final bool autoAdjustScroll;
  final bool flexibleHeight;
  final String backgroundColorCssCode;
  final String placeholder;
  final String? initialText;
  final bool printWebViewLog;

  HtmlEditor({
    Key? key,
    controller,
    this.onChange,
    this.onFocus,
    this.onBlur,
    this.minHeight = 300.0,
    this.autoAdjustScroll = false,
    this.flexibleHeight = false,
    this.backgroundColorCssCode = "#ffffff",
    this.placeholder = "Edit text",
    this.initialText,
    this.printWebViewLog = false,
  }) : super(key: key) {
    if (controller == null) {
      this.controller = EditorController();
    } else {
      this.controller = controller;
    }
  }

  @override
  _HtmlEditorState createState() => _HtmlEditorState();
}

class _HtmlEditorState extends State<HtmlEditor> with AutomaticKeepAliveClientMixin {
  late String htmlData;
  late double _height;
  late ContextMenu _contextMenu;
  InAppWebViewController? _controller;
  Completer<bool> _isInitializedCompleter = Completer();
  bool _showLoadingWheel = true;
  late Future<bool> isInitialized;

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
      height: auto !important;
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
        height: auto !important;
        min-height: ${widget.minHeight}px;
        overflow: ${widget.flexibleHeight ? 'hidden' : 'scroll'} !important;
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
            inputmode="text" id="editor">
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
              _controller?.evaluateJavascript(source: """
              document.execCommand('bold');
            """);
            },
          ),
          ContextMenuItem(
            androidId: 1,
            iosId: "1",
            title: "𝐼",
            action: () {
              _controller?.evaluateJavascript(source: """
              document.execCommand('italic');
            """);
            },
          ),
          ContextMenuItem(
            androidId: 2,
            iosId: "2",
            title: "U̲",
            action: () {
              _controller?.evaluateJavascript(source: """
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
            _controller?.evaluateJavascript(source: """
              document.execCommand('removeFormat');
            """);
          },
        ),
      ],
    );
    isInitialized = _isInitializedCompleter.future;
    isInitialized.then(
      (value) => setState(
        () {
          _showLoadingWheel = !value;
        },
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      height: _height,
      child: Stack(
        children: [
          InAppWebView(
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                  transparentBackground: true,
                  disableHorizontalScroll: true,
                  disableVerticalScroll: widget.flexibleHeight,
                  horizontalScrollBarEnabled: false,
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
            onConsoleMessage: widget.printWebViewLog
                ? (_, message) {
                    print("Webview: " + message.message);
                  }
                : null,
            initialData: InAppWebViewInitialData(
              data: htmlData,
            ),
            onWebViewCreated: (controller) {
              _controller = controller;
            },
            onLoadError: (_, __, ___, ____) {
              _isInitializedCompleter.complete(false);
            },
            onLoadStop: (controller, _) {
              // set up editor and add callbacks
              controller.evaluateJavascript(source: """
            // initialize 
            var editor = document.getElementById("editor");
            editor.innerHTML = "<p><br></p>";
            var placeholder = document.createElement("div");
            placeholder.innerHTML = "<p>${widget.placeholder}</p>";
            placeholder.id = "placeholder";
            showPlaceholder();
            // block delete input to keep default content
            editor.addEventListener("keydown", event => {
                var key = event.key || event.code || event.keyCode.toString;
                if ((key === "Backspace" || key === "8" || key === "46") && editor.innerHTML === '<p><br></p>') {
                    event.preventDefault();
                }
            });
      
            // clean intput on paste so layout is not messed up
            editor.addEventListener('paste', event => {
                event.preventDefault();
                var text = event.clipboardData.getData("text/plain");
                console.log(text);
                document.execCommand("insertHTML", false, text);
            }, false);
      
            // focus callback
            editor.addEventListener('focus', (event) => {
                console.log("Editor focused");
                window.flutter_inappwebview.callHandler("onFocus");
            });
      
            document.getElementById("body").addEventListener('scroll', (event) => {
                console.log("Scroll!");
                event.preventDefault();
            });
      
            // blur callback
            editor.addEventListener('blur', (event) => {
                console.log("Editor unfocused");
                window.flutter_inappwebview.callHandler("onBlur");
            });
      
            // onChange callback
            editor.addEventListener("input", (event) => {
                var content = editor.innerHTML;
                var height = editor.scrollHeight;
                if (content != '<p><br></p>') {
                  hidePlaceholder();
                }
                else {
                  showPlaceholder();
                }
                console.log("Text:" + editor.innerHTML);
                console.log("Flexible height:" + height);
                window.flutter_inappwebview.callHandler("onChange", content, height);
            }, false);

            function showPlaceholder() {
              document.getElementById("editor-container").prepend(placeholder);
            }
            function hidePlaceholder() {
              placeholder.remove();
            }
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
                    if (widget.flexibleHeight) {
                      adjustEditorHeight(contentHeight: height.toDouble());
                    }
                    widget.onChange?.call(content, height.toDouble());
                  });
              _controller = controller;
              widget.controller.setWebViewController(controller);
              _isInitializedCompleter.complete(true);
              if (widget.initialText != null) {
                widget.controller.setText(widget.initialText!);
              }
            },
          ),
          if (_showLoadingWheel)
            Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            )
        ],
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
      if (widget.controller.scrollController != null && widget.autoAdjustScroll) {
        ScrollController controller = widget.controller.scrollController!;
        if (controller.position.maxScrollExtent > 0) {
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            controller.animateTo(controller.offset + heightChange,
                duration: Duration(milliseconds: 200), curve: Curves.ease);
          });
        }
      }
    }
  }

  @override
  bool get wantKeepAlive => _controller != null && mounted;
}
