import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool isSwitchedAirplane = false;
  bool isSwitchedWifi = false;
  bool isSwitchedBluetooth = false;
  bool isSwitchedCellular = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          Container(
            height: 60, // Set the height for the row
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    right: 12,
                  ), // Padding between image and text
                  child: Image.network(
                    'https://icons.veryicon.com/png/o/miscellaneous/ionicons/ios-airplane-1.png',
                    width: 32,
                    height: 32,
                  ),
                ),
                Text('Airplane Mode'),
                Spacer(),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8,
                  ), // Padding from the right edge
                  child: Switch.adaptive(
                    value: isSwitchedAirplane,
                    onChanged: (val) {
                      setState(() {
                        isSwitchedAirplane = val;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 60, // Set the height for the row
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    right: 12,
                  ), // Padding between image and text
                  child: Image.network(
                    'https://cdn-icons-png.flaticon.com/512/93/93158.png',
                    width: 32,
                    height: 32,
                  ),
                ),
                Text('Wifi'),
                Spacer(),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8,
                  ), // Padding from the right edge
                  child: Switch.adaptive(
                    value: isSwitchedWifi,
                    onChanged: (val) {
                      setState(() {
                        isSwitchedWifi = val;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 60, // Set the height for the row
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    right: 12,
                  ), // Padding between image and text
                  child: Image.network(
                    'https://cdn-icons-png.flaticon.com/512/659/659992.png',
                    width: 32,
                    height: 32,
                  ),
                ),
                Text('Bluetooth'),
                Spacer(),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8,
                  ), // Padding from the right edge
                  child: Switch.adaptive(
                    value: isSwitchedBluetooth,
                    onChanged: (val) {
                      setState(() {
                        isSwitchedBluetooth = val;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 60, // Set the height for the row
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    right: 12,
                  ), // Padding between image and text
                  child: Image.network(
                    'https://icons.veryicon.com/png/o/miscellaneous/alan-ui/ios-cellular-2.png',
                    width: 32,
                    height: 32,
                  ),
                ),
                Text('Cellular'),
                Spacer(),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8,
                  ), // Padding from the right edge
                  child: Switch.adaptive(
                    value: isSwitchedCellular,
                    onChanged: (val) {
                      setState(() {
                        isSwitchedCellular = val;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
