# General
[Minimal HTML WYSIWYG editor](https://pub.dev/packages/minimal_html_editor) with **only context menu formatting options** (for now).

This is mainly an alternative to other html-based WYSIWYG editors that:
 - use Summernote under the hood and very bloated
 - doesn't work well with screen reader
 - and doesn't offer fine-grained UI customization
 - lacking common text field callbacks and methods
# Features
### *Support fine-grained UI customization:*
- fixed height or flexible height
- customized placeholder, intial text
- background color
- padding
- Android hybrid composition
- Webview title (for screen reader)
- Auto-adjust scrolling for editor's height change
### *Common text field callbacks:*
- on focus
- on blur
- on change
### *Controller methods*
- set html
- get html
- focus
- unfocus
### *Lightweight*
Only backbone html, css and js underneath, no libary, no jQuery.
### *Exposed controller*
`EditorController.webViewController` is expose via `HtmlEditor.controller`. 
### *Smooth UI*
Flutter's `CircularProgressIndicator` is shown when web view is being loaded, no more empty container.
# How to use
## Minimal example
No constructor fields are required, just insert this into your widget tree:
```dart
HtmlEditor(),
```
## Simple example
Editor with fixed height, custom placeholder and initial content, gray background and onChange callback to update something:
```dart
HtmlEditor(
  backgroundColorCssCode: "gray",
  minHeight: 300,
  initialText: "Some initial text",
  placeholder: "Edit me",
  onChange: (content, height) => update(content),
),
```
## Full feature example
Editor with custom appearance, flexible height, auto scrolling to avoid texts going below keyboard while editing, custom web view title for screen reader and callbacks actions:
```dart
ListView(
  controller: scrollController,
  children: [
    ...,
    HtmlEditor(
      backgroundColorCssCode: "#555555",
      minHeight: 300,
      padding: EdgeInsets.zero,
      flexibleHeight: true,
      autoAdjustScroll: true,
      // Alternatively, make a variable for this
      // to gain access to the web controller and
      // the editor methods
      controller: EditorController(
        scrollController: scrollController,
      ),
      initialText: "Some initial text",
      placeholder: "Edit me",
      onChange: (content, height) => update(content),
      onFocus: () => doSomething(),
      onBlur: () => doSomeOtherThing(),
      printWebViewLog: true,
      webViewTitle: "Editor",
      useAndroidHybridComposition: true,
    ),
    ...,
  ],
),
```
Check out Example and API reference for more.
