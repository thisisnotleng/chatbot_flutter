import 'package:flutter/material.dart';
import 'package:my_first_app/data/notifiers.dart';
import 'package:my_first_app/views/pages/home_page.dart';
import 'package:my_first_app/views/pages/profile_page.dart';
import 'package:my_first_app/views/pages/setting_page.dart';
import 'widgets/navbar_widget.dart';

List<Widget> pages = [
  HomePage(),
  ProfilePage(),
];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Mapp"),
        centerTitle: false,
        leading: IconButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => SettingPage()));
        }, icon: Icon(Icons.settings)),
        // leading: Image(image: AssetImage('image/ios12_bg.jpg')),
        actions: [Text('Login'), Icon(Icons.login)],
      ),
      body: ValueListenableBuilder(valueListenable: selectedPageNotifier, builder: (context, selectedPage, child) {
        return pages.elementAt(selectedPage);
      },),
      bottomNavigationBar: NavbarWidget(),
    );
  }
}
