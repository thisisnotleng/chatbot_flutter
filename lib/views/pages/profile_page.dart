import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _nameState();
}

class _nameState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Profile Page'),
    );
  }
}