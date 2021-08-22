# General
Minimal HTML WYSIWYG editor with **only context menu formatting options** (for now), support flexible height, customize placeholder, intial text, background color, and common textfield callbacks and methods. 

Only backbone html, css and js underneath, no libary, no jQuery. Extremely lightweight.

Flutter `CircularProgressIndicator` is shown when web view is being loaded, giving smooth UI experience.

Works with screen reader.
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
			flexibleHeight: true,
			autoAdjustScroll: true,
			// Alternatively, make a variable for this to gain access to the web controller and the editor methods
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
		),
		...,
],
),
```
Check out Example and API reference for more.
