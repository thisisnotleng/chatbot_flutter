import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

String name = 'CV11';
int number = 1;
double weight = 2.5;
List mylist = ['apple', 'banana', 'car'];
Map<String, int> myMap = {
  'ChanVathanaka': 11,
  'SouYaty': 1,
  'Rous Somoeun': 26,
};

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          brightness: Brightness.dark,
        ),
      ),
      home: const MyHomePage(title: 'Youleng Learing FLutter Journey'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // int _counter = 15;

  void _incrementCounter() {
    setState(() {
      // _counter--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
        leading: Icon(Icons.notification_important, color: Colors.red),
      ),

      // body: Center(
      //   child: Container(
      //     color: Colors.black,
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       children: [
      //         Container(
      //           height: 100.0,
      //           width: 100.0,
      //           decoration: BoxDecoration(
      //             borderRadius: BorderRadius.circular(16.0),
      //             color: Colors.red,
      //           ),
      //         ),
      //         Container(
      //           alignment: Alignment.center,
      //           child: Text(
      //             'Box2',
      //           ),
      //           height: 100.0,
      //           width: 100.0,
      //           decoration: BoxDecoration(
      //             borderRadius: BorderRadius.circular(16.0),
      //             color: Colors.red,
      //           ),
      //         ),
      //         Text(
      //           'I am at the middle!',
      //           style: TextStyle(color: Colors.red),
      //         ),

      //       ],
      //     ),
      //   ),
      // ),
      // body: Stack(
      //   children: [
      //     // Image.asset(
      //     //   'assets/images/mac-os-wallpaper.jpg',
      //     //   fit: BoxFit.cover),
      //     SizedBox(height: 300, child: Center(child: Text('Flutter'))),
      //     ListTile(
      //       leading: Icon(Icons.update),
      //       tileColor: Colors.red,
      //       title: Text("New Version Available!"),
      //       trailing: Text('Update Now'),
      //       onTap: () {
      //         print('Updated');
      //       },
      //     ),
      //   ],

      //   // 'https://wallpapers.ispazio.net/wp-content/uploads/2025/06/ios-26-wallpaper-by-ispazio-1-768x1664.jpg',
      // ),


      body: Wrap(
        children: [
          Text('THISISNOTLENG'),
          Text('THISISNOTLENG'),
          Text('THISISNOTLENG'),
          Text('THISISNOTLENG'),
          Text('THISISNOTLENG'),
          Text('THISISNOTLENG'),
        ],
      ),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
