
import 'package:flutter/material.dart';

import '../data/app_icons.dart';
import '../data/colors.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key, slug});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".


  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  int _counter = 0;
  var glyphs=[];
  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: BaseColors.gold4,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('测试页'),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 10),
        child: GridView.count(
          crossAxisCount: 4,
          scrollDirection: Axis.vertical,
          children: const [
            Column(children: [Icon(AppIcons.home_outline),Text('home_outline')]),
            Column(children: [Icon(AppIcons.home),Text('home')]),
            Column(children: [Icon(AppIcons.chat),Text('chat')]),
            Column(children: [Icon(AppIcons.chat_1),Text('chat_1')]),
            Column(children: [Icon(AppIcons.group),Text('group')]),
            Column(children: [Icon(AppIcons.user),Text('user')]),
            Column(children: [Icon(AppIcons.user_plus),Text('user_plus')]),
            Column(children: [Icon(AppIcons.user_minus),Text('user_minus')]),
            Column(children: [Icon(AppIcons.user_times),Text('user_times')]),
            Column(children: [Icon(AppIcons.user_friends),Text('user_friends')]),
            Column(children: [Icon(AppIcons.spin4),Text('spin4')]),
            Column(children: [Icon(AppIcons.spin3),Text('spin3')]),
            Column(children: [Icon(AppIcons.spin6),Text('spin6')]),
            Column(children: [Icon(AppIcons.heart),Text('heart')]),
            Column(children: [Icon(AppIcons.heart_empty),Text('heart_empty')]),
            Column(children: [Icon(AppIcons.down_open),Text('down_open')]),
            Column(children: [Icon(AppIcons.left_open),Text('left_open')]),
            Column(children: [Icon(AppIcons.right_open),Text('right_open')]),
            Column(children: [Icon(AppIcons.up_open),Text('up_open')]),
            Column(children: [Icon(AppIcons.down_open_mini),Text('down_open_mini')]),
            Column(children: [Icon(AppIcons.left_open_mini),Text('left_open_mini')]),
            Column(children: [Icon(AppIcons.right_open_mini),Text('right_open_mini')]),
            Column(children: [Icon(AppIcons.up_open_mini),Text('up_open_mini')]),
            Column(children: [Icon(AppIcons.down_open_big),Text('down_open_big')]),
            Column(children: [Icon(AppIcons.file_word),Text('file_word')]),
            Column(children: [Icon(AppIcons.file_excel),Text('file_excel')]),
            Column(children: [Icon(AppIcons.file_powerpoint),Text('file_powerpoint')]),
            Column(children: [Icon(AppIcons.file_image),Text('file_image')]),
            Column(children: [Icon(AppIcons.file_archive),Text('file_archive')]),
            Column(children: [Icon(AppIcons.file_audio),Text('file_audio')]),
            Column(children: [Icon(AppIcons.file_code),Text('file_code')]),
            Column(children: [Icon(AppIcons.file_video),Text('file_video')]),
            Column(children: [Icon(AppIcons.doc_text_inv),Text('doc_text_inv')]),
            Column(children: [Icon(AppIcons.file_pdf),Text('file_pdf')]),
            Column(children: [Icon(AppIcons.doc_inv),Text('doc_inv')]),
            Column(children: [Icon(AppIcons.doc_text),Text('doc_text')]),
            Column(children: [Icon(AppIcons.docs),Text('docs')]),
            Column(children: [Icon(AppIcons.doc),Text('doc')]),
            Column(children: [Icon(AppIcons.globe_outline),Text('globe_outline')]),
            Column(children: [Icon(AppIcons.globe),Text('globe')]),
            Column(children: [Icon(AppIcons.home_1),Text('home_1')]),
            Column(children: [Icon(AppIcons.down_open_1),Text('down_open_1')]),
            Column(children: [Icon(AppIcons.left_open_1),Text('left_open_1')]),
            Column(children: [Icon(AppIcons.right_open_1),Text('right_open_1')]),
            Column(children: [Icon(AppIcons.up_open_1),Text('up_open_1')]),
            Column(children: [Icon(AppIcons.down),Text('down')]),
            Column(children: [Icon(AppIcons.left),Text('left')]),
            Column(children: [Icon(AppIcons.right),Text('right')]),
            Column(children: [Icon(AppIcons.up),Text('up')]),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}