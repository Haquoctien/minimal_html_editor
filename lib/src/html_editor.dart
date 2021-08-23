import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:minimal_html_editor/src/editor_controller.dart';

// ignore: must_be_immutable
class HtmlEditor extends StatefulWidget {
  /// Controller for controlling underlying webview and parent's scroll controller.
  ///
  /// This exposes the [EditorController.getHtml],[EditorController.setHtml], [EditorController.focus],
  /// [EditorController.unfocus] and [EditorController.webViewController] methods for this editor.
  late final EditorController controller;

  /// Call when editor contents change.
  ///
  /// [content] is the current content.
  /// [height] is the current content height, including scrollheight.
  final Function(String content, double height)? onChange;

  /// Call when editor gains focus.
  final Function()? onFocus;

  /// Call when editor loses focus.
  final Function()? onBlur;

  /// Whether widget will be flexible in height with respect to content.
  ///
  /// Default to `false`.
  final bool flexibleHeight;

  /// Minimum initial height for editor.
  ///
  /// This will be the height of this widget if [flexibleHeight] is `false`.
  /// Otherwise it will be the initial height and the widget will grow
  /// or shrink to accomodate content height, but never shrinks below this value.
  ///
  /// Default to `300.0`.
  final double minHeight;

  /// Adjust scroll so new lines don't go below keyboard.
  ///
  /// Not needed for [flexibleHeight] is `false`.
  /// If `true`, [EditorController.scrollController] must not be `null`.
  ///
  /// Default to `false`.
  final bool autoAdjustScroll;

  /// Background color for editor in css.
  ///
  /// This will be injected into the editor's css stylesheet.
  /// See `https://www.w3schools.com/cssref/css_colors.asp`.
  ///
  /// Default to `#ffffff`, which is white.
  final String backgroundColorCssCode;

  /// Padding for editor
  ///
  /// Default to [EdgeInsets.zero]
  final EdgeInsets padding;

  /// Placeholder (hint) for editor.
  ///
  /// Default to `Edit text`.
  final String placeholder;

  /// Initial text for editor.
  ///
  /// Has to be plain text in order to not mess up editor layout.
  /// Will be wrapped in `<p></p>`.
  /// Replaces `<p><br></p>` as the initial html content.
  final String? initialText;

  /// Whether to print webview console logs to debugger.
  ///
  /// Default to `false`.
  final bool printWebViewLog;

  /// Page title for web view.
  ///
  /// Can be used by screen reader as label for webview.
  final String webViewTitle;

  /// Enable Android hybrid composition.
  ///
  /// NOTE: It is recommended to use Hybrid Composition only on Android 10+ for a release app, as it can cause framerate drops on animations in Android 9 and lower.
  /// Default to `false`.
  final bool useAndroidHybridComposition;

  /// Whether to stack a loading wheel on top while the editor is being loaded.
  ///
  /// Default to `false`.
  final bool showLoadingWheel;

  /// Content scale factor for this web view
  ///
  /// Default to `1.0`
  final double scaleFactor;

  /// Custom webview options
  final InAppWebViewGroupOptions? webViewOptions;

  /// Creates a [HtmlEditor].
  ///
  /// No paramameters are `required`. But if [autoAdjustScroll] is `true`,
  /// then [EditorController.scrollController] must not be `null`.
  HtmlEditor({
    Key? key,
    EditorController? controller,
    this.onChange,
    this.onFocus,
    this.onBlur,
    this.minHeight = 300.0,
    this.padding = EdgeInsets.zero,
    this.autoAdjustScroll = false,
    this.flexibleHeight = false,
    this.backgroundColorCssCode = "#ffffff",
    this.placeholder = "Edit text",
    this.initialText,
    this.printWebViewLog = false,
    this.webViewTitle = "Editor",
    this.useAndroidHybridComposition = false,
    this.showLoadingWheel = false,
    this.scaleFactor = 1.0,
    this.webViewOptions,
  }) : super(key: key) {
    if (controller == null) {
      this.controller = EditorController();
    } else {
      this.controller = controller;
    }
    if (autoAdjustScroll && flexibleHeight) {
      assert(this.controller.scrollController != null);
    }
  }

  @override
  HtmlEditorState createState() => HtmlEditorState();
}

class HtmlEditorState extends State<HtmlEditor>
    with AutomaticKeepAliveClientMixin {
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
    <meta name="viewport" content="width=device-width, initial-scale=1}">
    <title>${widget.webViewTitle}</title>
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
      padding-top: ${widget.padding.top}px;
      padding-left: ${widget.padding.left}px;
      padding-right: ${widget.padding.right}px;
      padding-bottom: ${widget.padding.bottom}px;
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
  <div contenteditable="true" role="textbox" aria-multiline="true" spellcheck="false" autocorrect="false"
      inputmode="text" id="editor">
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
    if (widget.flexibleHeight) {
      widget.controller.setSetHeightCallback((height) {
        if (mounted) {
          this.setState(() {
            _height = max(height, widget.minHeight);
          });
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      height: _height + widget.padding.top + widget.padding.bottom,
      child: widget.showLoadingWheel ? buildStack() : buildWebView(),
    );
  }

  Widget buildWebView() {
    return InAppWebView(
      initialOptions: widget.webViewOptions ??
          InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              javaScriptEnabled: true,
              transparentBackground: true,
              disableHorizontalScroll: true,
              disableVerticalScroll: widget.flexibleHeight,
              horizontalScrollBarEnabled: false,
              verticalScrollBarEnabled: !widget.flexibleHeight,
              //supportZoom: false,
            ),
            android: AndroidInAppWebViewOptions(
              geolocationEnabled: false,
              builtInZoomControls: false,
              thirdPartyCookiesEnabled: false,
              textZoom: (100 * widget.scaleFactor).toInt(),
              useHybridComposition: widget.useAndroidHybridComposition,
            ),
          ),
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
            var body = document.getElementById("body");
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
              document.getElementById("body").prepend(placeholder);
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
          widget.controller.setHtml('<p>${widget.initialText!}</p>');
        }
      },
    );
  }

  Widget buildStack() {
    return Stack(
      children: [
        buildWebView(),
        if (_showLoadingWheel)
          Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          )
      ],
    );
  }

  void adjustEditorHeight({
    required double contentHeight,
  }) {
    var heightChange = contentHeight - _height;
    if (heightChange != 0) {
      setState(() {
        _height = max(contentHeight, widget.minHeight);
      });
      if (widget.controller.scrollController != null &&
          widget.autoAdjustScroll) {
        ScrollController controller = widget.controller.scrollController!;
        if (controller.position.maxScrollExtent > 0) {
          controller.animateTo(controller.offset + heightChange,
              duration: Duration(milliseconds: 200), curve: Curves.ease);
        }
      }
    }
  }

  @override
  bool get wantKeepAlive => _controller != null && mounted;
}
