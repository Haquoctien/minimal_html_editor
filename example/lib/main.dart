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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        appBar: AppBar(
          title: Text("Minimal Html Editor demo"),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              label: "One",
              icon: Icon(Icons.ac_unit),
            ),
            BottomNavigationBarItem(
              label: "Two",
              icon: Icon(Icons.access_alarm),
            )
          ],
        ),
        body: Center(
          child: ListView(
            controller: _scrollController,
            children: <Widget>[
              Center(
                  child: Text(
                "Hello world",
                style: TextStyle(fontSize: 20),
              )),
              HtmlEditor(
                flexibleHeight: true,
                minHeight: 150,
                autoAdjustScroll: true,
                scrollController: _scrollController,
              ),
              Center(
                  child: Text(
                "Chào thế giới",
                style: TextStyle(fontSize: 20),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
