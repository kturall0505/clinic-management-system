import 'package:flutter/material.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});
  @override State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override void initState() { super.initState(); }

  @override Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text('Appointments - Coming soon')),
    );
  }
}