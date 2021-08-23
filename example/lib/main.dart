import 'package:flutter/material.dart';
import 'package:minimal_html_editor/minimal_html_editor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minimal Html Editor',
      home: MyHomePage(title: 'Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _scrollController = ScrollController();
  late EditorController _editorController;
  @override
  void initState() {
    _editorController = EditorController(scrollController: _scrollController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        body: Scaffold(
          appBar: AppBar(
            title: Text("Minimal Html Editor demo"),
            bottom: TabBar(
              tabs: [
                Text("Flexible height, magenta background"),
                Text("Fixed height and scrollable"),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: <Widget>[
                    Center(
                      child: Text(
                        "Flexible height, magenta background",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    HtmlEditor(
                      flexibleHeight: true,
                      autoAdjustScroll: true,
                      controller: _editorController,
                      minHeight: 150,
                      padding: EdgeInsets.all(20),
                      backgroundColorCssCode: "magenta",
                      initialText: "Some initial text",
                      placeholder: "Chào thế giới",
                      printWebViewLog: true,
                      useAndroidHybridComposition: true,
                      showLoadingWheel: true,
                      scaleFactor: 2,
                      onChange: (content, height) => print(content),
                    ),
                    Center(
                      child: Text(
                        "Flexible height, magenta background",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Center(
                      child: Text(
                        "Fixed height and scrollable",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    HtmlEditor(
                      backgroundColorCssCode: "#fafafa",
                      minHeight: 250,
                      initialText: "Some initial text",
                      placeholder: "Chào thế giới",
                    ),
                    Center(
                      child: Text(
                        "Fixed height and scrollable",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
