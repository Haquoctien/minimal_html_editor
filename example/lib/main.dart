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
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
                Text("Flexible"),
                Text("Fixed and scrollable"),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                label: "Log content ",
                icon: IconButton(
                  icon: Icon(Icons.pages),
                  onPressed: () async => print(
                    await _editorController.getHtml(),
                  ),
                ),
              ),
              BottomNavigationBarItem(
                label: "Focus",
                icon: IconButton(
                  icon: Icon(Icons.edit_attributes_sharp),
                  onPressed: () => _editorController.focus(),
                ),
              ),
              BottomNavigationBarItem(
                label: "Blur",
                icon: IconButton(
                  icon: Icon(Icons.edit_attributes_sharp),
                  onPressed: () => _editorController.unfocus(),
                ),
              ),
            ],
          ),
          body: TabBarView(
            children: [
              ListView(
                controller: _scrollController,
                children: <Widget>[
                  Center(
                    child: Text(
                      "Hello world",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  HtmlEditor(
                    flexibleHeight: true,
                    autoAdjustScroll: true,
                    controller: _editorController,
                    minHeight: 150,
                    backgroundColorCssCode: "magenta",
                    initialText: "Hi there",
                    placeholder: "Placeholder for flexible height",
                    printWebViewLog: true,
                    onChange: (content, height) => print(content),
                  ),
                  Center(
                    child: Text(
                      "Chào thế giới",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Center(
                      child: Text(
                        "Hello world",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    HtmlEditor(
                      backgroundColorCssCode: "#fafafa",
                      minHeight: 250,
                      initialText: r"""<p>I am normal</p>
                        <p style="color:red;">I am red</p>
                        <p style="color:blue;">I am blue</p>
                        <p style="font-size:50px;">I am big</p>""",
                      placeholder: "Placeholder for fixed height",
                    ),
                    Center(
                      child: Text(
                        "Chào thế giới",
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
